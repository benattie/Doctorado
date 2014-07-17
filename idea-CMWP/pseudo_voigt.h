#ifndef PSEUDO_VOIGT_H_   /* Include guard */
#define PSEUDO_VOIGT_H_

#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_randist.h>

#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal

//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_vector * bg_pos, double * bg_int);
//PSEUDO-VOIGT NORMALIZADA (EN AREA)
double pseudo_voigt_n(double x, double x0, double eta, double H);
//FUNCION PSEUDO-VOIGT
double pseudo_voigt(double ttheta, int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], int n_bg, gsl_vector * bg_pos, double * bg_int);

#endif
