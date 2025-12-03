#include "stdio.h"
void main( )
{    int           a=100,  b=2147483647, c, d;
     unsigned int ua=100, ub=2147483647,uc,ud; 
     c=a+b;   uc=ua+ub;
     d=a-b;    ud=ua-ub;
     printf("c=a+b=%d+%d=%d\n",a,b,c);
     printf("uc=ua+ub=%u+%u=%u\n",ua,ub,uc);  
     printf("d=a-b=%d-%d=%d\n",a,b,d);
     printf("ud=ua-ub=%u-%u=%u\n",ua,ub,ud);
}



