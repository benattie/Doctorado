//Archivo con las definiciones de la pseudo_voigt asi como de las funciones auxiliares necesarias.
#include "pseudo_voigt.h"
//Funciones necesarias
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_randist.h>

//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_matrix * bg_pos, double bg_int[N][2])
{
    int i;
    double m, h, delta;
    double xl, xr;
    
    xl = gsl_matrix_get(bg_pos, 0, 0);
    if(x <= xl)
    {
	return bg_int[0][0];
    }
    
    for(i = 0; i < N; i++)
    {
	xl = gsl_matrix_get(bg_pos, i, 0);
	xr = gsl_matrix_get(bg_pos, i, 1);
	if(x >= xl && x < xr)
	{
	    	m = (bg_int[i][1] - bg_int[i][0]) / (xr - xl);
		delta = x - xl;
		h = bg_int[i][0];

		return m * delta + h;
	}
    }
    
    return bg_int[N - 1][1];
}

//Derivada respecto a los puntos de Bg
double dpv_dbg_left(int N, double x, gsl_matrix * bg_pos)
{
    int i; 
    double result;
    double xl, xr;
    
    xl = gsl_matrix_get(bg_pos, 0, 0);
    if(x <= xl)
    {
	return 1;
    }
   
    for(i = 0; i < N; i++)
    {
	xl = gsl_matrix_get(bg_pos, i, 0);
	xr = gsl_matrix_get(bg_pos, i, 1);
	if(x >= xl && x < xr)
	{
	    	result = 1 - (x - xl) / (xr - xl);
		return result;
	}
    }

    return 0;
}
double dpv_dbg_right(int N, double x, gsl_matrix * bg_pos)
{
    int i;
    double result;
    double xl, xr;
    
    xl = gsl_matrix_get(bg_pos, 0, 0);
    if(x <= xl)
    {
	return 0;
    }

    for(i = 0; i < N; i++)
    {
	xl = gsl_matrix_get(bg_pos, i, 0);
	xr = gsl_matrix_get(bg_pos, i, 1);
	if(x >= xl && x < xr)
	{
	    	result = (x - xl) / (xr - xl);
		return result;
	}
    }

    return 1;
}
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
//FUNCION PSEUDO-VOIGT
double pseudo_voigt(double ttheta, int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], gsl_matrix * bg_pos, double bg_int[numrings][2])
{
    int i;
    double eta_i, H_i, BG, pv_n;
    double result = 0;
    
    for (i = 0; i < numrings; i++)
    {
        eta_i = eta + shift_eta[i];
        H_i = H + shift_H[i];

        pv_n = pseudo_voigt_n(ttheta, t0[i], eta_i, H_i);
        
        BG = background(numrings, ttheta, bg_pos, bg_int); 
        
        result = result + I0[i] * pv_n - BG;
    }
    return result;
}

//Derivada respecto a la intensidad
double pseudo_voigt_n(double x, double x0, double eta, double H)
{
    double gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;

    return eta * gsl_ran_cauchy_pdf(delta, gamma) + (1 - eta) * gsl_ran_gaussian_pdf(delta, sigma);
}

double dpv_dI0(double x, double x0, double eta, double H)
{// mi dato es el FWHM (H_i) pero a las funciones tengo que pasarles gamma (Cauchy) y sigma (Gauss)
    return pseudo_voigt_n(x, x0, eta, H); 
}

//Derivadas respecto al centro del pico
double dCauchy_dt0(double x, double gamma)
{
    double c = 2 * M_PI / gamma;
    return x * c * gsl_pow_2(gsl_ran_cauchy_pdf(x, gamma));
}

double dGauss_dt0(double x, double sigma)
{
    double c = x / gsl_pow_2(sigma);
    return c * gsl_ran_gaussian_pdf(x, sigma);
}

//////////////////////////////////////////////////////////////////////////////////////
double dpv_dt0 (double I, double x, double x0, double eta, double H)
{
    double gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;
    
    return I * (eta * dCauchy_dt0(delta, gamma) + (1 - eta) * dGauss_dt0(delta, sigma));
}
/////////////////////////////////////////////////////////////////////////////////////

//Funciones para calcular la derivada respecto del ancho de pico
double dCauchy_dH(double x, double gamma)
{
    double a = -0.5;
    double b = (-2 * x * M_PI) / gsl_pow_2(gamma);
    double c = gsl_ran_cauchy_pdf(x, gamma);
    return a * c * (1 + c * b);
}

double dGauss_dH(double x, double sigma)
{
    double a = 1. / (2 * sqrt(2 * log(2)));
    double b = (gsl_pow_2(x) - gsl_pow_2(sigma)) / gsl_pow_3(sigma);

    return a * b * gsl_ran_gaussian_pdf(x, sigma);
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dshift_H(double I, double x, double x0, double eta, double H)
{
    double gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;

    return I * (eta * dCauchy_dH(delta, gamma) + (1 - eta) * dGauss_dH(delta, sigma));
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dH(int N, double I[N], double x, double x0[N], double eta[N], double H[N])
{
    int i;
    double result = 0;
    for(i = 0; i < N; i++)
    {
        result = result + dpv_dshift_H(I[i], x, x0[i], eta[i], H[i]);
    }
    return result;
}
/////////////////////////////////////////////////////////////////////////////////////

//Funciones para calcular la derivada respecto al eta

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dshift_eta(double I, double x, double x0, double H)
{
    double gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;

    return I * (gsl_ran_cauchy_pdf(delta, gamma) - gsl_ran_gaussian_pdf(delta, sigma));
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_deta(int N, double I[N], double x, double x0[N], double H[N])
{
    int i;
    double result = 0;
    for(i = 0; i < N; i++)
    {
        result = result + dpv_dshift_eta(I[i], x, x0[i], H[i]);
    }
    return result;
}
/////////////////////////////////////////////////////////////////////////////////////
