#include <gsl/gsl_math.h>
#include <gsl/gsl_randist.h>
#define pi 3.141592654

#include "pseudo_voigt.c"

//x = vector de parametros
//data = vector de data experimental
//f = vector diferencia

//DEFINICION DE FUNCIONES
float bin2theta(int bin, float pixel, float dist);

//ESTRUCTURA CON TODOS LOS DATOS EXPERIMENTALES
struct data {
    int n;
    int numrings;
    gsl_vector * ttheta;
    gsl_vector * y;
    gsl_vector * sigma;
};

//INICIO DE LA FUNCION
int pv_f (const gsl_vector * x, void *data, gsl_vector * f)
{
    int n = ((struct data *)data) -> n;
    int numrings = ((struct data *)data) -> numrings;
    gsl_vector * ttheta = ((struct data *)data) -> ttheta;
    gsl_vector * y = ((struct data *)data) -> y;
    gsl_vector * sigma = ((struct data *) data) -> sigma;

    int i, j = 0;
    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double shift_eta[numrings];
    double bg_left[numrings];
    double bg_right[numrings];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j);
    j++;
    eta = gsl_vector_get (x, j);
    j++;
    for(i = 0; i < numrings; i++)
    {
        I0[i] = gsl_vector_get(x, j);   j++;
        t0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j);  j++;        
        shift_eta[i] = gsl_vector_get(x, j);    j++;
        bg_left[i] = gsl_vector_get(x, j);  j++;
        bg_right[i] = gsl_vector_get(x, j); j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++)
    {
        double Yi = pseudo_voigt(numrings, I0, t0, H, eta, shift_H, shift_eta, bg_left, bg_right, gsl_vector_get(ttheta, i));

        gsl_vector_set (f, i, (Yi - gsl_vector_get(y, i)) / gsl_vector_get(sigma, i));
    }

    return GSL_SUCCESS;
}

//INICIO DE LA FUNCION JACOBIANA
int pv_df (const gsl_vector * x, void *data, gsl_matrix * J)
{
    int n = ((struct data *)data) -> n;
    int numrings = ((struct data *)data) -> numrings;
    gsl_vector * ttheta = ((struct data *)data) -> ttheta;
    gsl_vector * y = ((struct data *)data) -> y;
    gsl_vector * sigma = ((struct data *) data) -> sigma;

    int i, j = 0, k;
    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    
    double I0[numrings];
    double t0[numrings];
    
    double shift_H[numrings];
    double shift_eta[numrings];
    
    double H_i[numrings];
    double sigma_i[numrings];
    double gamma_i[numrings];
    double eta_i[numrings];

    double bg_left[numrings];
    double bg_right[numrings];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j);
    j++;
    eta = gsl_vector_get (x, j);
    j++;
    for(i = 0; i < numrings; i++)
    {
        I0[i] = gsl_vector_get(x, j);   j++;
        t0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j);  j++;        
        shift_eta[i] = gsl_vector_get(x, j);    j++;
        
        H_i[i] = H + shift_H[i];
        sigma_i[i] = H_i[i] / (2. * sqrt(2. log(2)));
        gamma_i[i] = H_i[i] / 2.;

        eta_i[i] = eta + shift_eta[i]; 

        bg_left[i] = gsl_vector_get(x, j);  j++;
        bg_right[i] = gsl_vector_get(x, j); j++;
    }
    
    //evaluo el jacobiano
    //definir la matriz J
    for (i = 0; i < n; i++)
    {
        /* Jacobian matrix J(i,j) = dfi / dxj, */
        /* where fi = (Yi - yi)/sigma[i],      */
        /*       Yi = pseudo_voigt  */
        /* and the xj are the parameters (I0, t0, H, eta, shift_H, shift_eta, BgL, BgR) */
        double s = sigma[i];
        //Derivada respecto de H
        double dH = dpv_dH(numrings, I0, ttheta[i], t0, eta_i, gamma_i, sigma_i);
        gsl_matrix_set (J, i, 0, dH/s);
        //Derivada respecto de eta
        double deta = dpv_deta(numrings, I0, ttheta[i], t0, gamma_i, sigma_i);
        gsl_matrix_set (J, i, 1, deta/s);
        
        double dI0[numrings], dt0[numrings], dshift_H[numrings], dshift_eta[numrings];
        for(j = 0; j < numrings; j++)
        {
            dI0[j] = 
        }


    }

    return GSL_SUCCESS;
}

//LA FUNCION QUE TIENE DEFINIDA LA PSUDOVOIGT Y SU JACOBIANO
int pv_fdf (const gsl_vector * x, void *data, gsl_vector * f, gsl_matrix * J)
{
  pv_f (x, data, f);
  pv_df (x, data, J);

  return GSL_SUCCESS;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//FUNCIONES AUXILIARES
float bin2theta(int bin, float pixel, float dist)
{
    //math.atan(float(bin) * 100e-6 / 1081e-3) * 180. / math.pi
    return atan((float) bin * pixel / dist) * 180. / M_PI;
}
