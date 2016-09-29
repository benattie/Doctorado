#ifndef AUX_FUNCT_H_   /* Include guard */
#define AUX_FUNCT_H_
//librerias necesarias
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_multifit_nlin.h>

#include "array_alloc.h"
#include "pseudo_voigt.h"

//definiciones importantes
#define pi 3.141592654

//DEFINICION DE ESTRUCTURAS
//datos del equipo
typedef struct exp_data
{
    char *path_out;
    char *root_name;
    double dist;
    double pixel;
    int size;
} exp_data;
//estructura con los errores de los fiteos
typedef struct err_fit_data
{
    double *** intens_err;
    double *** fwhm_err;
    double *** eta_err;
} err_fit_data;
//parametros que definen la forma del pico
typedef struct peak_shape_data
{
    double *** fwhm;
    double *** eta;
} peak_shape_data;

//datos del difractorgrama
typedef struct peak_data
{
    int numrings;
    int n_bg;
    int spr;
    int start_spr;
    int gamma;
    int start_gam;
    double treshold;
    int *ph;
    int *hkl;
    double *dostheta;
    double * intensity;
    double ** bg;
    double *** intens;
    peak_shape_data * shapes;
    err_fit_data * errors;
} peak_data;


//datos basicos del fiteo
struct data 
{
    int n;
    int numrings;
    int n_bg;
    gsl_vector * ttheta;
    gsl_vector * y;
    gsl_vector * sigma;
    gsl_vector * bg_pos;
};

//datos adicionales necesarios para cada paso del fiteo
typedef struct data_s1 
{
    struct data d;
    double eta;
    double * shift_H;
    double * shift_eta;
} data_s1;

typedef struct data_s2 
{
    struct data d;
    double H;
    double eta;  
    double * shift_eta;
} data_s2;

typedef struct data_s3 
{
    struct data d;
    double * shift_H;
    double * shift_eta;
} data_s3;

typedef struct data_s4 
{
    struct data d;
    double H;
    double eta;
} data_s4;
//DEFINICION DE FUNCIONES
double winkel_al(double th, double om, double ga);

double winkel_be(double thb, double omb, double gab, double alb);

double bin2theta(int bin, double pixel, double dist);

int theta2bin(double theta, double pixel, double dist);

void print_state (int iter, gsl_multifit_fdfsolver * s);

void print_seeds(double * seeds, int seeds_size, double ** bg, int bg_size);

void print_seeds2file(FILE * fp, double * seeds, double * errors, int seeds_size, double ** bg, int bg_size);

void reset_single_seed(double ** seeds, int index);

void reset_global_seeds(double ** seeds);

void reset_peak_seeds(double ** seeds, int peak_index);

void reset_bg_seeds(gsl_vector * y, double ** bg, int size);

void reset_all_seeds(gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size);

void check(gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size);

int check_for_null_peaks(double treshold, int numrings, int * zero_peak_index, double * intens);

void set_seeds(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds);

void set_seeds_back(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds);

void average(int ** data, double ** intens, int gamma, int n_av, int size, int numrings, double * av_pattern, double * av_intensity);

void solver_iterator(int * status, gsl_multifit_fdfsolver * s, const gsl_multifit_fdfsolver_type * T);

int fit_result(int all_seeds_size, double ** peak_seeds, double * errors, int * zero_peak_index, exp_data * sync_data, peak_data * difra);

int results_output(int all_seeds_size, double ** peak_seeds, double * errors, int * zero_peak_index, exp_data * sync_data, peak_data * difra, int spr, int gamma);

void smooth(double *** v, int i, int j, int k, int start_i,  int di, int end_i, int start_j, int dj, int end_j);

int periodic_index(int i, int ini, int end);

void print_double_vector(double * v, int size);
#endif
