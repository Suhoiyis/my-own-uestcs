#include "stdio.h"
#include "string.h"
void outputs(char *str)
{
    char buffer[16];
    // 检查输入字符串的长度是否小于缓冲区容量
    if (strlen(str) < sizeof(buffer)) {
        strcpy(buffer, str); // 只有在安全的情况下才使用 strcpy
    } else {
        // 如果字符串太长，可以打印错误信息或进行截断处理
        printf("Error: Input string is too long and has been truncated.\n");
        // 安全地截断并复制
        strncpy(buffer, str, sizeof(buffer) - 1);
        buffer[sizeof(buffer) - 1] = '\0'; // 确保字符串以 null 结尾
    }
    printf("%s\n", buffer);
}
void hacker(void)
{
  printf("being hacked\n");
}
int main(int argc, char *argv[])
{
   outputs(argv[1]);
   printf("yes\n");
   return 0;
}
