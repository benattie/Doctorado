#ifndef AUX_FUNCT_H_   /* Include guard */
#define AUX_FUNCT_H_
//librerias necesarias
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

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
    double dist;
    double pixel;
    int size;
    IRF ins;
} exp_data;
//datos del difractorgrama
typedef struct peak_data
{
    int numrings;
    int n_bg;
    int spr;
    int gamma;
    float * intensity;
    double ** bg;
    double ** intens;
    double ** fwhm;
    double ** eta;
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
float winkel_al(float th, float om, float ga);

float winkel_be(float thb, float omb, float gab, float alb);

double bin2theta(int bin, double pixel, double dist);

int theta2bin(double theta, double pixel, double dist);

void print_state (int iter, gsl_multifit_fdfsolver * s);

void print_seeds(double * seeds, int seeds_size, double ** bg, int bg_size);

void reset_single_seed(double ** seeds, int index);

void reset_global_seeds(double ** seeds);

void reset_peak_seeds(double ** seeds, int peak_index);

void reset_bg_seeds(gsl_vector * y, double ** bg, int size);

void reset_all_seeds(gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size);

void check (gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size);

int check_for_null_peaks (float treshold, int numrings, int * zero_peak_index, float * intens);

void set_seeds(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds);

//void reset_seeds(int size, double * peak_seeds, int * zero_peak_index, double ** seeds);

void average(float * intens_av, float * peak_intens_av, int n_av, int size, int numrings);

void solver_iterator(int * status, gsl_multifit_fdfsolver * s, const gsl_multifit_fdfsolver_type * T);

int results_print(int all_seeds_size, double ** peak_seeds, int * zero_peak_index, exp_data * sync_data, peak_data * difra);
#endif
