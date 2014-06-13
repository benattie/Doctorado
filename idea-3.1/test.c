#include "pseudo_voigt.h"
#include "array_alloc.h"

int periodic_index(int i, int ini, int end)
{
    if(i < ini)
          return end;
      
      if(i > end)
            return ini;
        
        return i;
}

int main()
{
    int i, ini = 4, end = 37;
    for(i=0;i<40;i++)
      printf("i = %d index = %d\n", i, periodic_index(i, ini, end));


    return 0;
}
