#ifndef PSEUDO_VOIGT_H_   /* Include guard */
#define PSEUDO_VOIGT_H_

#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_randist.h>

#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal

typedef struct IRF
{
    double UG;
    double VG;
    double WG;
    double UL;
    double VL;
    double WL;
} IRF;

//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_vector * bg_pos, double * bg_int);
//PSEUDO-VOIGT NORMALIZADA (EN AREA)
double pseudo_voigt_n(double x, double x0, double eta, double H);
//FUNCION PSEUDO-VOIGT
double pseudo_voigt(double ttheta, int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], int n_bg, gsl_vector * bg_pos, double * bg_int);
//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL GAUSSIANO(CAGLIOTI)
double HG_ins2(IRF ins, double theta);
//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL LORENZIANO(CAGLIOTI)
double HL_ins(IRF ins, double theta);
//PSEUDO-VOIGT ---> VOIGT
void deconvolution(double * HG2, double * HL, double H, double eta);
//VOIGT ---> PSEUDO-VOIGT
void convolution(double * H, double * eta, double HG, double HL);
//CORRECCION POR ANCHO DE PICO INSTRUMENTAL
void ins_correction(double * H, double * eta, IRF ins, double theta);

#endif
