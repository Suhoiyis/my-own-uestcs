#include "stdio.h"
void main()
{
  struct record {
    double   d;
    long     b;
    int      a;
    float    c;
  } ;

  struct record R[2] ;
  R[0].a=100;
  R[0].b=100;
  R[0].c=100;
  R[0].d=100;
  R[1].a=2147483640;
  R[1].b=0x12abcdef;
  R[1].c=16777217;
  R[1].d=16777217;
  printf("%d\n", R[0].a+R[1].a);
  printf("%f\n",R[1].c);
  printf("%lf\n",R[1].d) ;
}
