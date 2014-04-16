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

//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL GAUSSIANO(CAGLIOTI)
double HG_ins2(IRF ins, double theta)
{
    double result = ins.U * pow(tan(theta), 2.0) + ins.V * tan(theta) + ins.W + ins.IG / cos(theta);
    return result;
}
//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL LORENZIANO
double HL_ins(IRF ins, double theta)
{
    double result = ins.X * tan(theta) + ins.Y / cos(theta) + ins.Z;
    return result;
}
//PSEUDO-VOIGT ---> VOIGT
void convolution(double * HG2, double * HL, double H, double eta)
{
    double H2 = pow(H, 2.0);
    HG2[0] = H2 * (0.997379 - 0.719402 * eta - 0.294812 * pow(eta, 2.0) + 0.0172915 * pow(eta, 3.0));
    HL[0] = H * (0.72928 * eta + 0.19289 * pow(eta, 2.0) + 0.07783 * pow(eta, 3.0));
}
//VOIGT ---> PSEUDO-VOIGT
void deconvolution(double * H, double * eta, double HG2, double HL)
{
    double HG = sqrt(HG2);
    double H5 = pow(HG, 5.0) + 2.69269 *  pow(HG, 4.0) * HL + 2.42843 * pow(HG, 3.0) * pow(HL, 2.0) + 
                pow(HL, 5.0) + 0.07842 *  HG * pow(HL, 4.0) + 4.47163 * pow(HG, 2.0) * pow(HL, 3.0);
    *H = pow(H5, 0.2);
    double aux = HL / H[0];
    eta[0] = 1.36603 * aux - 0.47719 * pow(aux, 2.0) + 0.11116 * pow(aux, 3.0);
}
//CORRECCION POR ANCHO DE PICO INSTRUMENTAL
void ins_correction(double * H, double * eta, IRF ins, double theta)
{
    double * HG2 = vector_double_alloc(1);
    double * HL = vector_double_alloc(1);
    convolution(HG2, HL, H[0], eta[0]);
    HG2[0] -= HG_ins2(ins, theta);
    if(*HG2 <= 0) *HG2 = 0;
    HL[0] -= HL_ins(ins, theta);
    if(*HL <= 0) *HL = 0;
    deconvolution(H, eta, HG2[0], HL[0]);
    free(HG2);
    free(HL);
}
