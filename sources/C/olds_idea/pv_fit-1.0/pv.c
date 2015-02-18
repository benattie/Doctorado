//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting
void print_state (int iter, gsl_multifit_fdfsolver * s);

//COSAS MIAS
#include "read_file.c"
#include "pv_f.c"
#include "array_alloc.c"

//MAIN
int main(void){
    //variables de entrada (algunas no van a ser necesarias cuando incorpore todo al programa de sangbong)
    char name[15] = "dif000.dat"; //no va a hacer falta cuando corra el programa de sangbong
    int size = 1725; //sacar del programa de sangbong
    int numrings = 7; //sacar del programa de sangbong
    int i, j;
    //estimacion inicial de los parametros del fiteo (sacar del para_fit2d.dat o de un archivo externo)
    int ** bg_pos_data = matrix_int_alloc(numrings, 2);
    bg_pos_data[0][0] = 630;    bg_pos_data[0][1] = 684;
    bg_pos_data[1][0] = 730;    bg_pos_data[1][1] = 790;
    bg_pos_data[2][0] = 1060;    bg_pos_data[2][1] = 1094;
    bg_pos_data[3][0] = 1240;    bg_pos_data[3][1] = 1285;
    bg_pos_data[4][0] = 1305;    bg_pos_data[4][1] = 1336;
    bg_pos_data[5][0] = 1500;    bg_pos_data[5][1] = 1560;
    bg_pos_data[6][0] = 1650;    bg_pos_data[6][1] = 1690;

    double * t0_data = vector_double_alloc(numrings);
    t0_data[0] = 1.739;
    t0_data[1] = 2.011;
    t0_data[2] = 2.847;    
    t0_data[3] = 3.337;
    t0_data[4] = 3.484;
    t0_data[5] = 4.028;
    t0_data[6] = 4.389;

    double I0_data[numrings], H_data = 0.02000, eta_data = 0.100000, shift_H_data[numrings], shift_eta_data[numrings], bg_int_data[numrings][2];
    double pixel = 100e-6, dist = 1081e-3;

    int n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm) (sacar del fit2d)
    //variables auxiliares del programa
    i = 0, j = 0;
    
    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    FILE * fp;

    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;

    //Parametros a fitear
    double * x_init = vector_double_alloc(n_param);
    
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (numrings, 2); //posicion de los puntos que tomo para calcular el background

    

    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante 
        
    //obtengo los datos
    data(name, size, ttheta, y);
    size = bg_pos_data[6][1] + 1; //corto los datos en el ultimo punto de background
                             // de esta manera evito problemas que me dan los picos espurios
    for(i = 0; i < size; i++)
    {
        //gsl_vector_set(ttheta, i, bin2theta(i, pixel, dist)); //los valores del pixel y de dist deberia sacarlos del para_fit2d.dat
        gsl_vector_set(sigma, i, sqrt(gsl_vector_get(y, i))); //calculo los sigma de las intensidades
    }

    for(i = 0; i < numrings; i++)
    {//sacar los datos del para_fit2d.dat (o de otro archivo si es que pienso poner varios puntos de bg)
        gsl_matrix_set(bg_pos, i, 0, bin2theta(bg_pos_data[i][0], pixel, dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(bg_pos_data[i][1], pixel, dist)); //bin del punto definido bg_right
        //printf("%d\t%lf\t%d\t%lf\n", bg_pos_data[i][0], gsl_matrix_get(bg_pos, i, 0), bg_pos_data[i][1], gsl_matrix_get(bg_pos, i, 1));
    }

    struct data d = {size, numrings, ttheta, y, sigma, bg_pos};
    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.df = NULL;
    pv.fdf = NULL;

    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (<= pv.n)
    pv.params = &d; //datos experimentales
  
    //parametros iniciales
    i = 0;
    x_init[i] = H_data; i++;
    x_init[i] = eta_data; i++;
    
    I0_data[0] = 6.27; I0_data[1] = 120.81; I0_data[2] = 1.41;
    I0_data[3] = 13.24; I0_data[4] = 1.20; I0_data[5] = 10.40;
    I0_data[6] = 1.12; 

    for(j = 0; j < numrings; j++)
    {
        //I0_data[j] = gsl_vector_get(y, theta2bin(2. * t0_data[j], pixel, dist));//fijarse si hay que utilizar la normalizacion por integral o por intensidad maxima
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

    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);//error aca

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//imprimo los parametros iniciales
    if((fp = fopen("fit.dat", "w")) == NULL )
    {
        fprintf(stderr,"Error opening file(fit.dat).\n");
        exit(1);
    }
    #define FIT(i) gsl_vector_get(s -> x, i)
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))
    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
        
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        fprintf(fp, "Parametros iniciales:\n");
        fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        
        i = 2;
        fprintf (fp, "t0\tI\tH\teta\tbg_left\tbg_right\n");
        for(j = 0; j < numrings; j++)
        {
            fprintf (fp, "%.3lf\t%.3lf\t%.5lf\t%.5lf\t%.3lf\t%.3lf\n", 
                            FIT(i + 1), FIT(i), FIT(0) + FIT(i + 2), FIT(1) + FIT(i + 3), FIT(i + 4), FIT(i + 5));
            i+=6;
            /*
            fprintf (fp, "%.3lf\t", FIT(i));
            i++;
            fprintf (fp, "%.5lf\t", FIT(0) + FIT(i));
            i++;
            fprintf (fp, "%.5lf\t", FIT(1) + FIT(i));
            i++;
            fprintf (fp, "%.3lf\t", FIT(i));
            i++;
            fprintf (fp, "%.3lf\n\n", FIT(i));
            i++;
            */
        }
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////////
//imprimo los parametros finales
    gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza

    #define FIT(i) gsl_vector_get(s -> x, i)  
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))
    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
        double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
    
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);//calculo e imprimo el chi2 relativo del ajuste que convirgio
        fprintf(fp, "Parametros finales:\n\n");
        fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);

        i = 2;
         fprintf (fp, "t0\tsigma\tI\tsigma\tH\tsigma\t\teta\tsigma\t\t\tbg_l\tsigma\tbg_r\tsigma\n");
        for(j = 0; j < numrings; j++)
        {
            fprintf (fp, "%.3lf\t%.3lf\t%.3lf\t%.3lf\t%.5lf\t%.5lf\t%.5lf\t%.5lf\t%.3lf\t%.3lf\t%.3lf\t%.3lf\n",
                            FIT(i + 1), c * ERR(i + 1),  FIT(i), c * ERR(i),
                            FIT(0) + FIT(i + 2), c * sqrt(pow(ERR(0), 2) +  pow(ERR(i + 2), 2)),
                            FIT(1) + FIT(i + 3), c * sqrt(pow(ERR(1), 2) +  pow(ERR(i + 3), 2)),
                            FIT(i + 4), c * ERR(i + 4), FIT(i + 5),  c * ERR(i + 5));
            i+=6;
            /* Imprimo los datos con los errores
             c * sqrt(pow(ERR(0), 2) +  pow(ERR(i + 2), 2))
             *
            printf ("I[%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            printf ("t0[%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            printf ("shift_H[%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            printf ("shift_eta[%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            printf ("bg_int_data[0][%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            printf ("bg_int_data[1][%d]      = %.5lf +/- %.5lf\n", j, FIT(i), c * ERR(i)); i++;
            */
            /*
            fprintf (fp, "%.3lf\t", FIT(i));
            i++;
            
            fprintf (fp, "%.3lf\t", FIT(i));
            i++;

            fprintf (fp, "%.5lf\t", FIT(0) + FIT(i));
            i++;

            fprintf (fp, "%.5lf\t", FIT(1) + FIT(i));
            i++;

            fprintf (fp, "%.3lf\t", FIT(i));
            i++;

            fprintf (fp, "%.3lf\n\n", FIT(i));
            i++;*/

        }   
    }
    printf ("status = %s\n", gsl_strerror (status));
///////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    free(x_init);
    free(t0_data);
    free_int_matrix(bg_pos_data, numrings);
    fclose(fp);

    gsl_vector_free(ttheta);
    gsl_vector_free(y);
    gsl_vector_free(sigma);
    gsl_matrix_free(bg_pos);
    
    gsl_matrix_free(covar);

    gsl_multifit_fdfsolver_free (s);

    printf("\nGod's in his heaven\nAll fine with the world\n");
    return 0;
}
//FIN DEL MAIN

void print_state (int iter, gsl_multifit_fdfsolver * s)
{
  printf ("iter: %3d\t|f(x)| = %g\n", iter, gsl_blas_dnrm2 (s -> f));
}
