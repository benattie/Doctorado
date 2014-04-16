#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"

void read_file(FILE * fit_fp, double ** seed)
{
    char buf[250];
    char *token;
    //char *search = "\t ";
    char *search = "\t    ";
    int i = 0;
    fgets(buf, 250, fit_fp);//leo el titulo
    fgets(buf, 250, fit_fp);//"global H"
    fgets(buf, 250, fit_fp);//valor de H
    //leo el valor de H
    token = strtok(buf, search);
    while(token != NULL)
    {
        seed[0][i] = atof(token);
        seed[1][i] = seed[0][i];
        i++;
        token = strtok(NULL, search);
    }
    fgets(buf, 250, fit_fp);//"golbal eta"
    fgets(buf, 250, fit_fp);//valor de eta
    //leo el valor de eta
    token = strtok(buf, search);
    while(token != NULL)
    {
        seed[0][i] = atof(token);
        seed[1][i] = seed[0][i];
        i++;
        token = strtok(NULL, search);
    }
    fgets(buf, 250, fit_fp);//encabezado
    //leo los valores del ajuste con sus errores
    while(fgets(buf, 250, fit_fp) != NULL)
    {
        token = strtok(buf, search);
        while(token != NULL)
        {
            seed[0][i] = atof(token);
            seed[1][i] = seed[0][i];
            i++;
            token = strtok(NULL, search);
        }
    }
}
/*
int main()
{
    FILE * fit_fp;
    int i;
    int size = (2 + 7 * 6);
    double ** seed = matrix_double_alloc(2, size);
    fit_fp = fopen("fit_ini.dat", "r");
    read_file(fit_fp, seed);
    printf("%lf\n", seed[0][0]);
    printf("%lf\n", seed[0][1]);
    for(i = 2; i < size; i += 6)
    {
        printf("%lf\t%lf\t%lf\t%lf\t%lf\t%lf\n", seed[0][i], seed[0][i + 1], seed[0][i + 2], seed[0][i + 3], seed[0][i + 4], seed[0][i + 5]);
    }

    return 0;
}
*/
