#include "stdio.h"
void swap(int *x,int *y){
	int t=*x;
   *x=*y;
   *y=t; 
}
void caller() {
  int x = 125;
  int y = 80;
  swap(&x,&y);
  printf("x=%d  y=%d\n",x,y);
}
void main()
{ 
   caller();
  
}
  
