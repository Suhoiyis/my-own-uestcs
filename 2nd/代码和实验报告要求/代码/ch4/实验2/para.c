#include "stdio.h"
double funct(int i,double x,long j,double y,double *yptr);
void main()
{   int i=1;
    double x=2;
    long j=4;
    double y=8;
    y=funct(i,x,j,y,&x);
    printf("y=%f\n",y);   
}




















