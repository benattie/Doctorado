#ifndef WH_H_   /* Include guard */
#define WH_H_
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_fit.h>
#include <gsl/gsl_statistics_double.h>
#include <gsl/gsl_sort_int.h>
#include <gsl/gsl_sort_vector_int.h>
#include "array_alloc.h"

//estructuras de datos
typedef struct file_data
{
    char outPath[500];
    char inputPath[500];
    char filename[500];
    char fileext[500];
    int start;
    int end;
    char is_corr[3];
    char is_H[10];
    int model;
} file_data;

typedef struct crystal_data
{
    char type[10];
    double a;
    double burgersv;
    int npeaks;
    int ** indices;
    double * H2;
    double * warrenc;
} crystal_data;

typedef struct aux_data
{
    double lambda;
    double delta_min;
    double delta_step;
    double delta_max;
    double q_min;
    double q_step;
    double q_max;
    double Ch00_min;
    double Ch00_step;
    double Ch00_max;
} aux_data;

typedef struct shape_params
{
    double **FWHM;
    double **FWHM_err;
    double **breadth;
    double **breadth_err;
    double **FWHM_corr;
    double **FWHM_corr_err;
    double **breadth_corr;
    double **breadth_corr_err;
} shape_params;

typedef struct angles_grad
{
    double **theta_grad;
    double **dostheta_grad;
    double **alpha_grad;
    double **beta_grad;
} angles_grad;

typedef struct linear_fit
{
    int n_out_params;
    double m;
    double h;
    double *x;
    double *y;
    double *y_err;
    double R;
    double chisq;
    double **covar;
} linear_fit;

typedef struct best_values
{
    double R_max;
    double ** best_R_values;
    double chisq_min;
    double ** best_chisq_values;
} best_values;

//funciones
double warren_constants(char * type, int * hkl);

double WC_FCC(int *hkl);

int count_zeros(int * v, int size);

int count_equal(int * v);

double H2(int * hkl);

double burgers(double a, int * hkl);

double Chkl(double Ch00, double q, int * hkl);

void printf_filedata(file_data *fdata);

void printf_crystaldata(crystal_data *cdata);

void printf_auxdata(aux_data *adata);

void print_xy(double * x, double * y, double * y_err, int size);

void print_stats(linear_fit * fit_data, int xsize);

void read_input(FILE *fp, file_data *fdata, crystal_data *cdata, aux_data *adata);

int read_pole_figures(file_data * fdata, angles_grad * angles, shape_params * widths);

void print_results(file_data * fdata, FILE * fp, double ** fit_results, linear_fit * fit_data, int nlines, angles_grad * angles, crystal_data * cdata);

#endif
