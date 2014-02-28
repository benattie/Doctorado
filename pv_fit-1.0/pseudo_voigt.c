//FUNCION PSEUDO-VOIGT
double pseudo_voigt(int numrings, double I0[numrings], double t0[numrings], double H, double eta, double shift_H[numrings], double shift_eta[numrings], double bg_left[numrings], double bg_right[numrings], double ttheta)
{
    int i;
    double eta_i, H_i, x_i, BG, pv_n;
    double result = 0;
    
    for (i = 0; i < numrings; i++)
    {
        eta_i = eta + shift_eta[i];
        H_i = H + shift_H[i];
        x_i = ttheta - t0[i];

        pv_n = pseudo_voigt_n(ttheta, t0[i], eta_i, H_i);
        
        BG = (bg_left + bg_right) / 2.; 
        
        result = result + I0[i] * pv_n - BG;
    }
    
    return result;
}

 
//CORREGIR LAS POTENCIAS EN LAS FUNCIONES
//Derivada respecto a la intensidad
double pseudo_voigt_n(double x, double x0, double eta, double H)
{
    double eta, gamma, sigma, delta;
    gamma = H / 2.;
    sigma = H / (2. * sqrt(2. * log(2)));
    delta = x - x0;

    return eta * gsl_ran_cauchy_pdf(delta, gamma) + (1 - eta) * gsl_ran_gaussian_pdf(delta, sigma)
}

double dpv_I0(int N, double x, double x0[numrings], double eta[numrings], double H[numrings])
{// mi dato es el FWHM (H_i) pero a las funciones tengo que pasarles gamma (Cauchy) y sigma (Gauss)
    int i;
    double sigma, gamma, q, result = 0;
    for(i=0; i < N; i++)
    {
        result = result + pseudo_voigt_n(x, x0[i], eta[i], H[i]); 
    }
    return result;
}

//Derivadas respecto al centro del pico
double dCauchy_dt0(double x, double x0, double gamma)
{
    a = (x - x0) / sigma ^ 2;
    return a *  gsl_ran_gaussian_pdf(x_i, sigma);
}

double dGauss_dt0(double x, double x0, double sigma)
{
    a = (2 * M_PI) / gamma;
    b = (x - x0);
    return a * b * (gsl_ran_cauchy_pdf(x_i, H_i / 2.0))^2;
}

//////////////////////////////////////////////////////////////////////////////////////
double dpv_dt0 (double I, double x, double x0, double eta, double gamma, double sigma)
{
    return I * (eta * dCauchy_dt0(x, x0, gamma) + (1 - eta) * dGauss_dt0(x, x0, sigma));
}
/////////////////////////////////////////////////////////////////////////////////////

//Funciones para calcular la derivada respecto del ancho de pico
double dCauchy_dH(double x, double x0, double gamma)
{
    double a = -0.5;
    double b = (2 * (x - x0) * M_PI) / gamma^2;
    double c = gsl_ran_cauchy_pdf(x - x0, gamma);
    return a * c * (1 + c * b);
}

double dGauss_dH(double x, double x0, double sigma)
{
    double a = 1. / (2 * sqrt(2 * log(2)));
    double b = ((x - x0)^2 - sigma^2) / sigma^3;
    return a * b * gsl_ran_gaussian_pdf(x - x0, sigma);
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dshift_H(double I, double x, double x0, double eta, double gamma, double sigma)
{
    return I * (eta * dCauchy_dH(x, x0, gamma) + (1 - eta) * dGauss_dH(x, x0, sigma));
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dH(int N, double I[N], double x, double x0[N], double eta[N], double gamma[N], double sigma[N])
{
    int i;
    double result = 0;
    for(i = 0; i < N; i++){
        result = result + dpv_dshift_H(I[i], x, x0[i], eta[i], gamma[i], sigma[i]);
    }
    return result;
}
/////////////////////////////////////////////////////////////////////////////////////

//Funciones para calcular la derivada respecto al eta

/////////////////////////////////////////////////////////////////////////////////////
double dpv_dshift_eta(double I, double x, double x0, double gamma, double sigma)
{
    return I * (gsl_ran_cauchy_pdf(x - x0, gamma) - gsl_ran_gaussian_pdf(x - x0, sigma));
}

/////////////////////////////////////////////////////////////////////////////////////
double dpv_deta(int N, double I[N], double x, double x0[N], double gamma[N], double sigma[N])
{
    int i;
    double result = 0;
    for(i = 0; i < N; i++){
        result = result + dpv_dshift_eta(I[i], x, x0[i], gamma[i], sigma[i]);
    }
    return result;
}
/////////////////////////////////////////////////////////////////////////////////////

//Derivada respecto a los puntos de Bg
/////////////////////////////////////////////////////////////////////////////////////
double dpv_dbg(void)
{
    return 0.5;
}
/////////////////////////////////////////////////////////////////////////////////////
