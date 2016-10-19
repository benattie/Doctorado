//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting

//COSAS MIAS
#include "array_alloc.h"
#include "aux_functions.h"
#include "pv_f.c"

void pv_step1(int exists, double ** seeds, int seeds_size, double ** bg, struct data * d, int n_param)
{
    //variables generales del programa
    //printf("Mem Alloc\n");
    int i, j;
    double eta;
    double * shift_H = vector_double_alloc((*d).numrings);
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status = 0;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante
    double * x_init = vector_double_alloc(n_param);

    //printf("Inicializando los parametros\n");
    j = 0;
    x_init[j] = seeds[exists][0]; j++;//H
    for(i = 2; i < seeds_size; i += 4){
        x_init[j] = seeds[exists][i]; j++; //theta_0
        x_init[j] = seeds[exists][i + 1]; j++; //Intesity
    }
    for(i = 0; i < (*d).n_bg; i++){
        x_init[j] = bg[1][i]; 
        j++;
    }
    gsl_vector_view x = gsl_vector_view_array(x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    eta = seeds[exists][1];
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        shift_H[j] = seeds[exists][i + 2];
        shift_eta[j] = seeds[exists][i + 3];
        j++;
    }
    data_s1 d1 = {*d, eta, shift_H, shift_eta};

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f_step1; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior
    pv.n = d->n; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d1; //datos experimentales
 
    //inicializo el solver
    //printf ("\nSet solver\n");
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc(T, d->n, n_param);
    gsl_multifit_fdfsolver_set(s, &pv, &x.vector);
    solver_iterator(&status, s, T);

    //printf("Salida de los resultados del paso 1\n");
    j = 0;
    seeds[1][0] = gsl_vector_get(s -> x, j); j++;//H
    for(i = 2; i < seeds_size; i += 4){
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
    }
    for(i = 0; i < (*d).n_bg; i++){
        bg[1][i] = gsl_vector_get(s -> x, j);
        j++;
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Final del paso 1\n");
}

void pv_step2(int exists, double ** seeds, int seeds_size, double ** bg, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double H, eta;
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status = 0;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante
    double * x_init = vector_double_alloc(n_param);

    //printf("Inicializando los parametros\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
        x_init[j] = seeds[1][i + 2]; j++; //Shift_H
    }
    for(i = 0; i < (*d).n_bg; i++){
        x_init[j] = bg[1][i]; 
        j++;
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    H = seeds[1][0];
    eta = seeds[exists][1];
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        shift_eta[j] = seeds[exists][i + 3]; 
        j++;
    }
    data_s2 d2 = {*d, H, eta, shift_eta};

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f_step2; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior
    pv.n = (*d).n; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d2; //parametros fijos
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, (*d).n, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
    solver_iterator(&status, s, T);
    
    //printf("Salida de los resultados del paso 2\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
        seeds[1][i + 2] = gsl_vector_get(s -> x, j); j++; //Shift_H
    }
    for(i = 0; i < (*d).n_bg; i++){
        bg[1][i] = gsl_vector_get(s -> x, j); 
        j++;
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Final del paso 2\n");
}

void pv_step3(int exists, double ** seeds, double * errors, int seeds_size, double ** bg, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double * shift_H = vector_double_alloc((*d).numrings);
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status = 0;
    double c, chi, dof;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante
    double * x_init = vector_double_alloc(n_param);

    //printf("Inicializando los parametros\n");
    j = 0;
    x_init[j] = seeds[1][0]; j++;//H
    x_init[j] = seeds[exists][1]; j++;//eta
    for(i = 2; i < seeds_size; i += 4){
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
    }
    for(i = 0; i < (*d).n_bg; i++){
        x_init[j] = bg[1][i]; 
        j++;
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        shift_H[j] = seeds[1][i + 2];
        shift_eta[j] = seeds[exists][i + 3];
        j++;
    }
    data_s3 d3 = {*d, shift_H, shift_eta};

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f_step3; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior
    pv.n = (*d).n; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d3; //parametros fijos
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, (*d).n, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
    solver_iterator(&status, s, T);
    // Uncomment for GSL version previous to 2.1
    // gsl_multifit_covar (s->J, 0.0, covar);
    //
    // Comment the following 3 lines if using GSL version previous to 2.1
    gsl_matrix * J = gsl_matrix_calloc (d->n, n_param);//matriz jacobiana
    gsl_multifit_fdfsolver_jac(s, J);
    gsl_multifit_covar (J, 0.0, covar);


    chi = gsl_blas_dnrm2(s->f);
    dof = pv.n - pv.p;
    c = GSL_MAX_DBL(1, pow(chi, 2.0) / sqrt(dof));
    
    //printf("Salida de los resultados del paso 3\n");
    j = 0;
    seeds[1][0] = gsl_vector_get(s -> x, j);
    errors[0] = c * sqrt(gsl_matrix_get(covar, j, j));
    j++;//H
    seeds[1][1] = gsl_vector_get(s -> x, j); 
    errors[1] = c * sqrt(gsl_matrix_get(covar, j, j));
    j++;//eta
    for(i = 2; i < seeds_size; i += 4){
        seeds[1][i] = gsl_vector_get(s -> x, j); 
        j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); 
        j++; //Intensity
    }
    for(i = 0; i < (*d).n_bg; i++){
        bg[1][i] = gsl_vector_get(s -> x, j); 
        j++;
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    gsl_matrix_free(covar);
    //printf("Final del paso 3\n");
}

void pv_step4(int exists, double ** seeds, double * errors, int seeds_size, double ** bg, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double H, eta;
    //variables del solver
    int status = 0;
    double c, chi, dof;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante
    double * x_init = vector_double_alloc(n_param);

    //printf("Inicializando los parametros\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
        x_init[j] = seeds[1][i + 2]; j++; //Shift_H
        x_init[j] = seeds[exists][i + 3]; j++; //Shift_eta
    }
    for(i = 0; i < (*d).n_bg; i++){
        x_init[j] = bg[1][i]; 
        j++;
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear
    //Estructura con los parametros fijos del fiteo
    H = seeds[1][0];
    eta = seeds[1][1];
    data_s4 d4 = {*d, H, eta};

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f_step4; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior
    pv.n = (*d).n; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d4; //datos experimentales
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, (*d).n, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
    solver_iterator(&status, s, T);
    // Uncomment for GSL version previous to 2.1
    // gsl_multifit_covar (s->J, 0.0, covar);
    //
    // Comment the following 3 lines if using GSL version previous to 2.1
    gsl_matrix * J = gsl_matrix_calloc (d->n, n_param);//matriz jacobiana
    gsl_multifit_fdfsolver_jac(s, J);
    gsl_multifit_covar(J, 0.0, covar);


    chi = gsl_blas_dnrm2(s->f);
    dof = pv.n - pv.p;
    c = GSL_MAX_DBL(1, pow(chi, 2.0) / sqrt(dof));
   
    //printf("Salida de los resultados del paso 4\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 4){
        seeds[1][i] = gsl_vector_get(s -> x, j);
        errors[i] = c * sqrt(gsl_matrix_get(covar, j, j));
        j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j);
        errors[i + 1] = c * sqrt(gsl_matrix_get(covar, j, j));
        j++; //Intensity
        seeds[1][i + 2] = gsl_vector_get(s -> x, j);
        errors[i + 2] = c * sqrt(gsl_matrix_get(covar, j, j));
        j++; //Shift_H
        seeds[1][i + 3] = gsl_vector_get(s -> x, j);
        errors[i + 3] = c * sqrt(gsl_matrix_get(covar, j, j));
        j++; //Shift_eta
    }
    for(i = 0; i < (*d).n_bg; i++){
        bg[1][i] = gsl_vector_get(s -> x, j); 
        j++;
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    gsl_matrix_free(covar);
    //printf("Final del paso 4\n");
}
