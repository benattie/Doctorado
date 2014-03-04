//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
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

    //variables auxiliares del programa
    int n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)
    int i, iter = 0;

    //variables del solver
    int status;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Parametros a fitear
    gsl_vector * param_init = gsl_vector_alloc(n_param); //vector con los valores iniciales de los parametros
    gsl_vector * param = gsl_vector_alloc(n_param); //vector con los valores finales de los parametros
    
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (numrings, 2); //posicion de los puntos que tomo para calcular el background

    struct data d = {size, numrings, ttheta, y, sigma, bg_pos};

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * J = gsl_matrix_alloc(size, n_param);//matriz con el jacobiano de la funcion a fitear
    gsl_matrix *covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante 
        
   
    //obtengo los datos
    y = data(&name, size);
    for(i = 0; i < size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, 100e-6, 1081e-3)); //los valores del pixel y de dist deberia sacarlos del para_fit2d.dat
        gsl_vector_set(sigma, i, sqrt(gsl_vector_get(y, i))); //calculo los sigma de las intensidades
    }
    for(i = 0; i < numrings; i++)
    {//sacar los datos del para_fit2d.dat (o de otro archivo si es que pienso poner varios puntos de bg)
        gsl_matrix_set(bg_pos, i, 0, bin2theta(0, 100e-6, 1081e-3)); //poner el bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(0, 100e-6, 1081e-3)); //poner el bin del punto definido bg_right
    }


    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.df = &pv_df;//definicion del jacobiano
    pv.fdf = &pv_fdf;

    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (<= pv.n)
    pv.params = &d; //datos experimentales
   
    //parametros iniciales
 

    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, size, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, param_init); //x.vector es el vector con las estimaciones iniciales de los parametros de pv
    
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

        status = gsl_multifit_test_delta (s -> dx, s -> x, 1e-4, 1e-4);
    }
    while (status == GSL_CONTINUE && iter < 500);

/////////////////////////////////////////////////////////////////////////////////////
//TODAVIA TRATANDO DE ENTENDER QUE PASA ACA
    gsl_multifit_covar (s->J, 0.0, covar);

    #define FIT(i) gsl_vector_get(s -> x, i)  
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))

    { 
        double chi = gsl_blas_dnrm2(s->f);
        double dof = n - p;
        double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
    
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);

        //printf ("A      = %.5f +/- %.5f\n", FIT(0), c*ERR(0));
        //printf ("lambda = %.5f +/- %.5f\n", FIT(1), c*ERR(1));
        //printf ("b      = %.5f +/- %.5f\n", FIT(2), c*ERR(2));
    }

    printf ("status = %s\n", gsl_strerror (status));
///////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free (param);
    gsl_vector_free (param_init);

    gsl_vector_free (ttheta);
    gsl_vector_free (y);
    gsl_vector_free (sigma);
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
