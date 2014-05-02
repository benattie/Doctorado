#include "aux_functions.h"
//Funciones de transformacion angular. De coordenadas de maquina (omega, gamma) a coordenadas de figura de polos (alpha, beta)
float winkel_al(float th, float om, float ga)
{
    float   al,rad,chi,phi;
    double  omr, gar, thr, phir, chir;
    double  COSAL;

    rad = pi / 180;
    chi = 0.0;
    phi = 0.0;
    omr = om * rad;
    gar = ga * rad;
    thr = th * rad;
    phir = phi * rad;
    chir = chi * rad;

    /***the multiplication of matrix G and s */
     COSAL=(  ( (-1 * cos(omr) * sin(phir)) - (sin(omr) * cos(phir) * cos(chir)) ) * (-1 * sin(thr)) )
           + ( (-1 * sin(omr) * sin(phir)) + (cos(omr) * cos(phir) * cos(chir)) ) * (cos(thr) * cos(gar));

     al = (float)(acos(COSAL)) / rad;
     return (al);
}

float winkel_be(float thb, float omb, float gab, float alb)
{
    float   be,rad_be,chi_be,phi_be;
    double  thbr, ombr, gabr, albr, phibr, chibr;
    double  SINALCOSBE,COSBE,SINALSINBE,SINBE;
    
    rad_be = pi / 180;
    chi_be = 0.0;
    phi_be = 0.0;
    thbr = thb * rad_be;
    ombr = omb * rad_be;
    gabr = gab * rad_be;
    albr = alb * rad_be;
    chibr = chi_be * rad_be;
    phibr = phi_be * rad_be;

    /*** the multiplication of matrix G and s */

    SINALCOSBE
    = ( cos(ombr)*(-1 * sin(thbr)) ) + ( ( (sin(ombr) * cos(phibr)) + (cos(ombr) * sin(phibr) * cos(chibr)) ) * (cos(thbr) * cos(gabr)) );

    COSBE = SINALCOSBE / sin(albr);

    SINALSINBE = cos(thbr) * sin(gabr);

    SINBE = SINALSINBE / sin(albr);

    if(COSBE > 1.0)
    {
        be = 0.0;
        COSBE = 1;
    }
    if(COSBE < -1)
    {
        be = 180.0;
        COSBE = -1;
    }

    if(SINBE < 0)
        be = (float) 360 - ( acos(COSBE) / rad_be );
    else
        be = (float) acos(COSBE) / rad_be;

    if((omb == 0) && (be > 270.0))
        be = 360 - be;
    if((omb == 0) && (be <= 80.0))
        be = 360 - be;

    return (be);
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

void print_state (int iter, gsl_multifit_fdfsolver * s)
{
    printf ("iter: %3d\t|f(x)| = %g\n", iter, gsl_blas_dnrm2 (s -> f));
}

void print_seeds(double * seeds, int seeds_size, double ** bg, int bg_size)
{
    int i;
    printf("%3.5lf  %3.5lf\n", seeds[0], seeds[1]);
    for(i = 2; i < seeds_size; i += 4)
        printf("%3.5lf  %3.5lf  %3.5lf  %3.5lf\n", seeds[i], seeds[i + 1], seeds[i + 2], seeds[i + 3]);
    for(i = 0; i < bg_size; i++)
        printf("%3.3lf ", bg[0][i]);
    printf("\n");
    for(i = 0; i < bg_size; i++)
        printf("%3.3lf ", bg[1][i]);
    printf("\n");
    getchar();
}

void print_seeds2file(FILE * fp, double * seeds, int seeds_size, double ** bg, int bg_size)
{
    int i;
    fprintf(fp, "%3.5lf  %3.5lf\n", seeds[0], seeds[1]);
    for(i = 2; i < seeds_size; i += 4)
        fprintf(fp, "%3.5lf  %3.5lf  %3.5lf  %3.5lf\n", seeds[i], seeds[i + 1], seeds[i + 2], seeds[i + 3]);
    for(i = 0; i < bg_size; i++)
        fprintf(fp, "%3.3lf ", bg[0][i]);
    fprintf(fp, "\n");
    for(i = 0; i < bg_size; i++)
        fprintf(fp, "%3.3lf ", bg[1][i]);
    fprintf(fp, "\n---------------------------\n");

}

void reset_single_seed(double ** seeds, int index)
{
    seeds[1][index] = seeds[0][index];
}

void reset_global_seeds(double ** seeds)
{
    seeds[1][0] = seeds[0][0];
    seeds[1][1] = seeds[0][1];
}

void reset_peak_seeds(double ** seeds, int peak_index)
{
    int i;
    for(i = peak_index; i < peak_index + 4; i++)
        seeds[1][i] = seeds[0][i];
}

void reset_bg_seeds(gsl_vector * y, double ** bg, int size)
{
    int i;
    for(i = 0; i < size; i++)
        bg[1][i] = gsl_vector_get(y, bg[0][i]);
}

void reset_all_seeds(gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size)
{
    int i;
    reset_global_seeds(seeds);
    for(i = 0; i < n_peaks; i++)
        reset_peak_seeds(seeds, i);
    reset_bg_seeds(y, bg, bg_size);
}

void check(gsl_vector * y, double ** seeds, int seeds_size, int n_peaks, double ** bg, int bg_size)
{
    int i;
    double H_global = seeds[1][0];
    double eta_global = seeds[1][1];
    if(H_global < 0 || H_global > 1)
    {
        reset_all_seeds(y, seeds, seeds_size, n_peaks, bg, bg_size);
    }
    else
    {
        if(eta_global < 0 || eta_global > 1)
            seeds[1][1] = seeds[0][1];

        for(i = 2; i < seeds_size; i += 4)
        {
            double dtheta = fabs(seeds[1][i] - seeds[0][i]);
            double I = seeds[1][i + 1];
            double shift_H = fabs(seeds[1][i + 2]);
            double shift_eta = fabs(seeds[1][i + 3]);
            if(I < 0 || shift_H > 2 || shift_eta > 2 || dtheta > 2)
                reset_peak_seeds(seeds, i);
        }
    }
}

//Esta funcion revisa si hay elementos de intens que esten por debajo de treshold y devuelve el numero de picos que efectivamente tiene el difractograma.
int check_for_null_peaks(float treshold, int numrings, int * zero_peak_index, float * intens)
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

    for(i = 2; i < size; i += 4)
    {
        if(zero_peak_index[l] == 0)
        {
            for(k = 0; k < 4; k++)
            {
                peak_seeds[0][j + k] = seeds[0][i + k];
                peak_seeds[1][j + k] = seeds[exists][i + k];
            }
            j += 4;
        }
        l++;
    }
}

void set_seeds_back(int size, int * zero_peak_index, int exists, double ** seeds, double ** peak_seeds)
{
    int i, j = 2, k, l = 0;
    seeds[1][0] = peak_seeds[1][0];
    seeds[1][1] = peak_seeds[1][1];

    for(i = 2; i < size; i += 4)
    {
        if(zero_peak_index[l] == 0)
        {
            for(k = 0; k < 4; k++)
                seeds[1][i + k] = peak_seeds[1][j + k];
            j += 4;
        }
        l++;
    }
}

void average(float * intens_av, float * peak_intens_av, int n_av, int size, int numrings)
{
    int i;
    for(i = 0; i < size; i++)
        intens_av[i] /= n_av;

    for(i = 0; i < numrings; i++)
        peak_intens_av[i] /= n_av;
}

void solver_iterator(int * status, gsl_multifit_fdfsolver * s, const gsl_multifit_fdfsolver_type * T)
{
    int iter = 0, max_iter = 500;
    double err_abs = 1e-4, err_rel = 1e-4;
    //print_state (iter, s);
    do
    {
        iter++;
        *status = gsl_multifit_fdfsolver_iterate (s);
        //printf ("status = %s\n", gsl_strerror (*status));
        //print_state (iter, s);
        if (*status)
            break;
        *status = gsl_multifit_test_delta (s -> dx, s -> x, err_abs, err_rel);
    }
    while (*status == GSL_CONTINUE && iter < max_iter);
    //printf ("status = %s\n", gsl_strerror (*status));
    //print_state (iter, s);
}

int fit_result(int all_seeds_size, double ** peak_seeds, int * zero_peak_index, exp_data * sync_data, peak_data * difra)
{//habria que ver si efectivamente le estoy pasando los valores mas proximos
    int bad_fit;
    if((*difra).gamma == (*difra).start_gam)
    {
        if((*difra).spr == (*difra).start_spr)
            bad_fit = results_output(all_seeds_size, peak_seeds, zero_peak_index, sync_data, difra, 0, 0); //en el indice 0,0 puse un -1
        else
            bad_fit = results_output(all_seeds_size, peak_seeds, zero_peak_index, sync_data, difra, (*difra).gamma, (*difra).spr - 1);
    }
    else
        bad_fit = results_output(all_seeds_size, peak_seeds, zero_peak_index, sync_data, difra, (*difra).gamma - 1, (*difra).spr);

    return bad_fit;
}

int results_output(int all_seeds_size, double ** peak_seeds, int * zero_peak_index, exp_data * sync_data, peak_data * difra, int spr, int gamma)
{
    int bad_fit = 0, i, j = 2, k = 0;
    double I, I_aux, H, H_aux, eta, eta_aux;
    for(i = 2; i < all_seeds_size; i += 4)
    {
        if(zero_peak_index[k] == 0)
        {
            I_aux = peak_seeds[1][j + 1];
            H_aux = peak_seeds[1][0] + peak_seeds[1][j + 2];
            eta_aux = peak_seeds[1][1] + peak_seeds[1][j + 3];
            if(I_aux < 0)
            {
                bad_fit = 1;
                I = 0.0;
                H = (*difra).fwhm[spr][gamma][k];
                eta = (*difra).eta[spr][gamma][k];
            }
            else
            {
                if(H_aux < 0 || H_aux > 1)
                {
                    bad_fit = 1;
                    I = I_aux;
                    H = (*difra).fwhm[spr][gamma][k];
                    eta = (*difra).eta[spr][gamma][k];
                }
                else
                {
                    if(eta_aux < 0 || eta_aux > 1)
                    {
                        bad_fit = 1;
                        I = I_aux;
                        H = H_aux;
                        eta = (*difra).eta[spr][gamma][k];
                    }
                    else
                    {
                        bad_fit = 0;
                        I = I_aux;
                        H = H_aux;
                        eta = eta_aux;
                    }
                }
            }//end if routine if(I_aux < 0)
            //double theta_rad = (peak_seeds[1][j] / 2.) * M_PI / 180.; //2theta en grados -> THETA en RADIANES
            //ins_correction(&H, &eta, (*sync_data).ins, theta_rad);
            (*difra).intens[(*difra).spr][(*difra).gamma][k] = I;
            (*difra).fwhm[(*difra).spr][(*difra).gamma][k] = H;
            (*difra).eta[(*difra).spr][(*difra).gamma][k] = eta;
            j += 4;
        }
        else
        {
            (*difra).intens[(*difra).spr][(*difra).gamma][k] = 0.0;
            (*difra).fwhm[(*difra).spr][(*difra).gamma][k] = 0.0;
            (*difra).eta[(*difra).spr][(*difra).gamma][k] = 0.0;
        }//end if routine if(zero_peak_index[k] == 0)
        k++;
    }//end for routine for(i = 2; i < all_seeds_size; i += 4)
    return bad_fit;
}
