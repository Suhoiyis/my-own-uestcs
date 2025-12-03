#include "stdio.h"
void main()
{
  int a, b, c;
  scanf("%d %d", &a, &b);
  if (a>0 && b>0)
    c=a+b;
  else
    c=a-b;
  printf("c=%d\n", c);
}
