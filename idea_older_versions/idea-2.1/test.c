#include "pseudo_voigt.h"
#include "array_alloc.h"
int main()
{
    double *** r3 = r3_tensor_double_alloc(2, 2, 2);
    int i, j, k;
    for(i = 0; i < 2; i++)
    {
        for(j = 0; j < 2; j++)
        {
            for(k = 0; k < 2; k++)
            {
                r3[i][j][k] = i + j + k;
            }
        }
    }
    for(i = 0; i < 2; i++)
    {
        for(j = 0; j < 2; j++)
        {
            for(k = 0; k < 2; k++)
            {
                printf("%lf\t", r3[i][j][k]);
            }
            printf("    ");
        }
        printf("\n");
    }
    free_double_r3_tensor(r3, 2, 2);
    return 0;
}
