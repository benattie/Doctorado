//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//GSL
#include <gsl/gsl_vector.h> //funciones de vectores
#include <gsl/gsl_blas.h> //funciones basicas de algebra lineal
#include <gsl/gsl_multifit_nlin.h> //funciones de multifitting

//COSAS MIAS
#include "read_file.c"
#include "pv_f.c"
#include "array_alloc.c"

//FUNCIONES
void print_state (int iter, gsl_multifit_fdfsolver * s);
double bin2theta(int bin, double pixel, double dist);
int theta2bin(double theta, double pixel, double dist);

//MAIN
int pv_fitting(int exists, double dist, double pixel, int size, int numrings, int y_sang[2500],
        float t0_sang[20], float I0_sang[500][10], int bg_pos_left[15], int bg_pos_right[15],
        double ** fwhm, double ** eta)
{
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //declaracion de variables y allocacion de memoria
    double t0_ini[numrings], I0_ini[numrings], H_ini, eta_ini, shift_H_ini[numrings], shift_eta_ini[numrings], bg_int_ini[numrings][2];
    int n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)

    //variables auxiliares del programa
    int i = 0, j = 0;
    FILE * fit_fp;

    //variables del solver
    int status, iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    const gsl_multifit_fdfsolver_type * T;
    gsl_multifit_fdfsolver * s;
    double * x_init = vector_double_alloc(n_param);

    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (numrings, 2); //posicion de los puntos que tomo para calcular el background
    
    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //obtengo los datos
    for(i = 0; i < size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, pixel, dist));
        gsl_vector_set(y, i, y_sang[i]);//tal vez haya que promediar los datos
        gsl_vector_set(sigma, i, sqrt(gsl_vector_get(y, i))); //calculo los sigma de las intensidades
    }

    for(i = 0; i < numrings; i++)
    {
        gsl_matrix_set(bg_pos, i, 0, bin2theta(bg_pos_left[i], pixel, dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(bg_pos_right[i], pixel, dist)); //bin del punto definido bg_right
    }
    size = bg_pos_right[numrings]; //corto los datos en el ultimo punto de background
    struct data d = {size, numrings, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales

    //semillas de los parametros
    if(exists == 1)//si ya tengo los resultados de un fiteo anterior, los uso como semilla del fiteo siguiente
    {
        char name[20] = "fit_data.tmp";
        fit_fp = fopen(name, "r");
        read_file(fit_fp, &H_ini, &eta_ini, &I0_ini, &t0_ini, &shift_H_ini, &shift_eta_ini, &bg_int_ini);

        i = 0;
        x_init[i] = H_ini; i++;
        x_init[i] = eta_ini; i++;
    
        for(j = 0; j < numrings; j++)
        {
            x_init[i] = I0_ini[j]; i++;
            x_init[i] = t0_ini[j]; i++;
            x_init[i] = shift_H_ini[j];    i++;
            x_init[i] = shift_eta_ini[j];  i++;
            x_init[i] = bg_int_ini[j][0];  i++;
            x_init[i] = bg_int_ini[j][1];  i++;
        }
        gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear
    }
    else
    {//si no hay datos del fiteo anterior uso una plantilla creada a tal fin
        char name = "fit_ini.dat";
        read_file(fit_fp, name, exists, &H_ini, &eta_ini, &I0_ini, &t0_ini, &shift_H_ini, &shift_eta_ini, &bg_int_ini);

        i = 0;
        x_init[i] = H_ini; i++; //--> del archivo
        x_init[i] = eta_ini; i++; //--> del archivo
    
        for(j = 0; j < numrings; j++)
        {
            x_init[i] = I0_sang[j]; i++; //--> del I0_sang
            x_init[i] = 2. * t0_sang[j]; i++; //--> del t0_sang
            x_init[i] = shift_H_ini[j];    i++; //--> del archivo
            x_init[i] = shift_eta_ini[j];  i++; //--> del archivo
            
            bg_int_ini[j][0] = gsl_vector_get(y, bg_pos_left[j]);
            x_init[i] = bg_int_ini[j][0];  i++;

            bg_int_ini[j][1] = gsl_vector_get(y, bg_pos_right[j]);
            x_init[i] = bg_int_ini[j][1];  i++;
        }
        gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear
        fclose(fit_fp);
    }

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.df = NULL;
    pv.fdf = NULL;

    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (<= pv.n)
    pv.params = &d; //datos experimentales
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, size, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//imprimo los parametros finales
    gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza

    #define FIT(i) gsl_vector_get(s -> x, i)  
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))
    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
        double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
    
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);//calculo e imprimo el chi2 relativo del ajuste que convirgio
        fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        fprintf(fp, "H   = %.5lf +- %.5lf\n",  FIT(0), ERR(0));
        fprintf(fp, "eta = %.5lf +- %.5lf\n",  FIT(1), ERR(1));
        i = 2;
        fprintf (fp, "#t0\tsigma\tI\tsigma\tH\tsigma\t\teta\tsigma\t\t\tbg_l\tsigma\tbg_r\tsigma\n");
        for(j = 0; j < numrings; j++)
        {
            fprintf (fp, "%.3lf\t%.3lf\t%.3lf\t%.3lf\t%.5lf\t%.5lf\t%.5lf\t%.5lf\t%.3lf\t%.3lf\t%.3lf\t%.3lf\n",
                            FIT(i + 1), c * ERR(i + 1),  FIT(i), c * ERR(i),
                            FIT(0) + FIT(i + 2), c * sqrt(pow(ERR(0), 2) +  pow(ERR(i + 2), 2)),
                            FIT(1) + FIT(i + 3), c * sqrt(pow(ERR(1), 2) +  pow(ERR(i + 3), 2)),
                            FIT(i + 4), c * ERR(i + 4), FIT(i + 5),  c * ERR(i + 5));
            i+=6;
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

//FUNCIONES AUXILIARES
void print_state (int iter, gsl_multifit_fdfsolver * s)
{
  printf ("iter: %3d\t|f(x)| = %g\n", iter, gsl_blas_dnrm2 (s -> f));
}

double bin2theta(int bin, double pixel, double dist)
{
    return atan((double) bin * pixel / dist) * 180. / M_PI;
}

int theta2bin(double theta, double pixel, double dist)
{
    double aux = dist / pixel * tan(theta * M_PI / 180.);
    return (int) aux;
}
