#include "pseudo_voigt.h"
#include "array_alloc.h"

//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_vector * bg_pos, double * bg_int)
{
    int i;
    double m, h, delta;
    
    if(x <= gsl_vector_get(bg_pos, 0))
    	return bg_int[0];
    
    for(i = 0; i < N; i++)
    {
    	if(x >= gsl_vector_get(bg_pos, i) && x < gsl_vector_get(bg_pos, i + 1))
    	{
            m = (bg_int[i + 1] - bg_int[i]) / (gsl_vector_get(bg_pos, i + 1) - gsl_vector_get(bg_pos, i));
            delta = x - gsl_vector_get(bg_pos, i);
            h = bg_int[i];
    	    return m * delta + h;
	    }
    }
    return bg_int[N - 1];
}

//PSEUDO-VOIGT NORMALIZADA (EN AREA)
double pseudo_voigt_n(double x, double x0, double eta, double H)
{
    double gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;

    return eta * gsl_ran_cauchy_pdf(delta, gamma) + (1 - eta) * gsl_ran_gaussian_pdf(delta, sigma);
}

//FUNCION PSEUDO-VOIGT
double pseudo_voigt(double ttheta, int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], int n_bg, gsl_vector * bg_pos, double * bg_int)
{
    int i;
    double eta_i, H_i, BG, pv_n;
    double result = 0;
    
    for (i = 0; i < numrings; i++)
    {
        eta_i = eta + shift_eta[i];
        H_i = H + shift_H[i];
        pv_n = pseudo_voigt_n(ttheta, t0[i], eta_i, H_i);
        result += I0[i] * pv_n;
    }
    BG = background(n_bg, ttheta, bg_pos, bg_int);
    result += BG;
    return result;
}
