#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    int *N = (int*)argv[1];
    usleep(300000);          // 初始延迟设置
    printf("B sees N = %d\n", *N);
    *N = 0;
    return 0;
}
