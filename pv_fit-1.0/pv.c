//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting
void print_state (size_t iter, gsl_multifit_fdfsolver * s);

//COSAS MIAS
#include "read_file.c"
#include "pv_f.c"

//MAIN
int main(void){
    //variables de entrada (algunas no van a ser necesarias cuando incorpore todo al programa de sangbong)
    char name[15] = "dif000.dat"; //no va a hacer falta cuando corra el programa de sangbong
    int size = 1725; //sacar del programa de sangbong
    int numrings = 7; //sacar del programa de sangbong
    int i, j;
    //estimacion inicial de los parametros del fiteo (sacar del para_fit2d.dat o de un archivo externo)
    int ** bg_pos_data = (int **) malloc(numrings * sizeof(int));
    if(bg_pos_data == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    for(i = 0; i < numrings; i++)
    {
        bg_pos_data[i] = (int *) malloc(2 * sizeof(int));
        if(bg_pos_data[i] == NULL)
        {   
            printf("Out of memory\n");
            exit (1);
        }
    }
    bg_pos_data[0][0] = 630;    bg_pos_data[0][1] = 684;
    bg_pos_data[1][0] = 730;    bg_pos_data[1][1] = 790;
    bg_pos_data[2][0] = 1060;    bg_pos_data[2][1] = 1094;
    bg_pos_data[3][0] = 1240;    bg_pos_data[3][1] = 1285;
    bg_pos_data[4][0] = 1305;    bg_pos_data[4][1] = 1336;
    bg_pos_data[5][0] = 1500;    bg_pos_data[5][1] = 1560;
    bg_pos_data[6][0] = 1650;    bg_pos_data[6][1] = 1690;

    double * t0_data = (double *) malloc(numrings * sizeof(double));
    if(t0_data == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    t0_data[0] = 1.739;
    t0_data[0] = 2.011;
    t0_data[0] = 2.847;    
    t0_data[0] = 3.337;
    t0_data[0] = 3.484;
    t0_data[0] = 4.028;
    t0_data[0] = 4.391;

    double I0_data[numrings], H_data = 0.01, eta_data = 0.5, shift_H_data[numrings], shift_eta_data[numrings], bg_int_data[numrings][2];
    double pixel = 100e-6, dist = 1081e-3;

    //variables auxiliares del programa
    int n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)
    i = 0, j = 0;
    int iter = 0;

    //variables del solver
    int status, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;

    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Parametros a fitear
    double * x_init = (double *) malloc(n_param * sizeof(double)); //vector con los valores iniciales de los parametros
    if(x_init == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
//    gsl_vector * param = gsl_vector_alloc(n_param); //vector con los valores finales de los parametros
    
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (numrings, 2); //posicion de los puntos que tomo para calcular el background

    struct data d = {size, numrings, ttheta, y, sigma, bg_pos};

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
//    gsl_matrix * J = gsl_matrix_alloc(size, n_param);//matriz con el jacobiano de la funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante 
        
   
    //obtengo los datos
    y = data(name, size);
    for(i = 0; i < size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, pixel, dist)); //los valores del pixel y de dist deberia sacarlos del para_fit2d.dat
        gsl_vector_set(sigma, i, sqrt(gsl_vector_get(y, i))); //calculo los sigma de las intensidades
    }
    for(i = 0; i < numrings; i++)
    {//sacar los datos del para_fit2d.dat (o de otro archivo si es que pienso poner varios puntos de bg)
        gsl_matrix_set(bg_pos, i, 0, bin2theta(bg_pos_data[i][0], pixel, dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(bg_pos_data[i][1], pixel, dist)); //bin del punto definido bg_right
    }


    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.df = &pv_df;//definicion del jacobiano
    pv.fdf = &pv_fdf;

    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (<= pv.n)
    pv.params = &d; //datos experimentales

    //parametros iniciales
    i = 0;
    x_init[i] = H_data; i++;
    x_init[i] = eta_data; i++;

    
    for(j = 0; j < numrings; j++)
    {
        I0_data[j] = gsl_vector_get(y, theta2bin(2. * t0_data[j], pixel, dist));//fijarse si hay que utilizar la normalizacion por integral o por intensidad maxima
        x_init[i] = I0_data[j]; i++;
           
        x_init[i] = 2. * t0_data[j]; i++;

        shift_H_data[j] = 0.0;
        x_init[i] = shift_H_data[j];    i++;

        shift_eta_data[j] = 0.0;
        x_init[i] = shift_eta_data[j];  i++;

        bg_int_data[j][0] = gsl_vector_get(y, bg_pos_data[j][0]);
        x_init[i] = bg_int_data[j][0];  i++;

        bg_int_data[j][1] = gsl_vector_get(y, bg_pos_data[j][1]);
        x_init[i] = bg_int_data[j][1];  i++;
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear

    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, size, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
    

/*En principio todo este loop es reemplazable por...*/
    //inicio las iteraciones
    print_state (iter, s);

    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);

        printf ("status = %s\n", gsl_strerror (status));

        print_state (iter, s);

        if (status)
            break;

        status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (status == GSL_CONTINUE && iter < max_iter);

/*gsl_multifit_fdfsolver_driver (s, max_iter, err_abs, err_rel)*/
/////////////////////////////////////////////////////////////////////////////////////
//TODAVIA TRATANDO DE ENTENDER QUE PASA ACA
    gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza

//    #define FIT(i) gsl_vector_get(s -> x, i)  
//    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))

    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
//        double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
    
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);//calculo e imprimo el chi2 relativo del ajuste que convirgio

        //printf ("A      = %.5f +/- %.5f\n", FIT(0), c*ERR(0));
        //printf ("lambda = %.5f +/- %.5f\n", FIT(1), c*ERR(1));
        //printf ("b      = %.5f +/- %.5f\n", FIT(2), c*ERR(2));
    }

    printf ("status = %s\n", gsl_strerror (status));
///////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    //gsl_vector_free (param);
    free(x_init);

    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_matrix_free(bg_pos);
    
    gsl_matrix_free(covar);

    gsl_multifit_fdfsolver_free (s);

    printf("God's in his heaven\nAll fine with the world\n");
    return 0;
}
//FIN DEL MAIN

void print_state (size_t iter, gsl_multifit_fdfsolver * s)
{
  printf ("iter: %3u\t|f(x)| = %g\n", iter, gsl_blas_dnrm2 (s->f));
}
