#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit_nlin.h>
#include "array_alloc.h"
#include "aux_functions.h"
#include "pv_steps.c"

void pv_fitting(int exists, exp_data * sync_data, peak_data * difra, float * intens, double ** seeds)
{
    //printf("Inicio pv_fitting\n");
    //variables auxiliares del programa
    int i, bad_fit, zero_peak_index[(*difra).numrings];
    //elimino los picos que tienen una intensidad menor que treshold
    int n_peaks = check_for_null_peaks (difra->treshold, (*difra).numrings, zero_peak_index, intens);
    int seeds_size = 4 * n_peaks + 2, all_seeds_size = 4 * (*difra).numrings + 2;
    int net_size = theta2bin((*difra).bg[0][(*difra).n_bg - 1], (*sync_data).pixel, (*sync_data).dist);
    //seteo el vector con las semillas
    double ** peak_seeds = matrix_double_alloc(2, seeds_size), *fit_errors = vector_double_alloc(seeds_size);
    memset(fit_errors, 0, seeds_size * sizeof(double));
    set_seeds(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    //numero de parametros a fitear para cada paso del fiteo 
    int n_param[4] = {2 * n_peaks + 1 + (*difra).n_bg, 3 * n_peaks + (*difra).n_bg, 2 * n_peaks + 2 + (*difra).n_bg, 4 * n_peaks + (*difra).n_bg};
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(net_size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(net_size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(net_size); //error de las intensidades del difractograma
    gsl_vector * bg_pos = gsl_vector_alloc((*difra).n_bg); //error de las intensidades del difractograma

    //printf("Obteniendo datos\n");
    for(i = 0; i < net_size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, (*sync_data).pixel, (*sync_data).dist));//conversion de bin a coordenada angular
        gsl_vector_set(y, i, (*difra).intensity[i]);
        gsl_vector_set(sigma, i, sqrt((*difra).intensity[i])); //calculo los sigma de las intensidades
    }
    for(i = 0; i < (*difra).n_bg; i++)
        gsl_vector_set(bg_pos, i, (*difra).bg[0][i]);
    struct data d = {net_size, n_peaks, (*difra).n_bg, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales
 
    //creacion de un logfile con la entrada y salida de las semillas, asi no deberia tener que sacarlos resultados a pantalla para hacer un control de como va el fiteo
    //OJO sigue mas abajo!!!
    FILE * fp_logfile = fopen("fit_results.log", "a");
    fprintf(fp_logfile, "spr: %d gamma :%d\nsemilla inicial\n", (*difra).spr, (*difra).gamma + 1);
    print_seeds2file(fp_logfile, peak_seeds[exists], fit_errors, seeds_size, (*difra).bg, (*difra).n_bg);
   
    //printf("Inicio de las iteraciones\n");
    //printf("Paso 1\n");
    //print_seeds(peak_seeds[exists], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step1(exists, peak_seeds, seeds_size, (*difra).bg, &d, n_param[0]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
    //printf("Paso 2\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step2(exists, peak_seeds, seeds_size, (*difra).bg, &d, n_param[1]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
    //printf("Paso 3\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step3(exists, peak_seeds, fit_errors, seeds_size, (*difra).bg, &d, n_param[2]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
    //printf("Paso 4\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step4(exists, peak_seeds, fit_errors, seeds_size, (*difra).bg, &d, n_param[3]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    //printf("Fin de las iteraciones\n");

    //imprimo en fp_logfile los resultados de las iteraciones
    fprintf(fp_logfile, "semilla final\n");
    print_seeds2file(fp_logfile, peak_seeds[1], fit_errors, seeds_size, (*difra).bg, (*difra).n_bg);
    fflush(fp_logfile);
    fclose(fp_logfile);
   
    //printf("Correccion y salida de los resultados\n");
    bad_fit = fit_result(all_seeds_size, peak_seeds, fit_errors, zero_peak_index, sync_data, difra);
    if(bad_fit) check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
    set_seeds_back(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    
    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_vector_free(bg_pos);
    free_double_matrix(peak_seeds, 2);
    free(fit_errors);
    //printf("Fin pv_fitting\n");
}
