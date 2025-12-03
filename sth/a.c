#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    int *N = (int*)argv[1];  // 通过参数获取共享变量地址
    usleep(100000);          // 模拟处理延迟
    *N = *N + 1;
    return 0;
}

