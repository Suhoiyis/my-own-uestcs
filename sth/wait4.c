#include <sys/resource.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

void wait4_demo() {
    pid_t pid = fork();
    if (pid == 0) { // 子进程执行计算任务
        for (int i=0; i<1000000; i++) sqrt(rand());
        exit(0);
    } else if (pid > 0) {
        struct rusage usage;
        int status;
        wait4(pid, &status, 0, &usage);
        printf("CPU usage:\n");
        printf("User time: %ld.%06ld sec\n",
               usage.ru_utime.tv_sec, usage.ru_utime.tv_usec);
        printf("System time: %ld.%06ld sec\n",
               usage.ru_stime.tv_sec, usage.ru_stime.tv_usec);
    } else {
        perror("fork failed");
    }
}
