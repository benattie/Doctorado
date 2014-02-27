//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting

//COSAS MIAS
#include <read_file.c>

//MAIN
int main(void){
    //variables de entrada (algunas no van a ser necesarias cuando incorpore todo al programa de sangbong)
    char name[15] = "dif000.dat"; //no va a hacer falta cuando corra el programa de sangbong
    size_t size = 1725; //sacar del programa de sangbong
    int numrings = 7; //sacar del programa de sangbong

    //variables del solver
    const gsl_multifit_fsolver_type *T;
    gsl_multifit_fsolver *s;

    gsl_vector * param_init = gsl_vector_alloc(n_param); //vector con los valores iniciales de los parametros
    gsl_vector * param = gsl_vector_alloc(n_param); //vector con los valores finales de los parametros

    gsl_vector * ttheta = gsl_vector_alloc(size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(size); //intensidades del difractograma
    struct data d = {n, ttheta, y, sigma};

    gsl_multifit_function_f pv; //funcion a fitear
        
    //variables auxiliares del programa
    size_t n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)
    int i, iter = 0;
   

    //obtengo los datos
    y = data(&name, size);
    for(i = 0; i < size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, 100e-6, 1081e-3)); //los valores del pixel y de dist deberia sacarlos del para_fit2d.dat
        gsl_vector_set(sigma, i, sqrt(gsl_vector_get(y, i))); //calculo los sigma de las intensidades
    }
    

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear
    pv.params = &d; //datos experimentales
    

    //inicializo el solver
    T = gsl_multifit_fsolver_lmsder;
    s = gsl_multifit_fsolver_alloc (T, n, p);
    gsl_multifit_fsolver_set (s, &pv, param_init); //x.vector es el vector con las estimaciones iniciales de los parametros de pv
    
    //inicio las iteraciones
    do
    {
        iter++;
        status = gsl_multifit_fdfsolver_iterate (s);

        printf ("status = %s\n", gsl_strerror (status));

        print_state (iter, s);

        if (status)
            break;

        status = gsl_multifit_test_delta (s->dx, s->x, 1e-4, 1e-4);
    }
    while (status == GSL_CONTINUE && iter < 500);


    //liberacion de memoria allocada y cierre de archivos
    gsl_vector_free (param);
    gsl_vector_free (param_init);
    gsl_vector_free (ttheta);
    gsl_vector_free (y);
    gsl_vector_free (sigma);
    gsl_multifit_fsolver_free (s);

    printf("God's in his heaven\nAll fine with the world\n");
    return 0;
}
//FIN DEL MAIN

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

/*
void print_state (size_t iter, gsl_multifit_fdfsolver * s)
{
    printf ("iter: %3u x = % 15.8f % 15.8f % 15.8f "
        "|f(x)| = %g\n",
        iter,
        gsl_vector_get (s->x, 0), 
        gsl_vector_get (s->x, 1),
        gsl_vector_get (s->x, 2), 
        gsl_blas_dnrm2 (s->f));
}
*/

    /*
    FILE *  fout;
    if((fout = fopen("intens.dat","w")) == NULL )
    {//abro el archivo
        fprintf(stderr,"Error opening file(intens.dat).");
        exit(1);
    }
    
    for (i = 0; i < size; i++)
    {
        fprintf (fout, "y_%d = %g\n", i, gsl_vector_get (y, i));
    }
    */
