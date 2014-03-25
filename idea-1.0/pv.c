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
#include "read_IRF.c"
#include "array_alloc.h"
#include "pv_f.c"

//FUNCIONES
void print_state (int iter, gsl_multifit_fdfsolver * s);
double bin2theta(int bin, double pixel, double dist);
int theta2bin(double theta, double pixel, double dist);

//INICIO DEL MAIN
int pv_fitting(int exists, double dist, double pixel, int size, int numrings, int spr, int gamma, 
                int y_sang[2500], float t0_sang[20], float I0_sang[500][10], int bg_pos_left[15], int bg_pos_right[15],
                 double ** fwhm, double ** eta)
{
    //declaracion de variables y allocacion de memoria
    int n_param = 6 * numrings + 2; //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)
    double * seed;
    if(exists == 1)
    {
        seed = vector_double_alloc(n_param * 2);
    }
    else
    {
        seed = vector_double_alloc(2 + 2 * numrings);
    }
    //variables auxiliares del programa
    int i = 0, j = 0;
    FILE *fp_fit, *fp_IRF, *fp_log;
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
    gsl_matrix * bg_pos = gsl_matrix_alloc (numrings, 2); //posicion de los puntos que tomo para calcular el background (en unidades de angulo)
    //Funcion del fiteo y su jacobiano
    gsl_multifit_function_fdf pv; //funcion a fitear
    gsl_matrix * covar = gsl_matrix_alloc (n_param, n_param);//matriz covariante 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //anchos instrumentales
    fp_IRF = fopen("IRF.dat", "r");
    IRF ins;

    //obtengo los datos
    for(i = 0; i < size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, pixel, dist));//conversion de bin a coordenada angular
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
        fp_fit = fopen(name, "r");
        read_file(exists, fp_fit, seed);
        i = 0;

        x_init[i] = seed[2 * i]; i++;//H global
        x_init[i] = seed[2 * i]; i++;//eta global
        for(j = 0; j < numrings; j++)
        {
            x_init[i] = seed[2 * i]; i++;//theta0
            x_init[i] = seed[2 * i]; i++;//I0
            x_init[i] = seed[2 * i] - seed[0]; i++;//shift_H
            x_init[i] = seed[2 * i] - seed[1]; i++;//shift_eta
            x_init[i] = seed[2 * i]; i++;//bg_left
            x_init[i] = seed[2 * i]; i++;//bg_right
        }
    }
    else
    {//si no hay datos del fiteo anterior uso una plantilla creada a tal fin y los datos del programa de sang bon yi
        char name[20] = "fit_ini.dat";
        fp_fit = fopen(name, "r");
        read_file(exists, fp_fit, seed);
        int k = 0;
        i = 0;

        x_init[i] = seed[k]; i++; k++; //H global
        x_init[i] = seed[k]; i++; k++;//eta global
        for(j = 0; j < numrings; j++)
        {
            x_init[i] = 2. * t0_sang[j]; i++; //--> del t0_sang
            x_init[i] = I0_sang[gamma][j]; i++; //--> del I0_sang
            x_init[i] = seed[k]; i++; k++;//shift_H
            x_init[i] = seed[k]; i++; k++;//shift_eta
            x_init[i] = gsl_vector_get(y, bg_pos_left[j]);  i++; //intensidad del punto de background a la izquierda
            x_init[i] = gsl_vector_get(y, bg_pos_right[j]);  i++; //intensidad del punto de background a la derecha
        }
    }
    gsl_vector_view x = gsl_vector_view_array (x_init, n_param); //inicializo el vector con los datos a fitear
    fclose(fp_fit);

    //inicializo la funcion pseudo-voigt
    pv.f = &pv_f; //definicion de la funcion
    pv.df = NULL; //al apuntar la funcion con el jacobiano de la funcion a NULL, hago que la derivada de la funcion se calcule por el metodo de diferencias finitas
    pv.fdf = NULL; //idem anterior

    pv.n = size; //numero de puntos experimentales
    pv.p = n_param; //variables a fitear (debe cumplir <= pv.n)
    pv.params = &d; //datos experimentales
 
    //inicializo el solver
    T = gsl_multifit_fdfsolver_lmsder;
    s = gsl_multifit_fdfsolver_alloc (T, size, n_param);
    gsl_multifit_fdfsolver_set (s, &pv, &x.vector);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //inicio las iteraciones
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
    fp_log = fopen("logfile.txt", "a");
    if(status != 0)//reportar errores
    {
        printf ("\nError #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
        fprintf(fp_log, "#Error #%d en spr #%d y gamma #%d: %s\n", status, spr, gamma, gsl_strerror (status));
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Escritura de los resultados del fiteo en los vectores fwhm y eta
    //lectura del archivo con los valores de ancho de pico instrumental
    fp_IRF = fopen("IRF.dat", "r");
    ins = read_IRF(fp_IRF);
    fclose(fp_IRF);
    //correccion de los anchos obtenidos del fiteo y escritura a los punteros de salida (fwhm y eta)
    j = 0;
    int bad_fit = 0;
    for(i = 2; i < n_param; i += 6)
    {
        double theta = gsl_vector_get(s -> x, i);
        double * H_corr = vector_double_alloc(1);
        double * eta_corr = vector_double_alloc(1);
        H_corr[0] = gsl_vector_get(s -> x, 0) + gsl_vector_get(s -> x, i + 2);
        eta_corr[0] = gsl_vector_get(s -> x, 1) + gsl_vector_get(s -> x, i + 3);
        double I = gsl_vector_get(s -> x, i + 1);
        double DI = sqrt(gsl_matrix_get(covar, i + 1, i + 1));
        double err_rel = fabs(DI / I);
        if(err_rel > 0.5 || I < 0 || H_corr[0] < 0 || H_corr[0] > 1 || eta_corr[0] < 0 || eta_corr[0] > 1)
        {
            fprintf(fp_log, "#Bad fits:\n#spr\tgamma\tpeak\tDI/I\tI\tH\teta\n%3d\t%5d\t%4d\t%.3lf\t%.3lf\t%.3lf\t%.3lf\n", 
                                              spr, gamma, (i + 4) / 6, err_rel, I, H_corr[0], eta_corr[0]);
            fwhm[gamma][j] = -1.0;
            eta[gamma][j] = -1.0;
            bad_fit = 1;
        }
        else
        {   
            ins_correction(H_corr, eta_corr, ins, theta);
            fwhm[gamma][j] = H_corr[0];
            eta[gamma][j] = eta_corr[0];
        }
        j++;
    }
    fprintf(fp_log, "#-----------------------------------------------------\n");
    fclose(fp_log);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //imprimo los resultados del fiteo
    gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza

    #define FIT(i) gsl_vector_get(s -> x, i)
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))
    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
        double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
        FILE * fp = fopen("fit_data.tmp", "w");
        printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        fprintf(fp, "Global_H:\n%6.5lf %6.5lf\nGlobal_eta:\n%6.5lf %6.5lf\n",  FIT(0), ERR(0), FIT(1), ERR(1));
        i = 2;
        fprintf (fp, "#t0\tsigma\tI\tsigma\tH\tsigma\t\teta\tsigma\t\t\tbg_l\tsigma\tbg_r\tsigma\n");
        if(bad_fit)
        {//si hubo un bad_fit paso como valores iniciales del siguiente fiteo los del anterior
            for(j = 0; j < numrings; j++)
            {
                fprintf (fp, "%.3lf\t-1\t%.3lf\t-1\t%.5lf\t-1\t%.5lf\t-1\t%.3lf\t-1\t%.3lf\t -1\n",
                                x_init[i], x_init[i + 1], x_init[0] + x_init[i + 2],
                                x_init[1] + x_init[i + 3], x_init[i + 4], x_init[i + 5]);
                i+=6;
            }
        }
        else
        {//si el fiteo fue bueno uso los resultados como semilla del fiteo siguiente
            for(j = 0; j < numrings; j++)
            {
                fprintf (fp, "%.3lf\t%.3lf\t%.3lf\t%.3lf\t%.5lf\t%.5lf\t%.5lf\t%.5lf\t%.3lf\t%.3lf\t%.3lf\t%.3lf\n",
                                FIT(i), c * ERR(i), FIT(i + 1), c * ERR(i + 1),
                                FIT(0) + FIT(i + 2), c * sqrt(pow(ERR(0), 2) +  pow(ERR(i + 2), 2)),
                                FIT(1) + FIT(i + 3), c * sqrt(pow(ERR(1), 2) +  pow(ERR(i + 3), 2)),
                                FIT(i + 4), c * ERR(i + 4), FIT(i + 5),  c * ERR(i + 5));
                i+=6;
            }
        }
        fclose(fp);
    }
///////////////////////////////////////////////////////////////////////////////////////
    //liberacion de memoria allocada y cierre de archivos
    free(x_init);
    free(seed);
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
