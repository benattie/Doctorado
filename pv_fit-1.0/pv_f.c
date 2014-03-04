//#include <gsl/gsl_math.h>
//#include <gsl/gsl_randist.h>
#include "pseudo_voigt.h"

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
    gsl_matrix * bg_pos;
};

//INICIO DE LA FUNCION
int pv_f (const gsl_vector * x, void *data, gsl_vector * f)
{   
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    int n = ((struct data *)data) -> n;
    int numrings = ((struct data *)data) -> numrings;
    gsl_vector * ttheta = ((struct data *)data) -> ttheta;
    gsl_vector * y = ((struct data *)data) -> y;
    gsl_vector * sigma = ((struct data *) data) -> sigma;
    gsl_matrix * bg_pos = ((struct data *) data) -> bg_pos;

    int i, j = 0;
    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double shift_eta[numrings];
    double bg_int[numrings][2];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j); j++;
    eta = gsl_vector_get (x, j); j++;

    for(i = 0; i < numrings; i++)
    {
        I0[i] = gsl_vector_get(x, j);   j++;
        t0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j);  j++;        
        shift_eta[i] = gsl_vector_get(x, j);    j++;
        bg_int[i][0] = gsl_vector_get(x, j);  j++;
        bg_int[i][1] = gsl_vector_get(x, j);  j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++)
    {
        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, bg_pos, bg_int);
        double chi2 = (Yi - gsl_vector_get(y, i)) / gsl_vector_get(sigma, i);

        gsl_vector_set (f, i, chi2);
    }
    return GSL_SUCCESS;
}

//INICIO DE LA FUNCION JACOBIANA
int pv_df (const gsl_vector * x, void *data, gsl_matrix * J)
{
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    int n = ((struct data *)data) -> n;
    int numrings = ((struct data *)data) -> numrings;
    gsl_vector * ttheta = ((struct data *)data) -> ttheta;
    gsl_vector * y = ((struct data *)data) -> y;
    gsl_vector * sigma = ((struct data *) data) -> sigma;
    gsl_matrix * bg_pos = ((struct data *) data) -> bg_pos;

    int i, j = 0, k = 0;

    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double shift_eta[numrings];
    double bg_int[numrings][2];

    double H_i[numrings];
    double eta_i[numrings];

    //inicializo los parametros
    H = gsl_vector_get (x, j); j++;
    eta = gsl_vector_get (x, j); j++;

    for(i = 0; i < numrings; i++)
    {
        I0[i] = gsl_vector_get(x, j);   j++;
        t0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j);  j++;        
        shift_eta[i] = gsl_vector_get(x, j);    j++;
        
        H_i[i] = H + shift_H[i];
        eta_i[i] = eta + shift_eta[i]; 

        bg_int[i][0] = gsl_vector_get(x, j);  j++;
        bg_int[i][1] = gsl_vector_get(x, j);  j++;
    }
    
    //evaluo el jacobiano
    for (i = 0; i < n; i++)
    {//recorro todos los puntos experimentales (en 2\theta)
        /* Jacobian matrix J(i,j) = dfi / dxj, */
        /* where fi = (Yi - yi)/sigma[i],      */
        /*       Yi = pseudo_voigt  */
        /* and the xj are the parameters (I0, t0, H, eta, shift_H, shift_eta, Bg_Int) */
        double s = gsl_vector_get(sigma, i);

        //Derivadas respecto a los parámetros globales
        //Derivada respecto de H
        double dH = dpv_dH(numrings, I0, gsl_vector_get(ttheta, i), t0, eta_i, H_i);
        gsl_matrix_set (J, i, k, dH/s);     k++;

        //Derivada respecto de eta
        double deta = dpv_deta(numrings, I0, gsl_vector_get(ttheta, i), t0, H_i);
        gsl_matrix_set (J, i, k, deta/s);   k++;

        //Derivada respecto a los parametros de los picos
        double dI0[numrings], dt0[numrings], dshift_H[numrings], dshift_eta[numrings], dbg[numrings][2];
        for(j = 0; j < numrings; j++)
        {
            //Derivada respecto a la Intensidad máxima
            dI0[j] = dpv_dI0(gsl_vector_get(ttheta, i), t0, eta_i[j], H_i[j]);
            gsl_matrix_set (J, i, k, dI0[j] / s);   k++;
            
            //Derivada respecto a la posición del centro
            dt0[j] = dpv_dt0 (I0[j], gsl_vector_get(ttheta, i), t0[j], eta_i[j], H_i[j]);
            gsl_matrix_set (J, i, k, dt0[j] / s);   k++;

            //Derivada respecto al corrimiento en el ancho de pico
            dshift_H[j] = dpv_dshift_H(I0[j], gsl_vector_get(ttheta, i), t0[j], eta_i[j], H_i[j]);
            gsl_matrix_set (J, i, k, dshift_H[j] / s);  k++;

            //Derivada respecto al corrimiento del eta
            dshift_eta[j] = dpv_dshift_eta(I0[j], gsl_vector_get(ttheta, i), t0[j], H_i[j]);
            gsl_matrix_set (J, i, k, dshift_eta[j] / s);    k++;

            //Derivada respecto a la intensidad del background a los lados de cada pico
            dbg[j][0] = dpv_dbg_left(numrings, gsl_vector_get(ttheta, i), bg_pos);
            gsl_matrix_set (J, i, k, dbg[j][0] / s);    k++;

            dbg[j][1] = dpv_dbg_right(numrings, gsl_vector_get(ttheta, i), bg_pos);
            gsl_matrix_set (J, i, k, dbg[j][1] / s);    k++;
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
    return atan((float) bin * pixel / dist) * 180. / M_PI;
}
