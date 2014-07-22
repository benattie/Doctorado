#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"
#include "pseudo_voigt.h"

void read_file(FILE * fit_fp, double ** seed, int seeds_size)
{
    char buf[250], *getval = malloc(sizeof(char) * (250 + 1));
    int i = 0, rv;
    getval = fgets(buf, 250, fit_fp);//"global H"
    rv = fscanf(fit_fp,"%lf", &seed[0][i]);//valor de H
    getval = fgets(buf, 250, fit_fp);
    seed[1][i] = seed[0][i];
    i++;
    
    getval = fgets(buf, 250, fit_fp);//"golbal eta"
    rv = fscanf(fit_fp, "%lf", &seed[0][i]);//valor de eta
    seed[1][i] = seed[0][i];
    getval = fgets(buf, 250, fit_fp);
    i++;
    getval = fgets(buf, 250, fit_fp);//encabezado
    //leo el resto de los valores a afinar
    while(i < seeds_size)
    {
        rv = fscanf(fit_fp, "%lf", &seed[0][i]);
        seed[1][i] = seed[0][i];
        i++;
    }
    if(rv == 0 || rv == EOF) printf("\nWARNING: there were problems reading input file (fscanf) %d\n", rv);
    if(getval == NULL) printf("\nWARNING: there were problems reading input file (fgets)\n");

}
