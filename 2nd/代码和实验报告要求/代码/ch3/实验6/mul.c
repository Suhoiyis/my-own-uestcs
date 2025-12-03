#include "stdio.h"
void main()
{  int x1=3,y1=4,z1,z2;
   int x=0x76543210,y=4,z;
   unsigned int ux=0x76543210,uy=4,uz;
   z1=x1*y1;
   z2=x1*4;
   z=x*y;
   uz=ux*uy;
   printf("z1=%d,z2=%d,z=%d,uz=%u \n",z1,z2,z,uz);
}


