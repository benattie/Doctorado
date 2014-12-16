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
    int n = d_int.n, i, j = 0;
    int numrings = d_int.numrings;
    int n_bg = d_int.n_bg;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_vector * bg_pos = d_int.bg_pos;
    double eta = ((data_s1 *)data) -> eta;
    double * shift_H = ((data_s1 *)data) -> shift_H;
    double * shift_eta = ((data_s1 *)data) -> shift_eta;
    //parametros del fiteo (para el programa representan las variables independientes)
    double H, I0[numrings], t0[numrings], bg_int[n_bg];
    
    //inicializo los parametros
    i = 0;
    H = gsl_vector_get (x, j); j++;
    for(i = 0; i < numrings; i++){
        t0[i] = gsl_vector_get(x, j);
        I0[i] = gsl_vector_get(x, j + 1);
        j += 2;
    }
    for(i = 0; i < n_bg; i++){
        bg_int[i] = gsl_vector_get(x, j); 
        j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++){   
        double s = gsl_vector_get(sigma, i);
        if(s == 0) 
            s = S; //por si me toca un punto con intensidad nula
        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, n_bg, bg_pos, bg_int);
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
    int n = d_int.n, i, j = 0;;
    int numrings = d_int.numrings;
    int n_bg = d_int.n_bg;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_vector * bg_pos = d_int.bg_pos;
    double H = ((data_s2 *)data) -> H;
    double eta = ((data_s2 *)data) -> eta;
    double * shift_eta = ((data_s2 *)data) -> shift_eta;

    //parametros del fiteo (para el programa representan las variables independientes)
    double I0[numrings], t0[numrings], shift_H[numrings], bg_int[n_bg];
    
    //inicializo los parametros
    for(i = 0; i < numrings; i++){
        t0[i] = gsl_vector_get(x, j);
        I0[i] = gsl_vector_get(x, j + 1);
        shift_H[i] = gsl_vector_get(x, j + 2);
        j += 3;
    }
    for(i = 0; i < n_bg; i++){
        bg_int[i] = gsl_vector_get(x, j); 
        j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++){   
        double s = gsl_vector_get(sigma, i);
        if(s == 0) 
            s = S; //por si me toca un punto con intensidad nula
        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, n_bg, bg_pos, bg_int);
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
    int n = d_int.n, i, j = 0;
    int numrings = d_int.numrings;
    int n_bg = d_int.n_bg;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_vector * bg_pos = d_int.bg_pos;
    double * shift_H = ((data_s3 *)data) -> shift_H;
    double * shift_eta = ((data_s3 *)data) -> shift_eta;

    //parametros del fiteo (para el programa representan las variables independientes)
    double H, eta, I0[numrings], t0[numrings], bg_int[n_bg];
    
    //inicializo los parametros
    H = gsl_vector_get (x, j); j++;
    eta = gsl_vector_get (x, j); j++;
    for(i = 0; i < numrings; i++){
        t0[i] = gsl_vector_get(x, j);
        I0[i] = gsl_vector_get(x, j + 1);
        j += 2;
    }
    for(i = 0; i < n_bg; i++){
        bg_int[i] = gsl_vector_get(x, j); 
        j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++){   
        double s = gsl_vector_get(sigma, i);
        if(s == 0) 
            s = S; //por si me toca un punto con intensidad nula
        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, n_bg, bg_pos, bg_int);
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
    int n = d_int.n, i, j = 0;;
    int numrings = d_int.numrings;
    int n_bg = d_int.n_bg;
    gsl_vector * ttheta = d_int.ttheta;
    gsl_vector * y = d_int.y;
    gsl_vector * sigma = d_int.sigma;
    gsl_vector * bg_pos = d_int.bg_pos;
    double H = ((data_s4 *)data) -> H;
    double eta = ((data_s4 *)data) -> eta;

    //parametros del fiteo (para el programa representan las variables independientes)
    double I0[numrings], t0[numrings], shift_H[numrings], shift_eta[numrings], bg_int[n_bg];
    
    //inicializo los parametros
    for(i = 0; i < numrings; i++){
        t0[i] = gsl_vector_get(x, j);
        I0[i] = gsl_vector_get(x, j + 1);
        shift_H[i] = gsl_vector_get(x, j + 2);
        shift_eta[i] = gsl_vector_get(x, j + 3);
        j += 4;
    }
    for(i = 0; i < n_bg; i++){
        bg_int[i] = gsl_vector_get(x, j); 
        j++;
    }
    
    //evaluo la funcion
    for (i = 0; i < n; i++){   
        double s = gsl_vector_get(sigma, i);
        if(s == 0) 
            s = S; //por si me toca un punto con intensidad nula
        double Yi = pseudo_voigt(gsl_vector_get(ttheta, i), numrings, I0, t0, H, eta, shift_H, shift_eta, n_bg, bg_pos, bg_int);
        double res = (Yi - gsl_vector_get(y, i)) / s;
        gsl_vector_set (f, i, res);
    }
    return GSL_SUCCESS;
}
