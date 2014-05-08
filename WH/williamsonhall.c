#include "funciones.h"

int main()
{
    //variables del programa
    FILE *fp_in, *fp_out;
    FILE **inputFiles = malloc(sizeof(FILE *) * 15);
    char name[500], buf[500];
    int i, j, linecount, nlines = 13320;
    double delta, q, Ch00, radian = M_PI / 360.;
    double m, h, cov[2][2], chisq, chisq_min = 100, R, R_max = 0;
    double best_R_val[4], best_chisq_val[4];
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
    double h02[cdata->npeaks], wc[cdata->npeaks];
    double WC_FCC[9] = {sqrt(3) / 4., 1., sqrt(2) / 2., (3 * sqrt(11)) / 22., sqrt(3) / 4., 1.0, 0.0, 0.0, 0.0}; //constantes de Warren para una estructura FCC
    for(i = 0; i < cdata->npeaks; i++)
    {
        h02[i] = H2(cdata->indices[i]);
        wc[i] = WC_FCC[i]; //crear estructura de control para poner las constantes de warren segun sea FCC, BCC, HCP y segun los indices de Miller
    }
    cdata -> H2 = h02;
    cdata -> warrenc = wc; 
    //flags de control
    //printf_filedata(fdata);
    //printf_crystaldata(cdata);
    //printf_auxdata(adata);

    //datos del difractograma
    double dostheta[cdata->npeaks][nlines], theta[cdata->npeaks][nlines], alpha[cdata->npeaks][nlines], beta[cdata->npeaks][nlines];
    double x[cdata->npeaks], y[cdata->npeaks], y_err[cdata->npeaks];
    double FWHM[cdata->npeaks][nlines], FWHM_err[cdata->npeaks][nlines], breadth[cdata->npeaks][nlines], breadth_err[cdata->npeaks][nlines];

    //leo las figuras de polos
    for(i = fdata->start - 1; i < fdata->end - 1; i++)
    {
        sprintf(name, "%s%s%d.%s", fdata->outPath, fdata->filename, i + 1, fdata->fileext);
        if((inputFiles[i] = fopen(name, "r")) == NULL)
        {
            fprintf(stderr, "\nError opening %s.\n", name);
            exit(1);
        }
        fgets(buf, 500, inputFiles[i]);//skip line
        fgets(buf, 500, inputFiles[i]);//skip line
        while(fscanf(inputFiles[i], "%d", &linecount) != EOF)
        {
            fscanf(inputFiles[i], "%lf", &dostheta[i][linecount - 1]);
            fscanf(inputFiles[i], "%lf", &theta[i][linecount - 1]);
            fscanf(inputFiles[i], "%lf", &alpha[i][linecount - 1]);
            fscanf(inputFiles[i], "%lf", &beta[i][linecount - 1]);
            fscanf(inputFiles[i], "%lf", &FWHM[i][linecount - 1]);
            //fscanf(inputFiles[i], "%lf", &FWHM_err[i][linecount - 1]);
            theta[i][linecount - 1] *= radian; //paso el angulo a radianes
            //para trabajar con el breadth en vez del FWHM tengo que realizar un procedimiento parecido al que uso cuando
            //resto anchos intrumentales
        }
    }
    nlines = linecount;
    
    //rutina de calculo de factores de contraste y ajuste de Williamson-Hall
    for(j = 0; j < nlines; j++)
    {
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
                        best_R_val[0] = h;
                        best_R_val[1] = m;
                        best_R_val[2] = R;
                        best_R_val[3] = chisq;
                    }
                    if(chisq < chisq_min && h > 0 && m > 0)
                    {
                        chisq_min = chisq;
                        best_chisq_val[0] = h;
                        best_chisq_val[1] = m;
                        best_chisq_val[2] = R;
                        best_chisq_val[3] = chisq;
                    }
                }
            }
        }
        //imprimo los resultados
    }
    free(inputFiles);
    return 0;
}
