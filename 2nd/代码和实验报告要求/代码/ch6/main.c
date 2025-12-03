#include "stdio.h" 
#include "stdlib.h"
#include "string.h"
#include "support.h"

int main() {
     char *str;
     printf("欢迎使用LoongArch 64的二进制程序通关游戏！\n");
     printf("开始第一关游戏！\n");
     str=read_string();
     phase1(str);
     printf("祝贺通过！开始第二关游戏！\n");
     phase2();
     printf("祝贺通过！开始第三关游戏！\n");
     phase3();
     printf("祝贺通过！开始第四关游戏！\n");
     scanf("%*c"); //读取缓冲区中的回车
     str=read_string();
     phase4(str);
     printf("祝贺通过！开始第五关游戏！\n");
     str=read_string();
     phase5(str);
     printf("祝贺通过！开始第六关游戏！\n");
     phase6();
     printf("祝贺通过！开始第七关游戏！\n");
     phase7();
     printf("祝贺通过！开始第八关游戏！\n");
     phase8();
     printf("祝贺顺序闯关！\n");
     return 0;
  } 
 

