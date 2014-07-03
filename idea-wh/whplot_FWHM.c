#include "whplot_FWHM.h"

void williamson_hall_plot_FWHM_1(int nlines, aux_data * adata, crystal_data * cdata, shape_params * widths, angles_grad * angles, linear_fit * fit_data, best_values * out_values)
{
    double beta_min = adata->delta_min / cdata->a, beta_max = adata->delta_max / cdata->a, beta_step = adata->delta_step / cdata->a;
    double radian = M_PI / 180., delta, q, Ch00, weight[cdata->npeaks];
    int i, j, k = 0, l = 0, n = 20, m, nparams = 7;
    int ndelta = (beta_max - beta_min) / beta_step + 1, nq = (adata->q_max - adata->q_min) / adata->q_step + 1, nC = (adata->Ch00_max - adata->Ch00_min) / adata->Ch00_step + 1;
    int results_size = ndelta * nq * nC;
    size_t best_R_indices[n];
    double out_params[nparams][results_size], tmp[nparams];
    FILE *fp_fit = fopen("fit_results.dat", "w");

    for(i = 0; i < nlines; i++)
    {
        l = 0;
        for(j = 0; j < nparams; j++)
          memset(out_params[j], 0, sizeof(double) * results_size);

        if((i % 400) == 0) printf("\nCompletado en un %d %%", (i * 100) / nlines);
        for(delta = beta_max; delta > beta_min; delta -= beta_step)
        {
            for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
            {
                for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
                {
                    k = 0;
                    for(j = 0; j < cdata->npeaks; j++)
                    {
                        if(widths->FWHM[j][i] > 0)
                        {
                            fit_data->x[k] = pow(2. * sin(angles->theta_grad[j][i] *  radian) / adata->lambda, 2.0) * Chkl(Ch00, q, cdata->indices[j]);
                            fit_data->y[k] = widths->FWHM[j][i] * cos(angles->theta_grad[j][i] * radian) / adata->lambda - delta * cdata->warrenc[j];
                            fit_data->y_err[k] = widths->FWHM_err[j][i] * cos(angles->theta_grad[j][i] * radian) / adata->lambda;
                            weight[k] = 1. / pow(fit_data->y_err[k], 2.0);
                            k++;
                        }
                    }
                    //print_xy(fit_data->x, fit_data->y, fit_data->y_err, k);
                    if(k >= 3)
                    {
                      gsl_fit_wlinear(fit_data->x, 1, weight, 1, fit_data->y, 1, k, &fit_data->h,  &fit_data->m,
                                     &fit_data->covar[0][0], &fit_data->covar[0][1], &fit_data->covar[1][1], &fit_data->chisq); //fiteo con peso
                      fit_data->covar[1][0] = fit_data->covar[0][1];
                      fit_data->R = fabs(gsl_stats_correlation(fit_data->x, 1, fit_data->y, 1, k));
                      //print_stats(fit_data, k);
                      if(fit_data->h > 0 && fit_data->m > 0)
                      {
                        out_params[0][l] = delta;
                        out_params[1][l] = q;
                        out_params[2][l] = Ch00;
                        out_params[3][l] = fit_data->h;
                        out_params[4][l] = fit_data->m;
                        out_params[5][l] = fit_data->R;
                        out_params[6][l] = fit_data->chisq;
                        l++;
                      }
                    }
                    else
                    {
                      for(m = 0; m< nparams; m++)
                        out_params[m][l] = -1.0;
                      l++;
                    }//end if routine if(k >= 3)
                }//end for routine for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
            }//end for routine for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
        }//end for routine for(delta = adata->delta_min; delta < adata->delta_max; delta += adata->delta_step)
        //printf("k = %d\n", k);
        if(k >= 3)
          gsl_sort_largest_index(best_R_indices, n, out_params[5], 1, results_size);//obtengo los indices de los 10 mayores R
        
        print_stats2file(fp_fit, fit_data->x, fit_data->y, fit_data->y_err, k, out_params[4][best_R_indices[0]], out_params[3][best_R_indices[0]]);
        
        /*print_int_vector(best_R_indices, n);
        
        for(l = 0; l < n; l++)
            printf("delta[%zd] = %.10lf\n", best_R_indices[l], out_params[0][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("q[%zd] = %.10lf\n", best_R_indices[l], out_params[1][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("Ch00[%zd] = %.10lf\n", best_R_indices[l], out_params[2][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("h[%zd] = %.10lf\n", best_R_indices[l], out_params[3][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("m[%zd] = %.10lf\n", best_R_indices[l], out_params[4][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("R[%zd] = %.10lf\n", best_R_indices[l], out_params[5][i][best_R_indices[l]]);
        getchar();
        for(l = 0; l < n; l++)
            printf("chisq[%zd] = %.10lf\n", best_R_indices[l], out_params[6][i][best_R_indices[l]]);
        getchar();
*/
        for(l = 0; l < nparams; l++)
        {
          tmp[l] = 0;
          for(j = 0; j < n; j++)
            tmp[l] += out_params[l][best_R_indices[j]];
          
          tmp[l] /= n;
          out_values->best_R_values[l][i] = tmp[l];
          out_values->best_chisq_values[l][i] = tmp[l];
        }
    }//end for routine for(i = 0; i < nlines; i++)
    fclose(fp_fit);
}//end function

void williamson_hall_plot_FWHM_2(int nlines, aux_data * adata, crystal_data * cdata, shape_params * widths, angles_grad * angles, linear_fit * fit_data, best_values * out_values)
{
    int i, j, k;
    double radian = M_PI / 180., delta, q, Ch00;
    double beta_min = adata->delta_min / cdata->a, beta_max = adata->delta_max / cdata->a, beta_step = adata->delta_step / cdata->a;

    for(i = 0; i < nlines; i++)
    {
        if((i % 400) == 0) printf("\nCompletado en un %d %%", (i * 100) / nlines);
        out_values->R_max = -1;
        out_values->chisq_min = 1000;
        fit_data->R = out_values->R_max;
        fit_data->chisq = out_values->chisq_min;
        for(delta = beta_min; delta < beta_max; delta += beta_step)
        {
            for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
            {
                for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
                {
                    k = 0;
                    for(j = 0; j < cdata->npeaks; j++)
                    {
                        if(widths->FWHM_corr[j][i] > 0)
                        {
                            fit_data->x[k] = pow(2. * sin(angles->theta_grad[j][i] * radian) / adata->lambda, 2.0) * Chkl(Ch00, q, cdata->indices[j]);
                            fit_data->y[k] = widths->FWHM_corr[j][i] * cos(angles->theta_grad[j][i] * radian) / adata->lambda - delta * cdata->warrenc[j];
                            fit_data->y_err[k] = widths->FWHM_corr_err[j][i] * cos(angles->theta_grad[j][i] * radian) / adata->lambda;
                            k++;
                        }
                    }
                    //print_xy(fit_data->x, fit_data->y, fit_data->y_err, k);
                    gsl_fit_wlinear(fit_data->x, 1, fit_data->y_err, 1, fit_data->y, 1, k, &fit_data->h,  &fit_data->m,
                                    &fit_data->covar[0][0], &fit_data->covar[0][1], &fit_data->covar[1][1], &fit_data->chisq); //fiteo con peso
                    fit_data->covar[1][0] = fit_data->covar[0][1];
                    fit_data->R = gsl_stats_correlation(fit_data->x, 1, fit_data->y, 1, k);
                    //printf("m = %lf, h = %lf\nchisq = %lf R = %lf\n", fit_data->m, fit_data->h, fit_data->chisq, fit_data->R);
                    //getchar();
                    if(fabs(fit_data->R) > out_values->R_max && fit_data->h > 0 && fit_data->m > 0)
                    {
                        out_values->R_max = fit_data->R;
                        out_values->best_R_values[0][i] = delta;
                        out_values->best_R_values[1][i] = q;
                        out_values->best_R_values[2][i] = Ch00;
                        out_values->best_R_values[3][i] = fit_data->h;
                        out_values->best_R_values[4][i] = fit_data->m;
                        out_values->best_R_values[5][i] = fit_data->R;
                        out_values->best_R_values[6][i] = fit_data->chisq;
                    }
                    if(fit_data->chisq < out_values->chisq_min && fit_data->h > 0 && fit_data->m > 0)
                    {
                        out_values->chisq_min = fit_data->chisq;
                        out_values->best_chisq_values[0][i] = delta;
                        out_values->best_chisq_values[1][i] = q;
                        out_values->best_chisq_values[2][i] = Ch00;
                        out_values->best_chisq_values[3][i] = fit_data->h;
                        out_values->best_chisq_values[4][i] = fit_data->m;
                        out_values->best_chisq_values[5][i] = fit_data->R;
                        out_values->best_chisq_values[6][i] = fit_data->chisq;
                    }
                }//end for routine for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
            }//end for routine for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
        }//end for routine for(delta = adata->delta_min; delta < adata->delta_max; delta += adata->delta_step)
    }//end for routine for(i = 0; i < nlines; i++)
}
