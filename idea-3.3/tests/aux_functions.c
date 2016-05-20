#include "aux_functions.h"
//Funciones de transformacion angular. De coordenadas de maquina (omega, gamma) a coordenadas de figura de polos (alpha, beta)
double winkel_al(double th, double om, double ga)
{
    double   al, rad;
    double  omr, gar, thr;
    double  COSAL;

    rad = pi / 180;
    omr = om * rad;
    gar = ga * rad;
    thr = th * rad;

    /***the multiplication of matrix G and s */
     COSAL = sin(omr) * sin(thr) + cos(omr) * cos(thr) * cos(gar);
     al = (double)(acos(COSAL)) / rad;
     return al;
}

double winkel_be(double thb, double omb, double gab, double alb)
{
    double  be, rad;
    double  thbr, ombr, gabr, albr;
    double  SINALCOSBE, COSBE, SINALSINBE, SINBE;
    
    rad = pi / 180;
    thbr = thb * rad;
    ombr = omb * rad;
    gabr = gab * rad;
    albr = alb * rad;

    /*** the multiplication of matrix G and s */
    SINALCOSBE = -1* cos(ombr) * sin(thbr) + sin(ombr) * cos(thbr) * cos(gabr);
    
    COSBE = SINALCOSBE / sin(albr);

    SINALSINBE = cos(thbr) * sin(gabr);

    SINBE = SINALSINBE / sin(albr);
    
    be = -1;
    if(COSBE >= 1.0)
    {
        be = 0.0;
        COSBE = 1.0;
    }
    if(COSBE <= -1.0)
    {
        be = 180.0;
        COSBE = -1.0;
    }
    if(be == -1){
        if(COSBE >= 0){
            if(SINBE >= 0)
                be = (double) (acos(COSBE) / rad);
            else
                be = (double) (360 + asin(SINBE) / rad);
        }else{
             if(SINBE >= 0)
                be = (double) (acos(COSBE) / rad);
            else
                be = (double) (360 + atan2(SINBE, COSBE) / rad);
        }
    }
    return be;
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

void print_seeds2file(FILE * fp, double * seeds, double * errors, int seeds_size, double ** bg, int bg_size)
{
    int i;
    fprintf(fp, "H        err        eta      err\n");
    fprintf(fp, "%7.5lf  %7.5lf    %7.5lf  %7.5lf\n", seeds[0], errors[0], seeds[1], errors[1]);
    fprintf(fp, "theta0   err        Int      err        Shif_H   err        Sh_eta  err\n");
    for(i = 2; i < seeds_size; i += 4)
        fprintf(fp, "%7.5lf  %7.5lf    %7.5lf  %7.5lf    %7.5lf  %7.5lf    %7.5lf  %7.5lf\n", seeds[i], errors[i], seeds[i + 1], errors[i + 1],
                                                                                            seeds[i + 2], errors[i + 2], seeds[i + 3], errors[i + 3]);
    fprintf(fp, "bg_pos(2theta) bg_int\n");
    for(i = 0; i < bg_size; i++)
        fprintf(fp, "%5.3lf %5.3lf\n", bg[0][i], bg[1][i]);
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
int check_for_null_peaks(double treshold, int numrings, int * zero_peak_index, double * intens)
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

void average(double * intens_av, double * peak_intens_av, int n_av, int size, int numrings)
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

int fit_result(int all_seeds_size, double ** peak_seeds, double * errors, int * zero_peak_index, exp_data * sync_data, peak_data * difra)
{//habria que ver si efectivamente le estoy pasando los valores mas proximos
    int bad_fit;
    if((*difra).gamma == (*difra).start_gam)
    {
        if((*difra).spr == (*difra).start_spr)
            bad_fit = results_output(all_seeds_size, peak_seeds, errors, zero_peak_index, sync_data, difra, 0, 0); //en el indice 0,0 puse un -1
        else
            bad_fit = results_output(all_seeds_size, peak_seeds, errors, zero_peak_index, sync_data, difra, (*difra).spr - 1, (*difra).gamma);
    }
    else
        bad_fit = results_output(all_seeds_size, peak_seeds, errors, zero_peak_index, sync_data, difra, (*difra).spr, (*difra).gamma - (*difra).start_gam);

    return bad_fit;
}

int results_output(int all_seeds_size, double ** peak_seeds, double * errors, int * zero_peak_index, exp_data * sync_data, peak_data * difra, int spr, int gamma)
{
    int bad_fit = 0, i, j = 2, k = 0;
    double dtheta, dtheta_aux, I, I_aux, I_err, H, H_aux, H_err, eta, eta_aux, eta_err, breadth, breadth_err;
    double theta_rad, radian = M_PI / 180;
    for(i = 2; i < all_seeds_size; i += 4)
    {
        if(zero_peak_index[k] == 0)
        {
            dtheta_aux = peak_seeds[1][j];
            I_aux = peak_seeds[1][j + 1];
            H_aux = peak_seeds[1][0] + peak_seeds[1][j + 2];
            eta_aux = peak_seeds[1][1] + peak_seeds[1][j + 3];
            if(I_aux < 0)
            {
                bad_fit = 1;
                dtheta = peak_seeds[0][j];
                I = 0.0;
                I_err = 0.0;
                H = -1.0;
                H_err = -1.0;
                eta = -1.0;
                eta_err = -1.0;
                breadth = -1.0;
                breadth_err = -1.0;
            }
            else
            {
                if(H_aux < 0 || H_aux > 1)
                {
                    bad_fit = 1;
                    dtheta = peak_seeds[0][j];
                    I = I_aux;
                    I_err = errors[j + 1];
                    H = -1.0;
                    H_err = -1.0;
                    eta = -1.0;
                    eta_err = -1.0;
                    breadth = -1.0;
                    breadth_err = -1.0;
                }
                else
                {
                    if(eta_aux < 0 || eta_aux > 1)
                    {
                        bad_fit = 1;
                        dtheta = dtheta_aux;
                        I = I_aux;
                        I_err = errors[j + 1];
                        H = H_aux;
                        H_err = sqrt(pow(errors[0], 2.0) + pow(errors[j + 2], 2.0));
                        eta = -1.0;
                        eta_err = -1.0;
                        breadth = -1.0;
                        breadth_err = -1.0;
                    }
                    else
                    {
                        bad_fit = 0;
                        dtheta = dtheta_aux;
                        I = I_aux;
                        I_err = errors[j + 1];
                        H = H_aux;
                        H_err = sqrt(pow(errors[0], 2.0) + pow(errors[j + 2], 2.0));
                        eta = eta_aux;
                        eta_err = sqrt(pow(errors[1], 2.0) + pow(errors[j + 3], 2.0));
                        breadth = M_PI * (H_aux * 0.5) / (eta_aux + (1 - eta_aux) * sqrt(M_PI * log(2)));
                        breadth_err = delta_breadth(H, pow(errors[0] + errors[j + 2], 2.0), eta, pow(errors[1] + errors[j + 3], 2.0));
                    }
                }
            }//end if routine if(I_aux < 0)
            //printf("Salida de datos\n");
            difra->intens[(*difra).spr][(*difra).gamma][k] = I;
            difra->errors->intens_err[(*difra).spr][(*difra).gamma][k] = I_err;
            
            difra->shapes->fwhm[(*difra).spr][(*difra).gamma][k] = H;
            difra->errors->fwhm_err[(*difra).spr][(*difra).gamma][k] = H_err;
    
            difra->shapes->eta[(*difra).spr][(*difra).gamma][k] = eta;
            difra->errors->eta_err[(*difra).spr][(*difra).gamma][k] = eta_err;
    
            difra->shapes->breadth[(*difra).spr][(*difra).gamma][k] = breadth;
            difra->errors->breadth_err[(*difra).spr][(*difra).gamma][k] = breadth_err;
            
            //printf("Correccion instrumental\n");
            theta_rad = (dtheta * 0.5) * radian; //2theta en grados -> THETA en RADIANES
            ins_correction(&H, &eta, sync_data->ins, theta_rad);
            difra->shapes->fwhm_ins[(*difra).spr][(*difra).gamma][k] = H;
            difra->shapes->eta_ins[(*difra).spr][(*difra).gamma][k] = eta;
            difra->shapes->breadth_ins[(*difra).spr][(*difra).gamma][k] = M_PI * (H * 0.5) / (eta + (1 - eta) * sqrt(M_PI * log(2)));
            j += 4;
        }
        else
        {
            (*difra).intens[(*difra).spr][(*difra).gamma][k] =  0.0;
            difra->shapes->fwhm[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->shapes->fwhm_ins[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->errors->fwhm_err[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->shapes->eta[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->shapes->eta_ins[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->errors->eta_err[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->shapes->breadth[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->shapes->breadth_ins[(*difra).spr][(*difra).gamma][k] = -2.0;
            difra->errors->breadth_err[(*difra).spr][(*difra).gamma][k] = -2.0;
        }//end if routine if(zero_peak_index[k] == 0)
        k++;
    }//end for routine for(i = 2; i < all_seeds_size; i += 4)
    return bad_fit;
}

void smooth(double *** v, int i, int j, int k, int start_i,  int di, int end_i, int start_j, int dj, int end_j)
{
  double sum = 0, avg;
  int n = 0;
  
  if(v[periodic_index(i - di, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i - di, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k];
    n++;
  }
  if(v[periodic_index(i, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k];
    n++;
  }
  if(v[periodic_index(i + di, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i + di, start_i, end_i)][periodic_index(j - dj, start_j, end_j)][k];
    n++;
  }
  
  if(v[periodic_index(i - di, start_i, end_i)][periodic_index(j, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i - di, start_i, end_i)][periodic_index(j, start_j, end_j)][k];
    n++;
  }
  if(v[periodic_index(i + di, start_i, end_i)][periodic_index(j, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i + di, start_i, end_i)][periodic_index(j, start_j, end_j)][k];
    n++;
  }

  if(v[periodic_index(i - di, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i - di, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k];
    n++;
  }
  if(v[periodic_index(i, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k];
    n++;
  }
  if(v[periodic_index(i + di, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k] >= 0.0)
  {
    sum += v[periodic_index(i + di, start_i, end_i)][periodic_index(j + dj, start_j, end_j)][k];
    n++;
  }
  if(n)
  {
    avg = sum / n;
    v[i][j][k] = avg;
  }
  else
    v[i][j][k] = 0.0;
}

int periodic_index(int i, int ini, int end)
{
  if(i < ini)
    return end;
  
  if(i > end)
    return ini;
  
  return i;
}

double delta_breadth(double H, double DH2, double eta, double Deta2)
{
    double a = sqrt(M_PI * log(2));
    double b = eta + (1 - eta) * a;
    double c = (M_PI * 0.5) / b;
    double d = (H * (1 - a)) / b;
    return c * sqrt(DH2 + pow(d, 2) * Deta2);
}

void print_double_vector(double * v, int size)
{
    int i;
    for(i = 0; i < size; i++)
        printf("v[%d]  %lf\n", i, v[i]);
    getchar();
}
