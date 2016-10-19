#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit_nlin.h>
#include "array_alloc.h"
#include "aux_functions.h"
#include "pv_steps.c"
#include <time.h>

void pv_fitting(int exists, exp_data * sync_data, peak_data * difra, double * intens, double ** seeds)
{
    //printf("pv_fitting start\n");
    //auxiliary variables
    int i, j, bad_fit, zero_peak_index[difra->numrings];
    // Remove peaks with intensity below the treshold
    int n_peaks = check_for_null_peaks(difra->treshold, difra->numrings, zero_peak_index, intens);
    int seeds_size = 4 * n_peaks + 2, all_seeds_size = 4 * difra->numrings + 2;
    int ptrn_start = theta2bin(difra->bg[0][0], sync_data->pixel, sync_data->dist);
    int ptrn_end = theta2bin(difra->bg[0][difra->n_bg - 1], sync_data->pixel, sync_data->dist);
    int net_size = ptrn_end - ptrn_start;
    // Set the vector with the seeds for the fitting
    double ** peak_seeds = matrix_double_alloc(2, seeds_size), *fit_errors = vector_double_alloc(seeds_size);
    memset(fit_errors, 0, seeds_size * sizeof(double));
    set_seeds(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    // Number of parameters to fit
    int n_param[4] = {2 * n_peaks + 1 + difra->n_bg, 3 * n_peaks + difra->n_bg, 2 * n_peaks + 2 + difra->n_bg, 4 * n_peaks + difra->n_bg};
    // Fixed parameters
    gsl_vector * ttheta = gsl_vector_alloc(net_size); // 2theta
    gsl_vector * y = gsl_vector_alloc(net_size); // counts of the pattern
    gsl_vector * sigma = gsl_vector_alloc(net_size); // count error
    gsl_vector * bg_pos = gsl_vector_alloc(difra->n_bg); // background points

    //printf("Getting data\n");
    j = 0;
    for(i = ptrn_start; i < ptrn_end; i++){        
        gsl_vector_set(ttheta, j, bin2theta(i, sync_data->pixel, sync_data->dist));// convert from bin to 2theta
        gsl_vector_set(y, j, difra->intensity[i]); // set inensities
        gsl_vector_set(sigma, j, sqrt(difra->intensity[i])); // the error of the intensities is the square root
        j++;
    }
    for(i = 0; i < difra->n_bg; i++)
        gsl_vector_set(bg_pos, i, difra->bg[0][i]);
    struct data d = {net_size, n_peaks, difra->n_bg, ttheta, y, sigma, bg_pos}; // structure with the experimental data
 
    // Logfile with the input and output seeds
    char fitlogname[1024];
    sprintf(fitlogname, "%sfit_results.log", sync_data->root_name);
    FILE * fp_logfile = fopen(fitlogname, "a");
    fprintf(fp_logfile, "spr: %d gamma: %d (p%d)\nStarting values\n", difra->spr, difra->gamma, difra->npattern);
    print_seeds2file(fp_logfile, peak_seeds[exists], fit_errors, seeds_size, difra->bg, difra->n_bg);
    //printf("Start interations\n");
    //printf("Step 1\n");
    //print_seeds(peak_seeds[exists], seeds_size, difra->bg, difra->n_bg);
    pv_step1(exists, peak_seeds, seeds_size, difra->bg, &d, n_param[0]);
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, difra->bg, difra->n_bg);
    //printf("Step 2\n");
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    pv_step2(exists, peak_seeds, seeds_size, difra->bg, &d, n_param[1]);
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, difra->bg, difra->n_bg);
    //printf("Step 3\n");
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    pv_step3(exists, peak_seeds, fit_errors, seeds_size, difra->bg, &d, n_param[2]);
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    check(y, peak_seeds, seeds_size, n_peaks, difra->bg, difra->n_bg);
    //printf("Step 4\n");
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    pv_step4(exists, peak_seeds, fit_errors, seeds_size, difra->bg, &d, n_param[3]);
    //print_seeds(peak_seeds[1], seeds_size, difra->bg, difra->n_bg);
    //printf("End of iterations\n");

    //Print the result of the fitting in fp_logfile
    fprintf(fp_logfile, "Final values\n");
    print_seeds2file(fp_logfile, peak_seeds[1], fit_errors, seeds_size, difra->bg, difra->n_bg);
    fflush(fp_logfile);
    fclose(fp_logfile);
   
    //printf("Print the fitted pattern\n");
    if(strcmp(sync_data->printdata, "y") == 0 || strcmp(sync_data->printdata, "Y") == 0){
        char filename[256];
        FILE *fp;
        int n;
        double t0[n_peaks], I0[n_peaks], shift_H[n_peaks], shift_eta[n_peaks];
    
        sprintf(filename, "%sfitted_pattern/%sspr_%d_pattern_%d.dat", sync_data->path_out, sync_data->root_name, difra->spr, difra->gamma);
        if((fp = fopen(filename, "w")) == NULL){
            fprintf(stderr, "Error opening file %s\n", filename); exit(1);
        }

        n = 0;
        for(i = 2; i < seeds_size; i += 4){
          t0[n] = peak_seeds[1][i]; 
          I0[n] = peak_seeds[1][i + 1];
          shift_H[n] = peak_seeds[1][i + 2];
          shift_eta[n] = peak_seeds[1][i + 3];
          n++;
        }
        double H, eta, I;
        for(i = 0; i < net_size; i++){
            if(gsl_vector_get(y, i)){
                H = peak_seeds[1][0], eta = peak_seeds[1][1];
                I = pseudo_voigt(gsl_vector_get(ttheta, i), n_peaks, I0, t0, H, eta, shift_H, shift_eta, difra->n_bg, bg_pos, difra->bg[1]);
                fprintf(fp, "%.5lf %.5lf %.5lf\n", gsl_vector_get(ttheta, i), gsl_vector_get(y, i), I);
            }else{
                H = peak_seeds[1][0], eta = peak_seeds[1][1];
                I = pseudo_voigt(gsl_vector_get(ttheta, i), n_peaks, I0, t0, H, eta, shift_H, shift_eta, difra->n_bg, bg_pos, difra->bg[1]);
                fprintf(fp, "%.5lf %.5lf %.5lf\n", gsl_vector_get(ttheta, i), 1.0, I);
            }
        }
        fflush(fp);
        fclose(fp);
    }

    //printf("Correction and output of the results\n");
    bad_fit = fit_result(all_seeds_size, peak_seeds, fit_errors, zero_peak_index, sync_data, difra);
    if(bad_fit) 
        check(y, peak_seeds, seeds_size, n_peaks, difra->bg, difra->n_bg);
    set_seeds_back(all_seeds_size, zero_peak_index, exists, seeds, peak_seeds);
    
    //Free allocated memory and close files
    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_vector_free(bg_pos);
    free_double_matrix(peak_seeds, 2);
    free(fit_errors);
    //printf("pv_fitting end\n");
}
