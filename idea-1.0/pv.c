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
#include "pv_steps.c"
#include "pv_f.c"

//FUNCIONES
double bin2theta(int bin, double pixel, double dist);
int theta2bin(double theta, double pixel, double dist);

//ESTRUCTURAS PROPIAS
typedef struct exp_data
{
    double dist;
    double pixel;
    int size;
    IRF ins;
} exp_data;

typedef struct peak_data
{
    int numrings;
    int spr;
    int gamma;
    float intensity[2500];
    int bg_left[15];
    int bg_right[15];
    double ** fwhm;
    double ** eta;
} peak_data;

//INICIO DEL MAIN
void pv_fitting(int exists, exp_data sync_data, peak_data difra)
{
    //DECLARACION DE VARIABLES Y ALLOCACION DE MEMORIA
    //numero de parametros a fitear (tengo 6 parametros por pico ademas del eta y el fwhm)    
    int n_param[4] = {4 * difra.numrings + 1, 5 * difra.numrings + 1, 5 * difra.numrings + 2, 6 * difra.numrings + 1};
    //variables auxiliares del programa
    int i = 0, j = 0;
    FILE *fp_fit, *fp_bflog;
    //Parametros fijos
    gsl_vector * ttheta = gsl_vector_alloc(sync_data.size); //valores de 2theta
    gsl_vector * y = gsl_vector_alloc(sync_data.size); //intensidades del difractograma
    gsl_vector * sigma = gsl_vector_alloc(sync_data.size); //error de las intensidades del difractograma
    gsl_matrix * bg_pos = gsl_matrix_alloc (difra.numrings, 2); //posicion de los puntos que tomo para calcular el background (en unidades de angulo)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //obtengo los datos
    sync_data.size = difra.bg_right[difra.numrings - 1];//leo hasta el ultimo punto de background
    for(i = 0; i < sync_data.size; i++)
    {
        gsl_vector_set(ttheta, i, bin2theta(i, sync_data.pixel, sync_data.dist));//conversion de bin a coordenada angular
        gsl_vector_set(y, i, difra.intensity[i]);//tal vez haya que promediar los datos
        gsl_vector_set(sigma, i, sqrt(difra.intensity[i])); //calculo los sigma de las intensidades
    }

    for(i = 0; i < difra.numrings; i++)
    {
        gsl_matrix_set(bg_pos, i, 0, bin2theta(difra.bg_left[i], sync_data.pixel, sync_data.dist)); //bin del punto definido bg_left
        gsl_matrix_set(bg_pos, i, 1, bin2theta(difra.bg_right[i], sync_data.pixel, sync_data.dist)); //bin del punto definido bg_right
    }

    struct data d = {sync_data.size, difra.numrings, ttheta, y, sigma, bg_pos}; //estructura que contiene los datos experimentales
    
    pv_step1(exists, &sync_data, &difra, seeds, &d, n_param[0]);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Correccion de los resultados\n");
    //Escritura de los resultados del fiteo en los vectores fwhm y eta
    
    //correccion de los anchos obtenidos del fiteo y escritura a los punteros de salida (fwhm y eta)
    j = 0;
    int bad_fit = 0;
    fp_bflog = fopen("logfile.txt", "a");
    gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza
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
            fprintf(fp_bflog, "%3d    %5d    %4d    %5.3lf    %8.3lf    %8.5lf    %8.5lf\n", spr, gamma, (i + 4) / 6, err_rel, I, H_corr[0], eta_corr[0]);
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
    fclose(fp_bflog);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //printf("Impresion de los resultados\n");
    //imprimo los resultados del fiteo
    //gsl_multifit_covar (s -> J, 0.0, covar); //calculo la matriz de covarianza
    #define FIT(i) gsl_vector_get(s -> x, i)
    #define ERR(i) sqrt(gsl_matrix_get(covar, i, i))
    { 
        double chi = gsl_blas_dnrm2(s -> f);
        double dof = size - n_param;
        //double c = GSL_MAX_DBL(1, chi / sqrt(dof)); 
        FILE * fp = fopen("fit_data.tmp", "w");
        //printf("chisq/dof = %g\n",  pow(chi, 2.0) / dof);
        if(bad_fit)
        {//si hubo un bad_fit paso como valores iniciales del siguiente fiteo los del anterior
            //printf ("\nBad fit in spr #%d and gamma #%d with status %s(%d)\n", spr, gamma, gsl_strerror (status), status);
            fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);
            fprintf(fp, "Global_H:\n%6.5lf -1\nGlobal_eta:\n%6.5lf -1\n",  x_init[0], x_init[1]);
            i = 2;
            fprintf (fp, "#t0    sigma    I    sigma    H    sigma    eta    sigma    bg_l    sigma    bg_r    sigma\n");
            for(j = 0; j < numrings; j++)
            {
                fprintf (fp, "%.3lf   -1    %.3lf    -1    %.5lf    -1    %.5lf    -1    %.3lf    -1    %.3lf    -1\n",
                                x_init[i], x_init[i + 1], x_init[0] + x_init[i + 2],
                                x_init[1] + x_init[i + 3], x_init[i + 4], x_init[i + 5]);
                i += 6;
            }
        }
        else
        {//si el fiteo fue bueno uso los resultados como semilla del fiteo siguiente
            fprintf(fp, "chisq/dof = %g\n",  pow(chi, 2.0) / dof);
            fprintf(fp, "Global_H:\n%6.5lf %6.5lf\nGlobal_eta:\n%6.5lf %6.5lf\n",  FIT(0), ERR(0), FIT(1), ERR(1));
            i = 2;
            fprintf (fp, "#t0    sigma    I    sigma    H    sigma    eta    sigma    bg_l    sigma    bg_r    sigma\n");
            for(j = 0; j < numrings; j++)
            {
                fprintf (fp, "%.3lf    %.3lf    %.3lf    %.3lf    %.5lf    %.5lf    %.5lf    %.5lf    %.3lf    %.3lf    %.3lf    %.3lf\n",
                                FIT(i), ERR(i), FIT(i + 1), ERR(i + 1),
                                FIT(0) + FIT(i + 2), sqrt(pow(ERR(0), 2) +  pow(ERR(i + 2), 2)),
                                FIT(1) + FIT(i + 3), sqrt(pow(ERR(1), 2) +  pow(ERR(i + 3), 2)),
                                FIT(i + 4), ERR(i + 4), FIT(i + 5),  ERR(i + 5));
                i += 6;
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

    //printf("\nGod's in his heaven\nAll fine with the world\n");
    if((gamma % 30) == 0) printf("\nFin (%d %d)\n", spr, gamma);//imprimo progreso
    //return 0;
}
//FIN DEL MAIN

//FUNCIONES AUXILIARES
double bin2theta(int bin, double pixel, double dist)
{
    return atan((double) bin * pixel / dist) * 180. / M_PI;
}

int theta2bin(double theta, double pixel, double dist)
{
    double aux = dist / pixel * tan(theta * M_PI / 180.);
    return (int) aux;
}
