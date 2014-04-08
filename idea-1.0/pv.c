//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting

//COSAS MIAS
#include "array_alloc.h"
#include "pv_steps.c"

//FUNCIONES
double bin2theta(int bin, double pixel, double dist);
int theta2bin(double theta, double pixel, double dist);
void reset_all_seeds(double ** seeds, int size);
void reset_peak_seeds(double ** seeds, int index);


//INICIO DEL MAIN
void pv_fitting(int exists, exp_data * sync_data, peak_data * difra, double ** seeds)
{
    //printf("Inicio pv_fitting\n");
    //DECLARACION DE VARIABLES Y ALLOCACION DE MEMORIA
    //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)    
    int n_param[4] = {4 * (*difra).numrings + 1, 5 * (*difra).numrings + 1, 5 * (*difra).numrings + 2, 6 * (*difra).numrings + 1};
    //variables auxiliares del programa
    int i = 0, j = 0;
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc((*sync_data).size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc((*sync_data).size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc((*sync_data).size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc ((*difra).numrings, 2); //posicion de los puntos que tomo para calcular el background (en unidades de angulo)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //obtengo los datos
    //printf("Obteniendo datos\n");
    (*sync_data).size = (*difra).bg_right[(*difra).numrings - 1];//leo hasta el ultimo punto de background
    for(i = 0; i < (*sync_data).size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, (*sync_data).pixel, (*sync_data).dist));//conversion de bin a coordenada angular
        gsl_vector_set(y, i, (*difra).intensity[i]);//tal vez haya que promediar los datos
        gsl_vector_set(sigma, i, sqrt((*difra).intensity[i])); //calculo los sigma de las intensidades
    }

    for(i = 0; i < (*difra).numrings; i++)
    {
        gsl_matrix_set(bg_pos, i, 0, bin2theta((*difra).bg_left[i], (*sync_data).pixel, (*sync_data).dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta((*difra).bg_right[i], (*sync_data).pixel, (*sync_data).dist)); //bin del punto definido bg_right
    }

    struct data d = {(*sync_data).size, (*difra).numrings, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Fiteo
    //printf("Inicio de las iteraciones\n");
    //printf("Paso 1\n");
    pv_step1(exists, sync_data, difra, seeds, &d, n_param[0]);
    //printf("Paso 2\n");
    pv_step2(exists, sync_data, difra, seeds, &d, n_param[1]);
    //printf("Paso 3\n");
    pv_step3(exists, sync_data, difra, seeds, &d, n_param[2]);
    //printf("Paso 4\n");
    pv_step4(exists, sync_data, difra, seeds, &d, n_param[3]);
    //printf("Fin de las iteraciones\n");
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Correccion de los resultados\n");
    //Escritura de los resultados del fiteo en los vectores fwhm y eta
    //correccion de los anchos obtenidos del fiteo y escritura a los punteros de salida (fwhm y eta)
    j = 0;
    //int bad_fit = 0;
    //FILE *fp_bflog = fopen("logfile.txt", "a");
    for(i = 2; i < 6 * (*difra).numrings + 2; i += 6)
    {
        double * H_corr = vector_double_alloc(1);
        double * eta_corr = vector_double_alloc(1);
        double I = seeds[1][i + 1];
        *H_corr = seeds[1][0] + seeds[1][i + 2];
        *eta_corr = seeds[1][1] + seeds[1][i + 3];
        if(I < 0 || *H_corr < 0 || *H_corr > 1 || *eta_corr < 0 || *eta_corr > 1)
        {
            //fprintf(fp_bflog, "%3d    %5d    %4d    %5.3lf    %8.3lf    %8.5lf    %8.5lf\n", spr, gamma, (i + 4) / 6, err_rel, I, H_corr[0], eta_corr[0]);
            (*difra).fwhm[(*difra).gamma][j] = -1.0;
            (*difra).eta[(*difra).gamma][j] = -1.0;
            //bad_fit = 1;
            reset_peak_seeds(seeds, i);
        }
        else
        {   
            double theta = seeds[1][i];
            ins_correction(H_corr, eta_corr, (*sync_data).ins, theta);
            (*difra).fwhm[(*difra).gamma][j] = *H_corr;
            (*difra).eta[(*difra).gamma][j] = *eta_corr;
        }
        j++;
    }
    //if(bad_fit) reset_all_seeds(seeds, 6 * (*difra).numrings + 2);
    //fclose(fp_bflog);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_matrix_free(bg_pos);

    //printf("\nGod's in his heaven\nAll fine with the world\n");
    if((((*difra).gamma - 1) % 30) == 0) printf("\nFin (%d %d)\n", (*difra).spr, (*difra).gamma);//imprimo progreso
    //return 0;
}
//FIN DEL MAIN

//FUNCIONES AUXILIARES
double bin2theta(int bin, double pixel, double dist)
{
    return atan((double) bin * pixel / dist) * 180. / M_PI;
}

int theta2bin(double theta, double pixel, double dist)
{
    double aux = dist / pixel * tan(theta * M_PI / 180.);
    return (int) aux;
}

void reset_all_seeds(double ** seeds, int size)
{
    int i;
    for(i = 0; i < size; i++)
        seeds[1][i] = seeds[0][i];
}

void reset_peak_seeds(double ** seeds, int index)
{
    int i;
    for(i = index; i < index + 4; i++)
        seeds[1][i] = seeds[0][i];
}
