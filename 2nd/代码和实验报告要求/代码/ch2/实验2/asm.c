#include "stdio.h"
void main()
{ int x=2,y=3,z=4;
 asm (   "ld.w $r12,$r22,-20\n\t"
	     "ld.w $r13,$r22,-24\n\t"
         "st.w $r12,$r22, -24\n\t"
	     "st.w $r13,$r22,-20\n\t"
        "add.w $r12,$r13,$r12\n\t"
        "st.w $r12,$r22,-28\n\t"	 
         );
  printf("x=%d,y=%d,z=%d\n",x,y,z);
}
