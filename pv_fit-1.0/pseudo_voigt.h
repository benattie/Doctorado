#ifndef PSEUDO_VOIGT_H   /* Include guard */
#define PSEUDO_VOIGT_H
//Archivo con las definiciones de la pseudo_voigt asi como de las funciones auxiliares necesarias.

//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_matrix * bg_pos, double bg_int[N][2]);
//Derivada respecto a los puntos de Bg
double dpv_dbg_left(int N, double x, gsl_matrix * bg_pos);
double dpv_dbg_right(int N, double x, gsl_matrix * bg_pos);
/////////////////////////////////////////////////////////////////////////////////////
//FUNCION PSEUDO-VOIGT
double pseudo_voigt(double ttheta, int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], gsl_matrix * bg_pos, double bg_int[numrings][2]);
//Derivada respecto a la intensidad
double pseudo_voigt_n(double x, double x0, double eta, double H);
double dpv_dI0(double x, double x0, double eta, double H);
//Derivadas respecto al centro del pico
double dCauchy_dt0(double x, double gamma);
double dGauss_dt0(double x, double sigma);
double dpv_dt0 (double I, double x, double x0, double eta, double H);
/////////////////////////////////////////////////////////////////////////////////////
//Funciones para calcular la derivada respecto del ancho de pico
double dCauchy_dH(double x, double gamma);
double dGauss_dH(double x, double sigma);
double dpv_dshift_H(double I, double x, double x0, double eta, double H);
double dpv_dH(int N, double I[N], double x, double x0[N], double eta[N], double H[N]);
/////////////////////////////////////////////////////////////////////////////////////
//Funciones para calcular la derivada respecto al eta
double dpv_dshift_eta(double I, double x, double x0, double H);
double dpv_deta(int N, double I[N], double x, double x0[N], double H[N]);
/////////////////////////////////////////////////////////////////////////////////////
#endif
