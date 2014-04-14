#include "pseudo_voigt.h"
#include "aux_functions.h"
#define S 1
//x = vector de valores a ajustar
//data = estructura a los parametros fijos de la funcion (datos experimentales, etc)
//f = vector diferencia entre los valores teoricos y los experimentales

//INICIO DE LA FUNCION DEL PASO 1
int pv_f_step1 (const gsl_vector * x, void * data, gsl_vector * f)
{   
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    struct data d_int = ((data_s1 *)data) -> d;
    int n = d_int.n;
    int numrings = d_int.numrings;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_matrix * bg_pos = d_int.bg_pos;
    double eta = ((data_s1 *)data) -> eta;
    double * shift_H = ((data_s1 *)data) -> shift_H;
    double * shift_eta = ((data_s1 *)data) -> shift_eta;

    int i, j = 0;

    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double I0[numrings];
    double t0[numrings];
    double bg_int[numrings][2];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j); j++;
    for(i = 0; i < numrings; i++)
    {
        t0[i] = gsl_vector_get(x, j);   j++;
        I0[i] = gsl_vector_get(x, j);   j++;
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
//INICIO DE LA FUNCION DEL PASO 2
int pv_f_step2 (const gsl_vector * x, void * data, gsl_vector * f)
{   
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    struct data d_int = ((data_s2 *)data) -> d;
    int n = d_int.n;
    int numrings = d_int.numrings;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_matrix * bg_pos = d_int.bg_pos;
    double H = ((data_s2 *)data) -> H;
    double eta = ((data_s2 *)data) -> eta;
    double * shift_eta = ((data_s2 *)data) -> shift_eta;

    int i, j = 0;

    //parametros del fiteo (para el programa representan las variables independientes)
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double bg_int[numrings][2];
    
    //inicializo los parametros
    for(i = 0; i < numrings; i++)
    {
        t0[i] = gsl_vector_get(x, j);   j++;
        I0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j); j++;
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

//INICIO DE LA FUNCION DEL PASO 3
int pv_f_step3 (const gsl_vector * x, void * data, gsl_vector * f)
{   
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    struct data d_int = ((data_s3 *)data) -> d;
    int n = d_int.n;
    int numrings = d_int.numrings;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_matrix * bg_pos = d_int.bg_pos;
    double * shift_H = ((data_s3 *)data) -> shift_H;
    double * shift_eta = ((data_s3 *)data) -> shift_eta;
    int i, j = 0;

    //parametros del fiteo (para el programa representan las variables independientes)
    double H;
    double eta;
    double I0[numrings];
    double t0[numrings];
    double bg_int[numrings][2];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j); j++;
    eta = gsl_vector_get (x, j); j++;
    for(i = 0; i < numrings; i++)
    {
        t0[i] = gsl_vector_get(x, j);   j++;
        I0[i] = gsl_vector_get(x, j);   j++;
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

//INICIO DE LA FUNCION DEL PASO 4
int pv_f_step4 (const gsl_vector * x, void * data, gsl_vector * f)
{   
    //parametros fijos del fiteo (salen de los datos experimentales así como del para_fit2d.dat)
    struct data d_int = ((data_s4 *)data) -> d;
    int n = d_int.n;
    int numrings = d_int.numrings;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_matrix * bg_pos = d_int.bg_pos;
    double H = ((data_s4 *)data) -> H;
    double eta = ((data_s4 *)data) -> eta;
    int i, j = 0;

    //parametros del fiteo (para el programa representan las variables independientes)
    double I0[numrings];
    double t0[numrings];
    double shift_H[numrings];
    double shift_eta[numrings];
    double bg_int[numrings][2];
    
    //inicializo los parametros
    for(i = 0; i < numrings; i++)
    {
        t0[i] = gsl_vector_get(x, j);   j++;
        I0[i] = gsl_vector_get(x, j);   j++;
        shift_H[i] = gsl_vector_get(x, j); j++;
        shift_eta[i] = gsl_vector_get(x, j); j++;
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
/////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
