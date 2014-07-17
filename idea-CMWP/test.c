#include "pseudo_voigt.h"
#include "array_alloc.h"
int main()
{
  int i;
  char a[100] = "python hola.py hola";
  i = system(a);
  sprintf(a, "python hola.py mundo");
  i = system(a);
  /*
    int i = 0;
    char a = {'y'};
    if((a == 'y'  || a == 'Y') && i < 0)
        printf("no deberias ver el primer if\n");
    i = -1;
    if((a == 'y'  || a == 'Y') && i < 0)
        printf("si deberias ver el segundo if\n");
    sprintf(&a, "Y");
    if((a == 'y'  || a == 'Y') && i < 0)
        printf("tampoco deberías ver el tercer if\n");
*/

    return 0;
}
