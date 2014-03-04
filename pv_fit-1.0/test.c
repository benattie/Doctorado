#include <stdlib.h>
#include <stdio.h>
//FUNCION BACKGROUND (INTERPOLACION LINEAL)
int main()
{
    int i;
    for(i = 0; i < 10; i++)
    {
	printf("%d\n", i);
	if(i == 5)
	{
	    printf("Terminó donde debía\n");
	    return 0;
	}
    }
    printf("Terminó donde NO debía\n");
    return 1;
}
