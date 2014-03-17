//#include <gsl/gsl_math.h>
//#include <gsl/gsl_randist.h>
#include "pseudo_voigt.h"
#define S 1
//x = vector de valores a ajustar
//data = estructura a los parametros fijos de la funcion (datos experimentales, etc)
//f = vector diferencia entre los valores teoricos y los experimentales

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
        double s = gsl_vector_get(sigma, i);
        if(s == 0) s = S; //por si me toca un punto con intensidad nula

        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, bg_pos, bg_int);
        double res = (Yi - gsl_vector_get(y, i)) / s;
        gsl_vector_set (f, i, res);
    }
    return GSL_SUCCESS;
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
