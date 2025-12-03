#include "stdio.h"
void main()
{ struct record{
  char 	  xc;
  int 	  xi; 
  long   xl;
  short  xs;
  long long xll;
  char   yc;
  } ;
  struct  record R[2] ;
  R[0].xc=100;  R[0].xi=100; R[0].xl=100; R[0].xs=100; R[0].xll=100;R[0].yc=0xff;
  R[1].xc=0x11;   R[1].xi=0x12345678;    R[1].xl=0x2233aabbccddeeff; R[1].xs=0x4455;  
  R[1].xll=0x6677abcdefabcdef;R[1].yc=0x88; 
 printf("char:%dB,short:%dB,int:%dB\n",sizeof(R[0].xc),sizeof(R[0].xs),sizeof(R[0].xi));
 printf("long:%dB,long long:%dB\n",sizeof(R[0].xl),sizeof(R[0].xll));
 printf("R:%dB\n",sizeof(R));
}


