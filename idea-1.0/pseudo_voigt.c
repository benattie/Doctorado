#include "pseudo_voigt.h"
#include "array_alloc.h"

/*
typedef struct IRF
{
    double U;
    double V;
    double W;
    double IG;
    double X;
    double Y;
    double Z;
} IRF;
*/
//FUNCION BACKGROUND (INTERPOLACION LINEAL)
double background(int N, double x, gsl_matrix * bg_pos, double bg_int[N][2])
{
    int i, j = 0;
    double m, h, delta;
    double aux[2 * N], aux_bg[2 * N];
    
    for(i = 0; i < N; i++)
    {//paso a las posiciones de una matriz a un vector   
        aux[j] = gsl_matrix_get(bg_pos, i, 0); 
        aux_bg[j] = bg_int[i][0];
        j++;

        aux[j] = gsl_matrix_get(bg_pos, i, 1);
        aux_bg[j] = bg_int[i][1];
        j++;
    }

    if(x <= aux[0])
    {
	return aux_bg[0];
    }
    
    for(i = 0; i < 2 * N; i++)
    {
	if(x >= aux[i] && x < aux[i + 1])
	{
            m = (aux_bg[i + 1] - aux_bg[i]) / (aux[i + 1] - aux[i]);
            delta = x - aux[i];
            h = aux_bg[i];

	    return m * delta + h;
	}
    }
    return aux_bg[2 * N - 1];
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
        result += I0[i] * pv_n;
    }
    BG = background(numrings, ttheta, bg_pos, bg_int);
    result += BG;

    return result;
}

//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL GAUSSIANO(CAGLIOTI)
double HG_ins2(IRF ins, double theta)
{
    double result = ins.U * pow(tan(theta), 2.0) + ins.V * tan(theta) + ins.W + ins.IG / cos(theta);
    return result;
}
//FUNCION PARA CALCULAR EL ANCHO INSTRUMENTAL LORENZIANO(CAGLIOTI)
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
