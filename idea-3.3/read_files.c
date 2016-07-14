#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"
#include "pseudo_voigt.h"
#include "aux_functions.h"

void read_file(FILE * fit_fp, double ** seed, int seeds_size, double ** bg, int bg_size)
{
    char *getval = malloc(sizeof(char) * (250 + 1));
    int rv = 0;
    char buf[250];
    int i = 0;
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
    getval = fgets(buf, 250, fit_fp);//encabezado
    getval = fgets(buf, 250, fit_fp);//encabezado
    for(i = 0; i < bg_size; i++)
    {
        rv = fscanf(fit_fp, "%lf", &bg[0][i]);
        rv = fscanf(fit_fp, "%lf", &bg[1][i]);
    }
    if(getval == NULL) printf("\nWARNING (fgets): There were problems while reading fit_ini.dat\n");
    if(rv == 0 || rv == EOF) printf("\nWARNING (fscanf): there were problems reading param data in fit_ini.dat (%d)\n", rv);
}

double search_nu(char * buf, char * search)
{
    char *token;
    token = strtok(buf, search);
    token = strtok(NULL, search);
    return atof(token);
}

void read_IRF(FILE * fp, IRF * ins, SAMPLE_INFO *sample)
{ 
    char *getval = malloc(sizeof(char) * (250 + 1));
    int rv = 0;
    char buf[100];

    // Datos del ancho instrumental
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->UG));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->VG));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->WG));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->UL));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->VL));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &(ins->WL));

    // Datos de la forma de la muestra
    // (para las correcciones por espesor de muestra, volumen y absorcion)
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 100, fp);

    getval = fgets(buf, 23, fp);
    rv = fscanf(fp, "%s", sample->shape);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 23, fp);
    rv = fscanf(fp, "%lf", &(sample->lw0));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 23, fp);
    rv = fscanf(fp, "%lf", &(sample->lw90));
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 23, fp);
    rv = fscanf(fp, "%lf", &(sample->mu));
    getval = fgets(buf, 100, fp);


    if(getval == NULL) printf("\nWARNING (fgets): There were problems while reading IRF.dat\n");
    if(rv == 0 || rv == EOF) printf("\nWARNING (fscanf): there were problems reading param data in IRF.dat (%d)\n", rv);
}
/*
int main()
{
    FILE * fit_fp = fopen("IRF.dat", "r");
    IRF ins;
    SAMPLE_INFO sample;
    read_IRF(fit_fp, &ins, &sample);
    printf("%lf  %lf  %lf\n%lf  %lf  %lf\n", ins.UG, ins.VG, ins.WG, ins.UL, ins.VL, ins.WL);
    printf("%s  %lf  %lf %lf\n", sample.shape, sample.lw0, sample.lw90, sample.mu);

    return 0;
}
*/
