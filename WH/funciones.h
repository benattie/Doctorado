#ifndef WH_H_   /* Include guard */
#define WH_H_
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
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

void read_input(FILE *fp, file_data *fdata, crystal_data *cdata, aux_data *adata);

#endif
