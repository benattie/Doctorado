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
    int i, j, k, bad_fit = 0, zero_peak_index[(*difra).numrings];
    float treshold = 3.0;
    //elimino los picos que tienen una intensidad menor que treshold
    int n_peaks = check_for_null_peaks (treshold, (*difra).numrings, zero_peak_index, intens);
    int seeds_size = 6 * n_peaks + 2, all_seeds_size = 6 * (*difra).numrings + 2;
    int net_size = (*difra).bg_right[(*difra).numrings - 1];
    // seteo el vector con las semillas
    double ** peak_seeds = matrix_double_alloc(2, seeds_size);
    set_seeds(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    //numero de parametros a fitear para cada paso del fiteo 
    int n_param[4] = {4 * n_peaks + 1, 5 * n_peaks, 4 * n_peaks + 2, 6 * n_peaks};
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(net_size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(net_size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(net_size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc(n_peaks, 2); //posicion de los puntos que tomo para calcular el background (en unidades de angulo)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Obteniendo datos\n");
    for(i = 0; i < net_size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, (*sync_data).pixel, (*sync_data).dist));//conversion de bin a coordenada angular
        gsl_vector_set(y, i, (*difra).intensity[i]);
        gsl_vector_set(sigma, i, sqrt((*difra).intensity[i])); //calculo los sigma de las intensidades
    }
    
    j = 0;
    for(i = 0; i < (*difra).numrings; i++)
    {
        if(zero_peak_index[i] == 0)
        {
            gsl_matrix_set(bg_pos, j, 0, bin2theta((*difra).bg_left[i], (*sync_data).pixel, (*sync_data).dist));
            gsl_matrix_set(bg_pos, j, 1, bin2theta((*difra).bg_right[i], (*sync_data).pixel, (*sync_data).dist));
            j++;
        }
    }
    struct data d = {net_size, n_peaks, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Inicio de las iteraciones\n");
    //printf("Paso 1\n");
    //print_seeds(peak_seeds[1], seeds_size);
    pv_step1(exists, peak_seeds, seeds_size, &d, n_param[0]);
    //print_seeds(peak_seeds[1], seeds_size);
    check(peak_seeds, seeds_size);
    //getchar();
    //printf("Paso 2\n");
    //print_seeds(peak_seeds[1], seeds_size);
    pv_step2(exists, peak_seeds, seeds_size, &d, n_param[1]);
    //print_seeds(peak_seeds[1], seeds_size);
    check(peak_seeds, seeds_size);
    //getchar();
    //printf("Paso 3\n");
    //print_seeds(peak_seeds[1], seeds_size);
    pv_step3(exists, peak_seeds, seeds_size,  &d, n_param[2]);
    //print_seeds(peak_seeds[1], seeds_size);
    check(peak_seeds, seeds_size);
    //getchar();
    //printf("Paso 4\n");
    //print_seeds(peak_seeds[1], seeds_size);
    pv_step4(exists, peak_seeds, seeds_size, &d, n_param[3]);
    //print_seeds(peak_seeds[1], seeds_size);
    //getchar();
    //printf("Fin de las iteraciones\n");
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Correccion de los resultados\n");
    j = 2;
    k = 0;
    for(i = 2; i < all_seeds_size; i += 6)
    {
        if(zero_peak_index[k] == 0)
        {
            
            double * H = vector_double_alloc(1);
            double * eta = vector_double_alloc(1);
            double I = peak_seeds[1][j + 1];
            *H = peak_seeds[1][0] + peak_seeds[1][j + 2];
            *eta = peak_seeds[1][1] + peak_seeds[1][j + 3];
            if(I < 0)
            {
                bad_fit = 1;
                (*difra).intens[(*difra).gamma][k] = -1.0;
                (*difra).fwhm[(*difra).gamma][k] = -1.0;
                (*difra).eta[(*difra).gamma][k] = -1.0;
                reset_peak_seeds(peak_seeds, j);
            }
            else
            {
                if(*H < 0 || *H > 1)
                {
                    bad_fit = 1;
                    (*difra).intens[(*difra).gamma][k] = I;
                    (*difra).fwhm[(*difra).gamma][k] = -1.0;
                    (*difra).eta[(*difra).gamma][k] = -1.0;
                    reset_peak_seeds(peak_seeds, j);
                }
                else
                {
                     if(*eta < 0 || *eta > 1)
                    {
                        bad_fit = 1;
                        (*difra).intens[(*difra).gamma][k] = I;
                        (*difra).fwhm[(*difra).gamma][k] = *H;
                        (*difra).eta[(*difra).gamma][k] = -1.0;
                        reset_peak_seeds(peak_seeds, j);
                    }
                    else
                    {
                        //double theta = peak_seeds[1][j] / 2.; //necesito theta y NO 2theta para poder ahcer la correccion por ancho instrumental
                        //ins_correction(H, eta, (*sync_data).ins, theta);
                        (*difra).intens[(*difra).gamma][k] = I;
                        (*difra).fwhm[(*difra).gamma][k] = *H;
                        (*difra).eta[(*difra).gamma][k] = *eta;
                    }
                }
            }
            j += 6;
        }
        else
        {
                (*difra).intens[(*difra).gamma][k] = 0.0;
                (*difra).fwhm[(*difra).gamma][k] = 0.0;
                (*difra).eta[(*difra).gamma][k] = 0.0;
        }
        k++;
    }
    if(bad_fit) check(peak_seeds, seeds_size);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_matrix_free(bg_pos);
    free_double_matrix(peak_seeds, 2);
    //printf("Fin pv_fitting\n");
}
//FIN DE PV_FITTING
