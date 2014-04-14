#include "aux_functions.h"


double bin2theta(int bin, double pixel, double dist)
{
    return atan((double) bin * pixel / dist) * 180. / M_PI;
}

int theta2bin(double theta, double pixel, double dist)
{
    double aux = dist / pixel * tan(theta * M_PI / 180.);
    return (int) aux;
}

void print_state (int iter, gsl_multifit_fdfsolver * s)
{
    printf ("iter: %3d\t|f(x)| = %g\n", iter, gsl_blas_dnrm2 (s -> f));
}


void reset_all_seeds(double ** seeds, int size)
{
    int i;
    for(i = 0; i < size; i++)
        seeds[1][i] = seeds[0][i];
}

//reseteo todas las semillas menos la posicion del pico
void reset_almost_all_seeds(double ** seeds, int size)
{
    int i, j;
    reset_global_seeds(seeds);
    for(i = 2; i < size; i += 6)
    {
        for(j = 1; j < 6; j++)
            seeds[1][i + j] = seeds[0][i + j];
    }
        
}

void reset_peak_seeds(double ** seeds, int index)
{
    int i;
    for(i = index; i < index + 4; i++)
        seeds[1][i] = seeds[0][i];
}

void reset_global_seeds(double ** seeds)
{
    seeds[1][0] = seeds[0][0];
    seeds[1][1] = seeds[0][1];
}

void reset_single_seed(double ** seeds, int index)
{
    seeds[1][index] = seeds[0][index];
}

void check (double ** seeds, int size)
{
    int i;
    double H_global = seeds[1][0];
    double eta_global = seeds[1][1];
    if(H_global < 0 || H_global > 1)
    {
        reset_all_seeds(seeds, size);
    }
    else
    {
        if(eta_global < 0 || eta_global > 1)
            seeds[1][1] = seeds[0][1];

        for(i = 2; i < size; i += 6)
        {
            double dtheta = fabs(seeds[1][i] - seeds[0][i]);
            double I = seeds[1][i + 1];
            double shift_H = fabs(seeds[1][i + 2]);
            double shift_eta = fabs(seeds[1][i + 3]);
            if(I < 0 || shift_H > 1 || shift_eta > 1 || dtheta > 2)
                reset_peak_seeds(seeds, i);
        }
    }
}

//Esta funcion revisa si hay elementos de intens que esten por debajo de treshold.
//Luego reacomoda en peak_seeds los elementos de seeds que NO corresponden a un pico nulo.
//Finalmente devuelve el numero de picos que efectivamente tiene el difractograma.
int check_for_null_peaks (float treshold, int numrings, int * zero_peak_index, float * intens)
{
    int i;
    int n_zero = 0, n_peaks;
    memset(zero_peak_index, 0, numrings * sizeof(int));
    //control por picos nulos
    for(i = 0; i < numrings; i++)
    {
        if(intens[i] < treshold)
        {
            zero_peak_index[i] = 1;
            n_zero++;
        }
    }
    n_peaks = numrings - n_zero;
    return n_peaks;
}

void set_seeds(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds)
{
    int i, j = 2, k, l = 0;
    peak_seeds[0][0] = seeds[0][0];
    peak_seeds[1][0] = seeds[exists][0];

    peak_seeds[0][1] = seeds[0][1];
    peak_seeds[1][1] = seeds[exists][1];


    for(i = 2; i < size; i += 6)
    {
        if(zero_peak_index[l] == 0)
        {
            for(k = 0; k < 6; k++)
            {
                peak_seeds[0][j + k] = seeds[0][i + k];
                peak_seeds[1][j + k] = seeds[exists][i + k];
            }
            j += 6;
        }
        l++;
    }
}
/*
void set_bg_pos(int n_peaks, int * zero_peak_index, int * bg_left, int * bg_right, int ** peak_bg)
{
    int i, j = 0;
    for(i = 0; i < n_peaks; i++)
    {
        if(zero_peak_index[i] == 0)
        {
            peak_bg[0][j] = bg_left[i];
            peak_bg[1][j] = bg_right[i];
            j++;
        }
    }
}
*/
void reset_seeds(int size, double * peak_seeds, int * zero_peak_index, double ** seeds)
{
    int i, j = 2, k;
    seeds[1][0] = peak_seeds[0];
    seeds[1][1] = peak_seeds[1];

    for(i = 2; i < size; i += 6)
    {
        if(zero_peak_index[(i / 6)] == 0)
        {
            for(k = 0; k < 6; k++)
                seeds[1][i + k] = peak_seeds[j + k];
            j += 6;
        }
    }
}

void average(float * intens_av, float * peak_intens_av, int n_av, int size, int numrings)
{
    int i;
    for(i = 0; i < size; i++)
    {
        intens_av[i] /= n_av;
    }
    for(i = 0; i < numrings; i++)
    {
        peak_intens_av[i] /= n_av;
    }
}


