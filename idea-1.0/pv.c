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
#include "aux_functions.h"
#include "pv_steps.c"

//INICIO DEL MAIN
void pv_fitting(int exists, exp_data * sync_data, peak_data * difra, float * intens, double ** seeds)
{
    //printf("Inicio pv_fitting\n");
    //DECLARACION DE VARIABLES Y ALLOCACION DE MEMORIA
    //variables auxiliares del programa
    int i, j;
    float treshold = 3.0;
    int zero_peak_index[(*difra).numrings];
    //elimino los picos que tienen una intensidad menor que treshold
    int n_peaks = check_for_null_peaks (treshold, (*difra).numrings, zero_peak_index, intens);
    int seeds_size = 6 * n_peaks + 2;
    // seteo el vector con las semillas
    double ** peak_seeds = matrix_double_alloc(2, seeds_size);
    int ** peak_bg = matrix_int_alloc(2, n_peaks);
    set_seeds(6 * (*difra).numrings + 2, zero_peak_index, seeds, peak_seeds);
    set_bg_pos(6 * (*difra).numrings + 2, zero_peak_index, (*difra).bg_left, (*difra).bg_right, peak_bg);
    //numero de parametros a fitear para cada paso del fiteo 
    int n_param[4] = {4 * n_peaks + 1, 5 * n_peaks + 1, 5 * n_peaks + 2, 6 * n_peaks + 1};

    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc((*sync_data).size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc((*sync_data).size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc((*sync_data).size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (n_peaks, 2); //posicion de los puntos que tomo para calcular el background (en unidades de angulo)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //obtengo los datos
    //printf("Obteniendo datos\n");
    (*sync_data).size = peak_bg[1][n_peaks - 1];//leo hasta el ultimo punto de background
    for(i = 0; i < (*sync_data).size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, (*sync_data).pixel, (*sync_data).dist));//conversion de bin a coordenada angular
        gsl_vector_set(y, i, (*difra).intensity[i]);//tal vez haya que promediar los datos
        gsl_vector_set(sigma, i, sqrt((*difra).intensity[i])); //calculo los sigma de las intensidades
    }

    for(i = 0; i < n_peaks; i++)
    {
        printf("%d\t%d\n--\n", peak_bg[0][i], peak_bg[1][i]);
        gsl_matrix_set(bg_pos, i, 0, bin2theta(peak_bg[0][i], (*sync_data).pixel, (*sync_data).dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(peak_bg[1][i], (*sync_data).pixel, (*sync_data).dist)); //bin del punto definido bg_right
        printf("%lf\t%lf", gsl_matrix_get(bg_pos, i, 0), gsl_matrix_get(bg_pos, i, 1));
    }
/*
    struct data d = {(*sync_data).size, (*difra).numrings, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Fiteo
    //printf("Inicio de las iteraciones\n");
    //printf("Paso 1\n");
    pv_step1(exists, sync_data, difra, seeds, &d, n_param[0]);
    check(seeds, seeds_size);
    //printf("Paso 2\n");
    pv_step2(exists, sync_data, difra, seeds, &d, n_param[1]);
    check(seeds, seeds_size);
    //printf("Paso 3\n");
    pv_step3(exists, sync_data, difra, seeds, &d, n_param[2]);
    check(seeds, seeds_size);
    //printf("Paso 4\n");
    pv_step4(exists, sync_data, difra, seeds, &d, n_param[3]);
    //printf("Fin de las iteraciones\n");
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Correccion de los resultados\n");
    //Escritura de los resultados del fiteo en los vectores fwhm y eta
    //correccion de los anchos obtenidos del fiteo y escritura a los punteros de salida (fwhm y eta)
    j = 0;
    int bad_fit = 0;
    //FILE *fp_bflog = fopen("logfile.txt", "a");
    //faltan los encabezados de fp_bflog
    for(i = 2; i < seeds_size; i += 6)
    {
        double * H_corr = vector_double_alloc(1);
        double * eta_corr = vector_double_alloc(1);
        double I = seeds[1][i + 1];
        *H_corr = seeds[1][0] + seeds[1][i + 2];
        *eta_corr = seeds[1][1] + seeds[1][i + 3];
        if(I < 0 || *H_corr < 0 || *H_corr > 1 || *eta_corr < 0 || *eta_corr > 1)
        {
            (*difra).fwhm[(*difra).gamma][j] = -1.0;
            (*difra).eta[(*difra).gamma][j] = -1.0;            
            reset_peak_seeds(seeds, i);
            //fprintf(fp_bflog, "%3d    %5d    %4d    %5.3lf    %8.3lf    %8.5lf    %8.5lf\n", spr, gamma, (i + 4) / 6, err_rel, I, H_corr[0], eta_corr[0]);
            bad_fit = 1;
        }
        else
        {   
            //double theta = seeds[1][i];
            //ins_correction(H_corr, eta_corr, (*sync_data).ins, theta);
            (*difra).fwhm[(*difra).gamma][j] = *H_corr;
            (*difra).eta[(*difra).gamma][j] = *eta_corr;
        }
        j++;
    }
    if(bad_fit) check(seeds, seeds_size);
    //if(bad_fit) reset_all_seeds(seeds, size);
    //fclose(fp_bflog);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_matrix_free(bg_pos);
    free_double_matrix(peak_seeds, 2);

    //printf("\nGod's in his heaven\nAll fine with the world\n");
    if((((*difra).gamma - 1) % 30) == 0) printf("\nFin (%d %d)\n", (*difra).spr, (*difra).gamma);//imprimo progreso
    //return 0;
    */
}
//FIN DEL MAIN
