#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "array_alloc.h"
#include "pseudo_voigt.h"

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

IRF read_IRF(FILE * fp)
{ 
    char *getval = malloc(sizeof(char) * (250 + 1));
    int rv = 0;
    char buf[100];
    IRF ins;

    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.UG);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.VG);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.WG);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.UL);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.VL);
    getval = fgets(buf, 100, fp);
    getval = fgets(buf, 4, fp);
    rv = fscanf(fp, "%lf", &ins.WL);
    if(getval == NULL) printf("\nWARNING (fgets): There were problems while reading IRF.dat\n");
    if(rv == 0 || rv == EOF) printf("\nWARNING (fscanf): there were problems reading param data in IRF.dat (%d)\n", rv);

    return ins;
}
/*
int main()
{
    FILE * fit_fp = fopen("IRF.dat", "r");
    IRF ins = read_IRF(fit_fp);
    printf("%lf  %lf  %lf  %lf\n%lf  %lf  %lf  %lf\n", ins.UG, ins.VG, ins.WG, ins.IG, ins.UL, ins.VL, ins.WL, ins.IL);
//
    char buf[250];
    int i, seeds_size, bg_size, n_peaks;
    double ** seed, ** bg_seed; 
    fit_fp = fopen("fit_ini_2.dat", "r");
    fgets(buf, 250, fit_fp);//leo el titulo
    fgets(buf, 250, fit_fp);//leo el encabezado
    fscanf(fit_fp, "%d", &n_peaks);
    fscanf(fit_fp, "%d", &bg_size);
    seeds_size = 4 * n_peaks + 2;
    seed = matrix_double_alloc(2, seeds_size);
    bg_seed = matrix_double_alloc(2, bg_size);
    fgets(buf, 250, fit_fp);//skip line
    read_file(fit_fp, seed, seeds_size, bg_seed, bg_size);
    printf("%lf\n", seed[0][0]);
    printf("%lf\n", seed[0][1]);
    for(i = 2; i < seeds_size; i += 4)
        printf("%lf\t%lf\t%lf\t%lf\n", seed[0][i], seed[0][i + 1], seed[0][i + 2], seed[0][i + 3]);
    
    for(i = 0; i < bg_size; i++)
        printf("%lf\t%lf\n", bg_seed[0][i], bg_seed[1][i]);
    
    printf("%lf\n", seed[1][0]);
    printf("%lf\n", seed[1][1]);
    for(i = 2; i < seeds_size; i += 4)
        printf("%lf\t%lf\t%lf\t%lf\n", seed[1][i], seed[1][i + 1], seed[1][i + 2], seed[1][i + 3]);
   
    free_double_matrix(seed, 2);
    free_double_matrix(bg_seed, 2);
    fclose(fit_fp);

    return 0;
}
*/
