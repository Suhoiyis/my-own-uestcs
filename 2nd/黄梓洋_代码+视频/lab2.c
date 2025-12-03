#include <stdio.h>
#include <stdlib.h>
#include <pcap.h>
#include <netinet/ip.h>
#include <netinet/if_ether.h>
#include <arpa/inet.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <limits.h>
#include <unistd.h>

#define STATS_WINDOWS 3
#define WINDOW_SIZES {2, 10, 40}
#define MAX_HISTORY 1000 // 每个窗口最多存储1000个数据包

typedef enum
{
    DIRECTION_INCOMING, // 入站
    DIRECTION_OUTGOING, // 出站
    DIRECTION_UNKNOWN,  // 未知方向
    DIRECTION_MULTICAST // 多播
} Direction;

// 窗口数据结构（区分入站/出站流量）
typedef struct
{
    unsigned long in_bytes;    // 入站字节数
    unsigned long out_bytes;   // 出站字节数
    unsigned long in_packets;  // 入站数据包数
    unsigned long out_packets; // 出站数据包数

    // 循环缓冲区存储数据包详情
    struct
    {
        time_t timestamp;
        unsigned long size;
        Direction dir; // 数据包方向
    } history[MAX_HISTORY];

    int head;
    int tail;
    int count;
} window_t;

typedef struct
{
    unsigned long window_bytes;
    unsigned long window_packets;
    time_t window_start;
} time_window_t;

typedef struct
{
    char iface[16];
    char filter[128];
    int promisc;
    int timeout_ms;
} config_t;

const int window_sizes[STATS_WINDOWS] = WINDOW_SIZES;
const config_t DEFAULT_CONFIG = {
    .iface = "eth0",
    .filter = "ip",
    .promisc = 1,
    .timeout_ms = 1000};

typedef struct
{
    char ip1[INET_ADDRSTRLEN];
    char ip2[INET_ADDRSTRLEN];
    char sip[INET_ADDRSTRLEN];
    char dip[INET_ADDRSTRLEN];
    unsigned long total_bytes;
    unsigned long in_bytes;
    unsigned long out_bytes;
    unsigned long peak_bandwidth;
    unsigned long in_peak_bandwidth;
    unsigned long out_peak_bandwidth;
    char fangxiang[10];
    window_t windows[STATS_WINDOWS]; // 滑动窗口统计（区分方向）
} ip_pair_t;

typedef struct
{
    ip_pair_t *pairs;
    size_t count;
    size_t capacity;
    pthread_mutex_t lock;
} ip_pair_stats_t;

typedef struct
{
    pcap_t *handle;
    config_t config;
    time_window_t windows[STATS_WINDOWS];
    pthread_mutex_t lock;
    volatile int running;
    ip_pair_stats_t ip_pairs;
    int strict_mode;
    unsigned char mac[ETH_ALEN];
} monitor_ctx_t;

/* 声明为全局变量 */
monitor_ctx_t ctx;

// 窗口操作函数
static void window_add_packet(window_t *window, time_t timestamp, unsigned long size, Direction dir)
{
    if (window->count >= MAX_HISTORY)
    {
        Direction old_dir = window->history[window->head].dir;
        unsigned long old_size = window->history[window->head].size;

        if (old_dir == DIRECTION_INCOMING)
        {
            window->in_bytes -= old_size;
            window->in_packets--;
        }
        else if (old_dir == DIRECTION_OUTGOING)
        {
            window->out_bytes -= old_size;
            window->out_packets--;
        }

        window->head = (window->head + 1) % MAX_HISTORY;
        window->count--;
    }

    window->history[window->tail].timestamp = timestamp;
    window->history[window->tail].size = size;
    window->history[window->tail].dir = dir;

    if (dir == DIRECTION_INCOMING)
    {
        window->in_bytes += size;
        window->in_packets++;
    }
    else if (dir == DIRECTION_OUTGOING)
    {
        window->out_bytes += size;
        window->out_packets++;
    }

    window->tail = (window->tail + 1) % MAX_HISTORY;
    window->count++;
}

static void window_prune_expired(window_t *window, time_t now, int window_sec)
{
    time_t cutoff = now - window_sec;

    while (window->count > 0)
    {
        if (window->history[window->head].timestamp < cutoff)
        {
            Direction dir = window->history[window->head].dir;
            unsigned long size = window->history[window->head].size;

            if (dir == DIRECTION_INCOMING)
            {
                window->in_bytes -= size;
                window->in_packets--;
            }
            else if (dir == DIRECTION_OUTGOING)
            {
                window->out_bytes -= size;
                window->out_packets--;
            }

            window->head = (window->head + 1) % MAX_HISTORY;
            window->count--;
        }
        else
        {
            break;
        }
    }
}

static double window_calculate_in_avg_bandwidth(window_t *window, time_t now, int window_sec)
{
    double actual_window_sec = window_sec;
    if (window->count > 0)
    {
        time_t oldest = window->history[window->head].timestamp;
        actual_window_sec = now - oldest;
        if (actual_window_sec > window_sec)
            actual_window_sec = window_sec;
    }

    if (actual_window_sec <= 0)
        return 0;
    return window->in_bytes / actual_window_sec;
}

static double window_calculate_out_avg_bandwidth(window_t *window, time_t now, int window_sec)
{
    double actual_window_sec = window_sec;
    if (window->count > 0)
    {
        time_t oldest = window->history[window->head].timestamp;
        actual_window_sec = now - oldest;
        if (actual_window_sec > window_sec)
            actual_window_sec = window_sec;
    }

    if (actual_window_sec <= 0)
        return 0;
    return window->out_bytes / actual_window_sec;
}

// 从物理层判断方向
Direction check_direction_from_physical(monitor_ctx_t *ctx, struct ethhdr *eth)
{
    if (memcmp(eth->h_dest, ctx->mac, ETH_ALEN) == 0)
        return DIRECTION_INCOMING;

    if (memcmp(eth->h_source, ctx->mac, ETH_ALEN) == 0)
        return DIRECTION_OUTGOING;

    return DIRECTION_UNKNOWN;
}

// 从IP层判断方向
Direction check_direction_from_ip(monitor_ctx_t *ctx, struct iphdr *ip)
{
    in_addr_t local_ip = inet_addr("192.168.217.250");

    if (ip->daddr == local_ip)
        return DIRECTION_INCOMING;

    if (ip->saddr == local_ip)
        return DIRECTION_OUTGOING;

    return DIRECTION_UNKNOWN;
}

// 检查是否是多播地址
int is_multicast_ip(struct iphdr *ip)
{
    return (ntohl(ip->daddr) & 0xF0000000) == 0xE0000000;
}

// 根据地址大小分配方向
Direction assign_direction_by_address(struct iphdr *ip)
{
    uint32_t src_ip = ntohl(ip->saddr);
    uint32_t dst_ip = ntohl(ip->daddr);

    if (src_ip < dst_ip)
        return DIRECTION_OUTGOING;
    else if (src_ip >= dst_ip)
        return DIRECTION_INCOMING;

    return DIRECTION_UNKNOWN;
}

// 初始化IP对
void init_ip_pair_stats(ip_pair_stats_t *stats)
{
    stats->pairs = malloc(16 * sizeof(ip_pair_t));
    stats->count = 0;
    stats->capacity = 16;
    pthread_mutex_init(&stats->lock, NULL);
}

// 更新IP对统计（区分入站/出站流量）
void update_ip_pair_stats(ip_pair_stats_t *stats, const char *src_ip, const char *dst_ip, unsigned long bytes, Direction dir)
{
    pthread_mutex_lock(&stats->lock);
    int cmp = strcmp(src_ip, dst_ip);
    const char *ip1 = (cmp < 0) ? src_ip : dst_ip;
    const char *ip2 = (cmp < 0) ? dst_ip : src_ip;

    time_t now = time(NULL);
    size_t i;

    for (i = 0; i < stats->count; i++)
    {
        if (strcmp(stats->pairs[i].ip1, ip1) == 0 && strcmp(stats->pairs[i].ip2, ip2) == 0)
        {
            stats->pairs[i].total_bytes += bytes;
            if (stats->pairs[i].peak_bandwidth < bytes)
            {
                stats->pairs[i].peak_bandwidth = bytes;
            }

            if (dir == DIRECTION_INCOMING)
            {
                strcpy(stats->pairs[i].fangxiang, "入站");
                stats->pairs[i].in_bytes += bytes;
                if (stats->pairs[i].in_peak_bandwidth < bytes)
                {
                    stats->pairs[i].in_peak_bandwidth = bytes;
                }
            }
            else if (dir == DIRECTION_OUTGOING)
            {
                strcpy(stats->pairs[i].fangxiang, "出站");
                stats->pairs[i].out_bytes += bytes;
                if (stats->pairs[i].out_peak_bandwidth < bytes)
                {
                    stats->pairs[i].out_peak_bandwidth = bytes;
                }
            }

            for (int w = 0; w < STATS_WINDOWS; w++)
            {
                window_prune_expired(&stats->pairs[i].windows[w], now, window_sizes[w]);
                window_add_packet(&stats->pairs[i].windows[w], now, bytes, dir);
            }

            pthread_mutex_unlock(&stats->lock);
            return;
        }
    }

    if (stats->count >= stats->capacity)
    {
        stats->capacity *= 2;
        stats->pairs = realloc(stats->pairs, stats->capacity * sizeof(ip_pair_t));
    }

    strcpy(stats->pairs[stats->count].ip1, ip1);
    strcpy(stats->pairs[stats->count].ip2, ip2);
    stats->pairs[stats->count].total_bytes = bytes;
    stats->pairs[stats->count].peak_bandwidth = bytes;
    stats->pairs[stats->count].in_peak_bandwidth = 0;
    stats->pairs[stats->count].out_peak_bandwidth = 0;

    if (dir == DIRECTION_INCOMING)
    {
        strcpy(stats->pairs[stats->count].fangxiang, "入站");
        stats->pairs[stats->count].in_bytes = bytes;
        stats->pairs[stats->count].in_peak_bandwidth = bytes;
        strcpy(stats->pairs[stats->count].sip, dst_ip);
        strcpy(stats->pairs[stats->count].dip, src_ip);
    }
    else if (dir == DIRECTION_OUTGOING)
    {
        strcpy(stats->pairs[stats->count].fangxiang, "出站");
        stats->pairs[stats->count].out_bytes = bytes;
        stats->pairs[stats->count].out_peak_bandwidth = bytes;
        strcpy(stats->pairs[stats->count].sip, src_ip);
        strcpy(stats->pairs[stats->count].dip, dst_ip);
    }

    for (int w = 0; w < STATS_WINDOWS; w++)
    {
        window_t *window = &stats->pairs[stats->count].windows[w];
        memset(window, 0, sizeof(window_t));

        window_add_packet(window, now, bytes, dir);
    }

    stats->count++;
    pthread_mutex_unlock(&stats->lock);
}

// 处理数据包
void packet_handler(u_char *user, const struct pcap_pkthdr *h, const u_char *packet)
{
    monitor_ctx_t *ctx = (monitor_ctx_t *)user;
    struct ethhdr *eth = (struct ethhdr *)packet;
    struct iphdr *ip = (struct iphdr *)(packet + sizeof(struct ethhdr));

    Direction direction = check_direction_from_physical(ctx, eth);
    if (direction == DIRECTION_UNKNOWN)
        direction = check_direction_from_ip(ctx, ip);

    if (direction == DIRECTION_UNKNOWN)
    {
        if (is_multicast_ip(ip))
            direction = DIRECTION_INCOMING;
        else
        {
            if (ctx->strict_mode)
                return;
            else
                direction = assign_direction_by_address(ip);
        }
    }

    char src_ip[INET_ADDRSTRLEN], dst_ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &ip->saddr, src_ip, INET_ADDRSTRLEN);
    inet_ntop(AF_INET, &ip->daddr, dst_ip, INET_ADDRSTRLEN);

    update_ip_pair_stats(&ctx->ip_pairs, src_ip, dst_ip, h->len, direction);
}

// 清理IP对
void cleanup_ip_pair_stats(ip_pair_stats_t *stats)
{
    free(stats->pairs);
    pthread_mutex_destroy(&stats->lock);
}

// 打印IP对统计（区分入站/出站流量）
void print_ip_pair_stats(ip_pair_stats_t *stats)
{
    pthread_mutex_lock(&stats->lock);
    time_t now = time(NULL);

    printf("\n=== IP Pair Traffic Statistics ===\n");
    FILE *fp = fopen("traffic_data.csv", "w");
    if (fp == NULL)
    {
        perror("fopen");
        printf("打不开");
        pthread_mutex_unlock(&stats->lock);
        return;
    }
    // fprintf(fp, "%s", "\n=== IP Pair Traffic Statistics ===\n");
    for (size_t i = 0; i < stats->count; i++)
    {
        printf("%-15s <-> %-15s | 总流量：%6lu B | 峰值带宽：%6lu B\n",
               stats->pairs[i].ip1,
               stats->pairs[i].ip2,
               stats->pairs[i].total_bytes,
               stats->pairs[i].peak_bandwidth);

        printf("入站总流量：%10luB | 出站总流量：%10luB\n",
               stats->pairs[i].in_bytes,
               stats->pairs[i].out_bytes);
        printf("入站峰值流量：%10luB | 出站峰值流量：%10luB\n",
               stats->pairs[i].in_peak_bandwidth,
               stats->pairs[i].out_peak_bandwidth);
        printf("入站：%15s -> %15s | ", stats->pairs[i].dip, stats->pairs[i].sip);
        printf("出站：%15s -> %15s\n", stats->pairs[i].sip, stats->pairs[i].dip);

        fprintf(fp, "%s , %s , %lu , %lu,%lu,%lu, %lu,%lu,",
                stats->pairs[i].sip,
                stats->pairs[i].dip,
                stats->pairs[i].total_bytes,
                stats->pairs[i].peak_bandwidth,
                stats->pairs[i].in_bytes,
                stats->pairs[i].out_bytes,
                stats->pairs[i].in_peak_bandwidth,
                stats->pairs[i].out_peak_bandwidth);

        for (int w = 0; w < STATS_WINDOWS; w++)
        {
            window_t *window = &stats->pairs[i].windows[w];
            window_prune_expired(window, now, window_sizes[w]);

            double in_avg = window_calculate_in_avg_bandwidth(window, now, window_sizes[w]);
            double out_avg = window_calculate_out_avg_bandwidth(window, now, window_sizes[w]);

            printf("过去%-3ds | 入站平均：%8.2f B/s | 出站平均：%8.2f B/s\n",
                   window_sizes[w],
                   in_avg,
                   out_avg);
            printf("         | 入站包数：%8lu    | 出站包数：%8lu\n",
                   window->in_packets,
                   window->out_packets);
            printf("---------------------------------------\n");
            fprintf(fp, "%.2f,%.2f,%lu,%lu,", in_avg, out_avg, window->in_packets, window->out_packets);
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
    pthread_mutex_unlock(&stats->lock);
}

// Ctrl c 退出
void signal_handler(int sig)
{
    printf("\nSignal %d received, preparing to exit...\n", sig);
    ctx.running = 0;
}

/* 添加缺失的函数实现 */
int init_capture(monitor_ctx_t *ctx)
{
    char errbuf[PCAP_ERRBUF_SIZE];
    struct bpf_program fp;

    ctx->handle = pcap_open_live(ctx->config.iface, BUFSIZ,
                                 ctx->config.promisc, ctx->config.timeout_ms, errbuf);
    if (!ctx->handle)
    {
        fprintf(stderr, "Error opening %s: %s\n", ctx->config.iface, errbuf);
        return -1;
    }

    if (pcap_compile(ctx->handle, &fp, ctx->config.filter, 0, PCAP_NETMASK_UNKNOWN) == -1)
    {
        fprintf(stderr, "Filter error: %s\n", pcap_geterr(ctx->handle));
        return -1;
    }

    if (pcap_setfilter(ctx->handle, &fp) == -1)
    {
        fprintf(stderr, "Filter install error: %s\n", pcap_geterr(ctx->handle));
        return -1;
    }

    printf("Monitoring %s with filter '%s'\n", ctx->config.iface, ctx->config.filter);
    return 0;
}

void *capture_thread(void *arg)
{
    monitor_ctx_t *ctx = (monitor_ctx_t *)arg;
    pcap_loop(ctx->handle, 0, packet_handler, (u_char *)ctx);
    return NULL;
}

int main(int argc, char **argv)
{
    pthread_t tid;
    ctx.strict_mode = 1;
    memset(&ctx, 0, sizeof(ctx));
    ctx.running = 1;
    ctx.config = DEFAULT_CONFIG;
    if (argc > 1)
        strncpy(ctx.config.iface, argv[1], sizeof(ctx.config.iface) - 1);

    init_ip_pair_stats(&ctx.ip_pairs);
    pthread_mutex_init(&ctx.lock, NULL);

    unsigned char my_mac[] = {0x00, 0x0C, 0x29, 0xBB, 0x1E, 0x8A};
    memcpy(ctx.mac, my_mac, ETH_ALEN);

    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    if (init_capture(&ctx) != 0)
    {
        return EXIT_FAILURE;
    }

    pthread_create(&tid, NULL, capture_thread, &ctx);

    // 主循环
    while (ctx.running)
    {
        sleep(5);
        print_ip_pair_stats(&ctx.ip_pairs);
    }

    // 清理
    pcap_breakloop(ctx.handle);
    pthread_join(tid, NULL);
    pcap_close(ctx.handle);
    pthread_mutex_destroy(&ctx.lock);
    cleanup_ip_pair_stats(&ctx.ip_pairs);

    return EXIT_SUCCESS;
}