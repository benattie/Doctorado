#include "funciones.h"

int main()
{
    //variables del programa
    FILE *fp_in, *fp_out;
    char name[500], buf[500];
    int i, linecount, nlines = 13320, nparam = 7;
    double dbuf;
    double m = 0, h = 0, **cov = matrix_double_alloc(2, 2), chisq = 0, R = 0;
    double best_R_val[nparam], best_chisq_val[nparam];
    file_data * fdata = (file_data *) malloc(sizeof(file_data));
    crystal_data * cdata = (crystal_data *) malloc(sizeof(crystal_data));
    aux_data * adata = (aux_data *) malloc(sizeof(aux_data));
    angles_grad * angles = (angles_grad *) malloc(sizeof(angles_grad));
    linear_fit * fit_data = (linear_fit *) malloc(sizeof(linear_fit));
    shape_params * widths = (shape_params *) malloc(sizeof(shape_params));
    best_values * out_values = (best_values *) malloc(sizeof(best_values));

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
    printf_crystaldata(cdata);
    //printf_auxdata(adata);

    //datos del difractograma
    double **dostheta = matrix_double_alloc(cdata->npeaks, nlines), **theta = matrix_double_alloc(cdata->npeaks, nlines);
    double **alpha = matrix_double_alloc(cdata->npeaks, nlines), **beta = matrix_double_alloc(cdata->npeaks, nlines);
    double **FWHM = matrix_double_alloc(cdata->npeaks, nlines);
    double **breadth = matrix_double_alloc(cdata->npeaks, nlines);
    double *x = vector_double_alloc(cdata->npeaks), *y = vector_double_alloc(cdata->npeaks);
    double *y_err = vector_double_alloc(cdata->npeaks);
    double **FWHM_err = matrix_double_alloc(cdata->npeaks, nlines), **breadth_err = matrix_double_alloc(cdata->npeaks, nlines);
    
    //generacion de las estructuras
    //estructura que contiene las coordenadas angulares (en grados)
    angles->theta_grad = theta;
    angles->dostheta_grad = dostheta;
    angles->theta_grad = alpha;
    angles->theta_grad = beta;
    
    //datos del ajuste lineal
    fit_data->n_out_params = nparam;
    fit_data->m = m;
    fit_data->h = h;
    fit_data->x = x;
    fit_data->y = y;
    fit_data->y_err = y_err;
    fit_data->R = R;
    fit_data->chisq = chisq;
    fit_data->covar = cov;

    //datos con los parametros de ensanchamiento del pico
    widths->FWHM = FWHM;
    widths->FWHM_err = FWHM_err;
    widths->breadth = breadth;
    widths->breadth_err = breadth_err;

    //datos con los mejores resultados del ajuste de williamson hall
    out_values->R_max = 0;
    out_values->best_R_values = best_R_val;
    out_values->chisq_min = 1000;
    out_values->best_chisq_values = best_chisq_val;

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
            fscanf(fp_in, "%lf", &angles->dostheta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->theta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->alpha_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->beta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->FWHM[i][linecount - 1]);
            //fscanf(fp_in, "%lf", &widths->FWHM_err[i][linecount - 1]);
        }
        fclose(fp_in);
    }//end for routine for(i = fdata->start - 1; i < fdata->end - 1; i++)
    nlines = linecount;

    printf("Iniciando el ajuste de Williamson-Hall\n");
    williamson_hall_plot(nlines, adata, cdata, widths, angles, fit_data, out_values);
    printf("Fin del ajuste de Williamson-Hall\n");

    printf("Imprimiendo los mejores resultados segun R\n");
    sprintf(name, "%s%s_WH_R.dat", fdata->outPath, fdata->filename);
    fp_out = fopen(name, "w");
    print_results_(2, fp_out, out_values->best_R_values, fit_data, nlines, angles, cdata);
    fclose(fp_out);

    printf("Imprimiendo los mejores resultados segun chi^2\n");
    sprintf(name, "%s%s_WH_chi2.dat", fdata->outPath, fdata->filename);
    fp_out = fopen(name, "w");
    print_results_(2, fp_out, out_values->best_chisq_values, fit_data, nlines, angles, cdata);
    fclose(fp_out);

    printf("Liberando memoria\n");
    free(angles); free(fit_data); free(widths); free(out_values);
    free_double_matrix(cov, 2);
    free_double_matrix(dostheta, cdata->npeaks); free_double_matrix(theta, cdata->npeaks);
    free_double_matrix(alpha, cdata->npeaks); free_double_matrix(beta, cdata->npeaks);
    free_double_matrix(FWHM, cdata->npeaks);
    free_double_matrix(breadth, cdata->npeaks);
    free(x); free(y);
    free(y_err); free(FWHM_err), free(breadth_err);
    free(fdata); free(cdata); free(adata);
    printf("done!\n");
    return 0;
}
