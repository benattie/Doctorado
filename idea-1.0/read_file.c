#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"

void read_file(int flag, FILE * fit_fp, double * seed)
{
    char buf[250];
    char *token;
    char *search = "\t ";
    int i = 0;
    if(flag){
        fgets(buf, 250, fit_fp);//leo el chi
        fgets(buf, 250, fit_fp);//global H
        fgets(buf, 250, fit_fp);//valor de H (con error)
        //leo el valor de H y su error
        token = strtok(buf, search);

        while(token != NULL)
        {
            seed[i] = atof(token);
            i++;
            token = strtok(NULL, search);
        }
        fgets(buf, 250, fit_fp);//golbal eta
        fgets(buf, 250, fit_fp);//valor de eta(con error)
        //leo el valor de eta y su error
        token = strtok(buf, search);
        while(token != NULL)
        {
            seed[i] = atof(token);
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
                seed[i] = atof(token);
                i++;
                token = strtok(NULL, search);
            }
        }
    }
    else
    {
        fgets(buf, 250, fit_fp);//leo el titulo
        fgets(buf, 250, fit_fp);//global H
        fgets(buf, 250, fit_fp);//valor de H
        //leo el valor de H
        token = strtok(buf, search);
        while(token != NULL)
        {
            seed[i] = atof(token);
            i++;
            token = strtok(NULL, search);
        }
        fgets(buf, 250, fit_fp);//golbal eta
        fgets(buf, 250, fit_fp);//valor de eta
        //leo el valor de eta
        token = strtok(buf, search);
        while(token != NULL)
        {
            seed[i] = atof(token);
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
                seed[i] = atof(token);
                i++;
                token = strtok(NULL, search);
            }
        }
    }
}
/*
int main()
{
    FILE * fit_fp;
    int i;
    int size = (2 + 7 * 4);
    double * seed = vector_double_alloc(size);
    fit_fp = fopen("fit_ini.dat", "r");
    read_file(0, fit_fp, seed);
    for(i = 0; i < size; i++)
    {
        printf("%lf\n", seed[i]);
    }

    return 0;
}
*/
