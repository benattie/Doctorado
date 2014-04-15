#ifndef AUX_FUNCT_H_   /* Include guard */
#define AUX_FUNCT_H_

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include <gsl/gsl_vector.h>
#include <gsl/gsl_multifit_nlin.h>

#include "array_alloc.h"
#include "pseudo_voigt.h"


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
    int spr;
    int gamma;
    float * intensity;
    int * bg_left;
    int * bg_right;
    double ** intens;
    double ** fwhm;
    double ** eta;
} peak_data;

//datos basicos del fiteo
struct data 
{
    int n;
    int numrings;
    gsl_vector * ttheta;
    gsl_vector * y;
    gsl_vector * sigma;
    gsl_matrix * bg_pos;
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

double bin2theta(int bin, double pixel, double dist);
int theta2bin(double theta, double pixel, double dist);
void print_state (int iter, gsl_multifit_fdfsolver * s);

void print_seeds(double *seeds, int size);
void reset_all_seeds(double ** seeds, int size);
//reseteo todas las semillas menos la posicion del pico
void reset_almost_all_seeds(double ** seeds, int size);
void reset_peak_seeds(double ** seeds, int index);
void reset_global_seeds(double ** seeds);
void reset_single_seed(double ** seeds, int index);
void check (double ** seeds, int size);

int check_for_null_peaks (float treshold, int numrings, int * zero_peak_index, float * intens);
void set_seeds(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds);
//void set_bg_pos(int n_peaks,int * zero_peak_index, int * bg_left, int * bg_right, int ** peak_bg);
void reset_seeds(int size, double * peak_seeds, int * zero_peak_index, double ** seeds);
void average(float * intens_av, float * peak_intens_av, int n_av, int size, int numrings);

#endif
