#ifndef WH_H_   /* Include guard */
#define WH_H_
//librerias necesarias
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_fit.h>

//estructura de datos
typedef struct crystal_data
{
    char * type;
    double a;
    double burgersv;
    int npeaks;
    int ** indices;
    double * H2;
    double * warrenc;
} crystal_data;

typedef struct difraction_data
{
    double * dostheta;
    double * FWHM;
    double * breadth;
    double lambda;
} difraction_data;

//funciones

#endif
