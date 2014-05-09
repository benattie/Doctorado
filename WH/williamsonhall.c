#include "funciones.h"

int main()
{
    //variables del programa
    FILE *fp_in;
    FILE *fp_out_R, *fp_out_chi2;
    char name[500], buf[500];
    int i, j, linecount, nlines = 13320, nparam = 7;
    double delta, q, Ch00, radian = M_PI / 360., b2;
    double m, h, cov[2][2], chisq, chisq_min = 100, R, R_max = 0;
    double best_R_val[nparam], best_chisq_val[nparam], out_values[nparam];
    file_data *fdata = malloc(sizeof(file_data));
    crystal_data *cdata = malloc(sizeof(crystal_data));
    aux_data *adata = malloc(sizeof(aux_data));

    //cargo los datos basicos
    if((fp_in = fopen("para_WH.dat", "r")) == NULL)
    {
        fprintf(stderr, "\nError opening para_WH.dat.\n");
        exit(1);
    }
    read_input(fp_in, fdata, cdata, adata);
    fclose(fp_in);
    //datos de la estructura cristalina
    double *h02 = vector_double_alloc(cdata->npeaks);
    double *wc = vector_double_alloc(cdata->npeaks);
    for(i = 0; i < cdata->npeaks; i++)
    {
        h02[i] = H2(cdata->indices[i]);
        wc[i] = warren_constants(cdata->type, cdata->indices[i]);
    }
    cdata -> H2 = h02;
    cdata -> warrenc = wc;
    //flags de control
    //printf_filedata(fdata);
    //printf_crystaldata(cdata);
    //printf_auxdata(adata);

    //datos del difractograma
    double **dostheta = matrix_double_alloc(cdata->npeaks, nlines);
    double **theta = matrix_double_alloc(cdata->npeaks, nlines);
    double **alpha = matrix_double_alloc(cdata->npeaks, nlines);
    double **beta = matrix_double_alloc(cdata->npeaks, nlines);
    double **FWHM = matrix_double_alloc(cdata->npeaks, nlines);
    //double **breadth = matrix_double_alloc(cdata->npeaks, nlines);
    double *x = vector_double_alloc(cdata->npeaks);
    double *y = vector_double_alloc(cdata->npeaks);
    //double y_err[cdata->npeaks], FWHM_err[cdata->npeaks][nlines], breadth_err[cdata->npeaks][nlines];
    //leo las figuras de polos
    for(i = fdata->start - 1; i < fdata->end - 1; i++)
    {
        sprintf(name, "%s%s%d.%s", fdata->outPath, fdata->filename, i + 1, fdata->fileext);
        printf("Reading file %s\n", name);
        if((fp_in = fopen(name, "r")) == NULL)
        {
            fprintf(stderr, "\nError opening %s.\n", name);
            exit(1);
        }
        fgets(buf, 500, fp_in);//skip line
        fgets(buf, 500, fp_in);//skip line
        while(fscanf(fp_in, "%d", &linecount) != EOF)
        {
            fscanf(fp_in, "%lf", &dostheta[i][linecount - 1]);
            fscanf(fp_in, "%lf", &theta[i][linecount - 1]);
            fscanf(fp_in, "%lf", &alpha[i][linecount - 1]);
            fscanf(fp_in, "%lf", &beta[i][linecount - 1]);
            fscanf(fp_in, "%lf", &FWHM[i][linecount - 1]);
            //fscanf(fp_in, "%lf", &FWHM_err[i][linecount - 1]);
            theta[i][linecount - 1] *= radian; //paso el angulo a radianes
            //printf("%d %.5lf %.5lf %.5lf %.5lf %.5lf\n", linecount, dostheta[i][linecount - 1], theta[i][linecount - 1], alpha[i][linecount - 1], beta[i][linecount - 1], FWHM[i][linecount - 1]);
            //getchar();
            //podria agregar aca la rutina para restar anchos instrumentales (opcional)
            //para trabajar con el breadth en vez del FWHM tengo que realizar un procedimiento parecido al que uso cuando
            //resto anchos intrumentales
        }
        fclose(fp_in);
    }
    nlines = linecount;
    
    printf("Iniciando el ajuste de Williamson-Hall\n");
    for(j = 0; j < nlines; j++)
    {
        if((j % 100) == 0) printf("Completado en un %d %%\n", (j * 100) / nlines);

        for(delta = adata->delta_min; delta < adata->delta_max; delta += adata->delta_step)
        {
            for(q = adata->q_min; q < adata->q_max; q += adata->q_step)
            {
                for(Ch00 = adata->Ch00_min; Ch00 < adata->Ch00_max; Ch00 += adata->Ch00_step)
                {
                    for (i = 0; i < cdata->npeaks; i++)
                    {
                        x[i] = 2. * sin(theta[i][j]) / adata->lambda * Chkl(Ch00, q, cdata->indices[i]);
                        y[i] = FWHM[i][j] * cos(theta[i][j]) / adata->lambda - delta * cdata->warrenc[i];
                        //y_err[i] = FWHM_err[i][j] * cos(theta[i][j]) / adata->lambda - delta * cdata->warrenc[i];
                    }
                    gsl_fit_linear(x, 1, y, 1, cdata -> npeaks, &h,  &m, &cov[0][0], &cov[0][1], &cov[1][1], &chisq); //fiteo sin peso
                    //gsl_fit_wlinear(x, 1, y_err, 1, y, 1, npeaks, &h,  &m, &cov[0][0], &cov[0][1], &cov[1][1], &chisq); //fiteo con peso
                    R = gsl_stats_correlation(x, 1, y, 2, cdata -> npeaks);
                    if(fabs(R) > R_max && h > 0 && m > 0)
                    {
                        R_max = R;
                        best_R_val[0] = delta;
                        best_R_val[1] = q;
                        best_R_val[2] = Ch00;
                        best_R_val[3] = h;
                        best_R_val[4] = m;
                        best_R_val[5] = R;
                        best_R_val[6] = chisq;

                    }
                    if(chisq < chisq_min && h > 0 && m > 0)
                    {
                        chisq_min = chisq;
                        best_chisq_val[0] = delta;
                        best_chisq_val[1] = q;
                        best_chisq_val[2] = Ch00;
                        best_chisq_val[3] = h;
                        best_chisq_val[4] = m;
                        best_chisq_val[5] = R;
                        best_chisq_val[6] = chisq;
                    }
                }
            }
        }
        //salida de los valores para el mejor ajuste segun R
        sprintf(name, "%s%s_WH_R.dat", fdata->outPath, fdata->filename);
        fp_out_R = fopen(name, "w");

        //obtencion de los valores a imprimir a partir de los resultados del ajuste
        out_values[0] = best_R_val[0]; //delta
        out_values[1] = best_R_val[1]; //q
        out_values[2] = best_R_val[2]; //Ch00
        out_values[3] = 0.9 / best_R_val[3]; //h = 0.9 / D (ver la expresion correcta)
        b2 = pow(cdata->burgersv, 2);
        out_values[4] = pow( (2 * best_R_val[4]) / (M_PI * b2), 2); //m = (\pi * M^2 * b^2) / 2 * sqrt(ro)
        out_values[5] = best_R_val[5]; //R
        out_values[6] = best_R_val[6]; //chisq
        fprintf(fp_out_R, "#alpha    beta    delta    q    Ch00    D    (M^4 * \\ro)    R    chi2\n");
        fprintf(fp_out_R, "%lf    %lf    ", alpha[0][j], beta[0][j]);
        for(i = 0; i < 7; i++)
            fprintf(fp_out_R, "%.5lf    ", out_values[i]);
        fprintf(fp_out_R, "\n");
        fclose(fp_out_R);

        //salida de los valores para el mejor ajuste segun chi^2
        sprintf(name, "%s%s_WH_chi2.dat", fdata->outPath, fdata->filename);
        fp_out_chi2 = fopen(name, "w");      

        //obtencion de los valores a imprimir a partir de los resultados del ajuste
        out_values[0] = best_chisq_val[0]; //delta
        out_values[1] = best_chisq_val[1]; //q
        out_values[2] = best_chisq_val[2]; //Ch00
        out_values[3] = 0.9 / best_chisq_val[3]; //h = 0.9 / D (ver la expresion correcta)
        b2 = pow(cdata->burgersv, 2);
        out_values[4] = pow( (2 * best_chisq_val[4]) / (M_PI * b2), 2); //m = (\pi * M^2 * b^2) / 2 * sqrt(ro)
        out_values[5] = best_chisq_val[5]; //R
        out_values[6] = best_chisq_val[6]; //chisq
        fprintf(fp_out_chi2, "#alpha    beta    delta    q    Ch00    D    (M^4 * \\ro)    R    chi2\n");
        fprintf(fp_out_chi2, "%lf    %lf    ", alpha[0][j], beta[0][j]);
        for(i = 0; i < 7; i++)
            fprintf(fp_out_chi2, "%.5lf    ", out_values[i]);
        fprintf(fp_out_chi2, "\n");
        fclose(fp_out_chi2);
    }
    printf("done!\n");
    return 0;
}
