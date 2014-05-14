#include "whplot_breadth.h"

void williamson_hall_plot_breadth_1(int nlines, aux_data * adata, crystal_data * cdata, shape_params * widths, angles_grad * angles, linear_fit * fit_data, best_values * out_values)
{
    int i, j, k;
    double radian = M_PI / 180., delta, q, Ch00;
    for(i = 0; i < nlines; i++)
    {
        if((i % 400) == 0) printf("\nCompletado en un %d %%", (i * 100) / nlines);
        out_values->R_max = 0;
        out_values->chisq_min = 1000;
        for(delta = adata->delta_min; delta < adata->delta_max; delta += adata->delta_step)
        {
            for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
            {
                for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
                {
                    k = 0;
                    for(j = 0; j < cdata->npeaks; j++)
                    {
                        if(widths->breadth[j][i] > 0)
                        {
                            fit_data->x[k] = pow(2. * sin(angles->theta_grad[j][i]*radian) / adata->lambda, 2.0) * Chkl(Ch00, q, cdata->indices[j]);
                            fit_data->y[k] = widths->breadth[j][i] * cos(angles->theta_grad[j][i]*radian) / adata->lambda - delta * cdata->warrenc[j];
                            fit_data->y_err[k] = widths->breadth_err[j][i] * cos(angles->theta_grad[j][i]) / adata->lambda;
                            k++;
                        }
                    }
                    gsl_fit_wlinear(fit_data->x, 1, fit_data->y_err, 1, fit_data->y, 1, k, &fit_data->h,  &fit_data->m,
                                &fit_data->covar[0][0], &fit_data->covar[0][1], &fit_data->covar[1][1], &fit_data->chisq); //fiteo con peso
                    fit_data->R = gsl_stats_correlation(fit_data->x, 1, fit_data->y, 2, cdata -> npeaks);
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

void williamson_hall_plot_breadth_2(int nlines, aux_data * adata, crystal_data * cdata, shape_params * widths, angles_grad * angles, linear_fit * fit_data, best_values * out_values)
{
    int i, j, k;
    double radian = M_PI / 180., delta, q, Ch00;
    for(i = 0; i < nlines; i++)
    {
        if((i % 400) == 0) printf("\nCompletado en un %d %%", (i * 100) / nlines);
        out_values->R_max = 0;
        out_values->chisq_min = 1000;
        for(delta = adata->delta_min; delta < adata->delta_max; delta += adata->delta_step)
        {
            for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
            {
                for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
                {
                    k = 0;
                    for(j = 0; j < cdata->npeaks; j++)
                    {
                        if(widths->breadth[j][i] > 0)
                        {
                            fit_data->x[k] = pow(2. * sin(angles->theta_grad[j][i]*radian) / adata->lambda, 2.0) * Chkl(Ch00, q, cdata->indices[j]);
                            fit_data->y[k] = widths->breadth_corr[j][i] * cos(angles->theta_grad[j][i]*radian) / adata->lambda - delta * cdata->warrenc[j];
                            fit_data->y_err[k] = widths->breadth_corr_err[j][i] * cos(angles->theta_grad[j][i]) / adata->lambda;
                            k++;
                        }
                    }
                    gsl_fit_wlinear(fit_data->x, 1, fit_data->y_err, 1, fit_data->y, 1, k, &fit_data->h,  &fit_data->m,
                                &fit_data->covar[0][0], &fit_data->covar[0][1], &fit_data->covar[1][1], &fit_data->chisq); //fiteo con peso
                    fit_data->R = gsl_stats_correlation(fit_data->x, 1, fit_data->y, 2, cdata -> npeaks);
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
