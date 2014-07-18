#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"
#include "pseudo_voigt.h"

void read_file(FILE * fit_fp, double ** seed, int seeds_size)
{
    char buf[250];
    int i = 0;
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
    while(i < seeds_size)
    {
        fscanf(fit_fp, "%lf", &seed[0][i]);
        seed[1][i] = seed[0][i];
        i++;
    }
}
