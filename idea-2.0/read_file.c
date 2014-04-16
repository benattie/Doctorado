#include <stdlib.h>
#include <stdio.h>
//#include <string.h>
#include "array_alloc.h"
void read_file(FILE * fit_fp, double ** seed)
{
    char buf[250];
    int i = 0;
    fgets(buf, 250, fit_fp);//leo el titulo
    fgets(buf, 250, fit_fp);//"global H"
    fscanf(fit_fp,"%lf", &seed[0][i]);//valor de H
    fgets(buf, 250, fit_fp);
    seed[1][i] = seed[0][i];
    i++;
    
    fgets(buf, 250, fit_fp);//"golbal eta"
    fscanf(fit_fp, "%lf", &seed[0][i]);//valor de eta
    seed[1][i] = seed[0][i];
    fgets(buf, 250, fit_fp);
    i++;
    
    fgets(buf, 250, fit_fp);//encabezado
    //leo el resto de los valores a afinar
    while(fscanf(fit_fp, "%lf", &seed[0][i]) != EOF)
    {
        seed[1][i] = seed[0][i];
        i++;
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
    printf("%lf\n", seed[1][0]);
    printf("%lf\n", seed[1][1]);
    for(i = 2; i < size; i += 6)
    {
        printf("%lf\t%lf\t%lf\t%lf\t%lf\t%lf\n", seed[1][i], seed[1][i + 1], seed[1][i + 2], seed[1][i + 3], seed[1][i + 4], seed[1][i + 5]);
    }

    return 0;
}
*/
