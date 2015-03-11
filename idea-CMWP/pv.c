#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit_nlin.h>
#include "array_alloc.h"
#include "aux_functions.h"
#include "pv_steps.c"

void pv_fitting(char basename[1024], int exists, exp_data * sync_data, peak_data * difra, double * intens, double ** seeds)
{
//    printf("Inicio pv_fitting\n");
    // variables auxiliares del programa
    char filename[500];
    FILE *fp;
    int i, n, bad_fit, zero_peak_index[(*difra).numrings];
    //elimino los picos que tienen una intensidad menor que treshold
    int n_peaks = check_for_null_peaks(difra->treshold, (*difra).numrings, zero_peak_index, intens);
    double t0[n_peaks], I0[n_peaks], shift_H[n_peaks], shift_eta[n_peaks];
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

//    printf("Obteniendo datos\n");
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
    char error_filename[1024];
    int rv;
    rv = sprintf(error_filename, "%spvfit_result.log", basename); 
    FILE * fp_logfile = fopen(error_filename, "a");
    fprintf(fp_logfile, "spr: %d gamma :%d\nsemilla inicial\n", (*difra).spr, (*difra).gamma);
    print_seeds2file(fp_logfile, peak_seeds[exists], fit_errors, seeds_size, (*difra).bg, (*difra).n_bg);
   
//    printf("Inicio de las iteraciones\n");
//    printf("Paso 1\n");
    //print_seeds(peak_seeds[exists], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step1(exists, peak_seeds, seeds_size, (*difra).bg, &d, n_param[0]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
//    printf("Paso 2\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step2(exists, peak_seeds, seeds_size, (*difra).bg, &d, n_param[1]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
//    printf("Paso 3\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step3(exists, peak_seeds, fit_errors, seeds_size, (*difra).bg, &d, n_param[2]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
//    printf("Paso 4\n");
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
    pv_step4(exists, peak_seeds, fit_errors, seeds_size, (*difra).bg, &d, n_param[3]);
    //print_seeds(peak_seeds[1], seeds_size, (*difra).bg, (*difra).n_bg);
 //   printf("Fin de las iteraciones\n");

    //imprimo en fp_logfile los resultados de las iteraciones
    fprintf(fp_logfile, "semilla final\n");
    print_seeds2file(fp_logfile, peak_seeds[1], fit_errors, seeds_size, (*difra).bg, (*difra).n_bg);
    fflush(fp_logfile);
    fclose(fp_logfile);
   
//    printf("Correccion y salida de los resultados\n");
    //imprimo el pattern
    sprintf(filename, "%s%sspr_%d_pattern_%d.dat", sync_data->path_out, sync_data->root_name, difra->spr, difra->gamma);
    if((fp = fopen(filename, "w")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", filename);
        exit(1);
    }
    for(i = 0; i < net_size; i++)
        if(gsl_vector_get(y, i))
            fprintf(fp, "%.5lf %.5lf\n", gsl_vector_get(ttheta, i), gsl_vector_get(y, i));
        else
            fprintf(fp, "%.5lf %.5lf\n", gsl_vector_get(ttheta, i), 1.0);

    fflush(fp);
    fclose(fp);
    //imprimo las posiciones de los picos y sus intensidades
    sprintf(filename, "%s%sspr_%d_pattern_%d.peak-index.dat", sync_data->path_out, sync_data->root_name, difra->spr, difra->gamma);
    if((fp = fopen(filename, "w")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", filename);
        exit(1);
    }
    n = 0;
    for(i = 2; i < seeds_size; i += 4)
    {
      t0[n] = peak_seeds[1][i]; 
      I0[n] = peak_seeds[1][i + 1];
      shift_H[n] = peak_seeds[1][i + 2];
      shift_eta[n] = peak_seeds[1][i + 3];
      n++;
    }
    n = 2;
    for(i = 0; i < difra->numrings; i++)
    {
        if(zero_peak_index[i] == 0)
        {
            double theta = peak_seeds[1][n], H = peak_seeds[1][0], eta = peak_seeds[1][1];
            //double I = pseudo_voigt(theta, difra->numrings, I0, t0, H, eta, shift_H, shift_eta, difra->n_bg, bg_pos, difra->bg[1]);
            double I = pseudo_voigt(theta, n_peaks, I0, t0, H, eta, shift_H, shift_eta, difra->n_bg, bg_pos, difra->bg[1]);
            fprintf(fp, "%.5lf %.5lf %d 0\n", peak_seeds[1][n], 0.9 * I, difra->hkl[i]);
            n += 4;
        }
    }    
    fflush(fp);
    fclose(fp);
    //imprimo las posiciones y las intensidades de los puntos de background
    sprintf(filename, "%s%sspr_%d_pattern_%d.bg-spline.dat", sync_data->path_out, sync_data->root_name, difra->spr, difra->gamma);
    if((fp = fopen(filename, "w")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", filename);
        exit(1);
    }
    for(i = 0; i < difra->n_bg; i++)
      fprintf(fp, "%.5lf %.5lf\n", difra->bg[0][i], difra->bg[1][i]);
    fflush(fp);
    fclose(fp);
    //se puede analizar la posibilidad de usar una cubic spline en vez de una lineal para este programa
    //ya que el propio cmwp va a usar una cubic spline
    bad_fit = fit_result(all_seeds_size, peak_seeds, fit_errors, zero_peak_index, sync_data, difra);
    if(bad_fit) check(y, peak_seeds, seeds_size, n_peaks, (*difra).bg, (*difra).n_bg);
    set_seeds_back(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    
    //liberacion de memoria allocada
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_vector_free(bg_pos);
    free_double_matrix(peak_seeds, 2);
    free(fit_errors);
//    printf("Fin pv_fitting\n");
}
