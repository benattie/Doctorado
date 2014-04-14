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

void pv_step1(int exists, double ** seeds, int seeds_size, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double eta;
    double * shift_H = vector_double_alloc((*d).numrings);
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante

    //un vector de valores iniciales para cada paso de la iteracion
    double * x_init = vector_double_alloc(n_param);

    //semillas de los parametros variables del fiteo
    //printf("Inicializando los parametros\n");
    j = 0;
    x_init[j] = seeds[exists][0]; j++;//H
    for(i = 2; i < seeds_size; i += 6)
    {
        x_init[j] = seeds[exists][i]; j++; //theta_0
        x_init[j] = seeds[exists][i + 1]; j++; //Intesity
        x_init[j] = seeds[exists][i + 4]; j++; //Bg_Left
        x_init[j] = seeds[exists][i + 5]; j++; //Bg_Right    
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    eta = seeds[exists][1];
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    {
        shift_H[j] = seeds[exists][i + 2]; 
        shift_eta[j] = seeds[exists][i + 3]; 
        j++;
    }
    data_s1 d1 = {*d, eta, shift_H, shift_eta};

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f_step1; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior

    pv.n = (*d).n; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d1; //datos experimentales
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, (*d).n, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //inicio las iteraciones
    //printf ("\nInicio del fit en spr #%d y gamma #%d\n", (*difra).spr, (*difra).gamma);
    //print_state (iter, s);
    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);
        //printf ("status = %s\n", gsl_strerror (status));
        //print_state (iter, s);
        if (status)
            break;
        status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (status == GSL_CONTINUE && iter < max_iter);
    //printf ("status = %s\n", gsl_strerror (status));
    //print_state (iter, s);
    //FILE *fp_errlog = fopen("error_logfile.txt", "a");
    //if(status != 0)//reportar errores
    //{
    //    printf ("\nError #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //    fprintf(fp_errlog, "#Error #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //}
    //fclose(fp_errlog);
    
    //imprimo los resultados
    //printf("Salida de los resultados del paso 1\n");
    j = 0;
    seeds[1][0] = gsl_vector_get(s -> x, j); j++;//H
    for(i = 2; i < seeds_size; i += 6)
    {
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
        seeds[1][i + 4] = gsl_vector_get(s -> x, j); j++; //Bg_Left
        seeds[1][i + 5] = gsl_vector_get(s -> x, j); j++; //Bg_Right
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Fin del paso 1\n");
}

void pv_step2(int exists, double ** seeds, int seeds_size, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double H, eta;
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante

    //un vector de valores iniciales para cada paso de la iteracion
    double * x_init = vector_double_alloc(n_param);

    //semillas de los parametros
    //printf("Inicializando los parametros\n");
    j = 0;
    //x_init[j] = seeds[1][0]; j++;//H
    for(i = 2; i < seeds_size; i += 6)
    {
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
        x_init[j] = seeds[1][i + 2]; j++; //Shift_H
        x_init[j] = seeds[1][i + 4]; j++; //Bg_Left
        x_init[j] = seeds[1][i + 5]; j++; //Bg_Right
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    H = seeds[1][0];
    eta = seeds[exists][1];
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    { 
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //inicio las iteraciones
    //printf ("\nInicio del fit en spr #%d y gamma #%d\n", difra.spr, difra.gamma);
    //print_state (iter, s);
    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);
        //printf ("status = %s\n", gsl_strerror (status));
        //print_state (iter, s);
        if (status)
            break;
        status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (status == GSL_CONTINUE && iter < max_iter);
    //printf ("status = %s\n", gsl_strerror (status));
    //print_state (iter, s);
    //FILE *fp_errlog = fopen("error_logfile.txt", "a");
    //if(status != 0)//reportar errores
    //{
    //    printf ("\nError #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //    fprintf(fp_errlog, "#Error #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //}
    //fclose(fp_errlog);
    
    //imprimo los resultados
    //printf("Salida de los resultados del paso 2\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    {
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
        seeds[1][i + 2] = gsl_vector_get(s -> x, j); j++; //Shift_H
        seeds[1][i + 4] = gsl_vector_get(s -> x, j); j++; //Bg_Left
        seeds[1][i + 5] = gsl_vector_get(s -> x, j); j++; //Bg_Right
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Fin del paso 2\n");
}

void pv_step3(int exists, double ** seeds, int seeds_size, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double * shift_H = vector_double_alloc((*d).numrings);
    double * shift_eta = vector_double_alloc((*d).numrings);
    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante ---> moverlo para el principio de cada paso (o solo para el ultimo, no se) 

    //un vector de valores iniciales para cada paso de la iteracion
    double * x_init = vector_double_alloc(n_param);

    //semillas de los parametros
    //printf("Inicializando los parametros\n");
    j = 0;
    x_init[j] = seeds[1][0]; j++;//H
    x_init[j] = seeds[exists][1]; j++;//eta
    for(i = 2; i < seeds_size; i += 6)
    {
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
        x_init[j] = seeds[1][i + 4]; j++; //Bg_Left
        x_init[j] = seeds[1][i + 5]; j++; //Bg_Right
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //Estructura con los parametros fijos del fiteo
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    {
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //inicio las iteraciones
    //printf ("\nInicio del fit en spr #%d y gamma #%d\n", difra.spr, difra.gamma);
    //print_state (iter, s);
    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);
        //printf ("status = %s\n", gsl_strerror (status));
        //print_state (iter, s);
        if (status)
            break;
        status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (status == GSL_CONTINUE && iter < max_iter);
    //printf ("status = %s\n", gsl_strerror (status));
    //print_state (iter, s);
    //FILE *fp_errlog = fopen("error_logfile.txt", "a");
    //if(status != 0)//reportar errores
    //{
    //    printf ("\nError #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //    fprintf(fp_errlog, "#Error #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //}
    //fclose(fp_errlog);
    
    //imprimo los resultados
    //printf("Salida de los resultados del paso 3\n");
    j = 0;
    seeds[1][0] = gsl_vector_get(s -> x, j); j++;//H
    seeds[1][1] = gsl_vector_get(s -> x, j); j++;//eta
    for(i = 2; i < seeds_size; i += 6)
    {
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
        seeds[1][i + 4] = gsl_vector_get(s -> x, j); j++; //Bg_Left
        seeds[1][i + 5] = gsl_vector_get(s -> x, j); j++; //Bg_Right
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Fin del paso 3\n");
}

void pv_step4(int exists, double ** seeds, int seeds_size, struct data * d, int n_param)
{
    //variables generales del programa
    int i, j;
    double H, eta;
    //FILE *fp_errlog;
    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    //gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante

    //un vector de valores iniciales para cada paso de la iteracion
    double * x_init = vector_double_alloc(n_param);

    //semillas de los parametros
    //printf("Inicializando los parametros\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    {
        x_init[j] = seeds[1][i]; j++; //theta_0
        x_init[j] = seeds[1][i + 1]; j++; //Intensity
        x_init[j] = seeds[1][i + 2]; j++; //Shift_H
        x_init[j] = seeds[exists][i + 3]; j++; //Shift_eta
        x_init[j] = seeds[1][i + 4]; j++; //Bg_Left
        x_init[j] = seeds[1][i + 5]; j++; //Bg_Right
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //inicio las iteraciones
    //printf ("\nInicio del fit en spr #%d y gamma #%d\n", difra.spr, difra.gamma);
    //print_state (iter, s);
    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);
        //printf ("status = %s\n", gsl_strerror (status));
        //print_state (iter, s);
        if (status)
            break;
        status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (status == GSL_CONTINUE && iter < max_iter);
    //printf ("status = %s\n", gsl_strerror (status));
    //print_state (iter, s);
    //FILE *fp_errlog = fopen("error_logfile.txt", "a");
    //if(status != 0)//reportar errores
    //{
    //    printf ("\nError #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //    fprintf(fp_errlog, "#Error #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    //}
    //fclose(fp_errlog);
    
    //imprimo los resultados
    //printf("Salida de los resultados del paso 4\n");
    j = 0;
    for(i = 2; i < seeds_size; i += 6)
    {
        seeds[1][i] = gsl_vector_get(s -> x, j); j++; //theta_0
        seeds[1][i + 1] = gsl_vector_get(s -> x, j); j++; //Intensity
        seeds[1][i + 2] = gsl_vector_get(s -> x, j); j++; //Shift_H
        seeds[1][i + 3] = gsl_vector_get(s -> x, j); j++; //Shift_eta
        seeds[1][i + 4] = gsl_vector_get(s -> x, j); j++; //Bg_Left
        seeds[1][i + 5] = gsl_vector_get(s -> x, j); j++; //Bg_Right
    }
    free(x_init);
    gsl_multifit_fdfsolver_free (s);
    //printf("Fin del paso 4\n");
}
