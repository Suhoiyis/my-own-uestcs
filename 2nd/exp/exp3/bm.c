#include "stdio.h"
#include "string.h"
void outputs(char *str)
{
   char buffer[16];
   strcpy(buffer, str);
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
