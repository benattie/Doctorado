#include "whplot_FWHM.h"

void williamson_hall_plot_FWHM_1(int nlines, aux_data * adata, crystal_data * cdata, shape_params * widths, angles_grad * angles, linear_fit * fit_data, best_values * out_values)
{
    int i, j, k;
    double radian = M_PI / 180., delta, q, Ch00;
    double beta_min = adata->delta_min / cdata->a, beta_max = adata->delta_max / cdata->a, beta_step = adata->delta_step / cdata->a;

    for(i = 0; i < nlines; i++)
    {
        if((i % 400) == 0) printf("\nCompletado en un %d %%", (i * 100) / nlines);
        out_values->R_max = 0;
        out_values->chisq_min = 1000;

        for(delta = beta_min; delta < beta_max; delta += beta_step)
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
                            k++;
                            //tal vez haya que multiplicar por  2 * cos(\theta) / \lambda
                        }
                    }
                    //print_xy(fit_data->x, fit_data->y, fit_data->y_err, k);
                    gsl_fit_wlinear(fit_data->x, 1, fit_data->y_err, 1, fit_data->y, 1, k, &fit_data->h,  &fit_data->m,
                                &fit_data->covar[0][0], &fit_data->covar[0][1], &fit_data->covar[1][1], &fit_data->chisq); //fiteo con peso
                    fit_data->covar[1][0] = fit_data->covar[0][1];
                    fit_data->R = gsl_stats_correlation(fit_data->x, 1, fit_data->y, 1, k);
                    //print_stats(fit_data, k);
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
