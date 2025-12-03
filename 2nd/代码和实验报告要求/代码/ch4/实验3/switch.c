#include "stdio.h"
void main() {
   int a,b,c,result;
   scanf("%d %d %d",&a,&b,&c);
   switch(a) {
   case 15:
       c=b&0x0f;
   case 10: 
       result=c+50;
       break;
   case 12:
   case 17:
       result=b+50;
       break;
   case 14:
       result=b;
       break;
   default:
       result=a;
   };
   printf("result=%d\n",result);
 }
 

