#include "funciones.h"

int main()
{
    printf("Programa para realizar figuras de polos generalizadas utilizando el analisis de Williamson-Hall\n");
    printf("Opciones:\n");
    printf("Modelos 1 y 2 (opcion 9):  (H * cos(\\theta) / \\lambda - \\delta * wc) = sqrt(\\alpha * \\ro) * [K * sqrt(C)]\n");
    printf("\\alpha = 0.5 * \\pi * M^2 * b^2\nK = 2 * sin(\\theta) / \\lambda\nC == contrast factor\n");
    printf("\\delta * wc = stacking fault broadening correction\n\\ro = dislocation density\n");
    printf("H = FWHM o BREADTH (opcion 8)\nModelos pares (opcion 7) trabajan con los anchos corregidos por ancho instrumental\n");
    printf("Para correr escribir:\n./idea-wh.exe");
    printf("IMPORTANTE\nIMPORTANTE\nIMPORTANTE\n");
    printf("IMPORTANTE\NVerificar que el archivo para_WH.dat se encuentre en el mismo directorio que idea-wh.exe");
    printf("IMPORTANTE\nIMPORTANTE\nIMPORTANTE\n");

    //variables del programa
    FILE *fp_in, *fp_out;
    char name[500];
    int i, nlines = 13320, nparam = 7;
    double m = 0, h = 0, **cov = matrix_double_alloc(2, 2), chisq = 0, R = 0;
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
    printf("\n----------------\nDatos de entrada\n----------------\n");
    printf_filedata(fdata);
    printf_crystaldata(cdata);
    printf_auxdata(adata);
    printf("----------------\nDatos de entrada\n----------------\n\n");
    //datos del difractograma
    double **dostheta = matrix_double_alloc(cdata->npeaks, nlines), **theta = matrix_double_alloc(cdata->npeaks, nlines);
    double **alpha = matrix_double_alloc(cdata->npeaks, nlines), **beta = matrix_double_alloc(cdata->npeaks, nlines);
    double **FWHM = matrix_double_alloc(cdata->npeaks, nlines), **FWHM_err = matrix_double_alloc(cdata->npeaks, nlines);
    double **breadth = matrix_double_alloc(cdata->npeaks, nlines), **breadth_err = matrix_double_alloc(cdata->npeaks, nlines);
    double **FWHM_corr = matrix_double_alloc(cdata->npeaks, nlines), **FWHM_corr_err = matrix_double_alloc(cdata->npeaks, nlines);
    double **breadth_corr = matrix_double_alloc(cdata->npeaks, nlines), **breadth_corr_err = matrix_double_alloc(cdata->npeaks, nlines);
    double *x = vector_double_alloc(cdata->npeaks), *y = vector_double_alloc(cdata->npeaks), *y_err = vector_double_alloc(cdata->npeaks);
    
    //generacion de las estructuras
    //estructura que contiene las coordenadas angulares (en grados)
    angles->theta_grad = theta;
    angles->dostheta_grad = dostheta;
    angles->alpha_grad = alpha;
    angles->beta_grad = beta;
    
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
    widths->FWHM_corr = FWHM_corr;
    widths->FWHM_corr_err = FWHM_corr_err;
    widths->breadth_corr = breadth_corr;
    widths->breadth_corr_err = breadth_corr_err;

    printf("Inicio lectura figuras de polos\n");
    nlines = read_pole_figures(fdata, angles, widths);

    //datos con los mejores resultados del ajuste de williamson hall
    double ** best_R_val = matrix_double_alloc(fit_data->n_out_params, nlines);
    double ** best_chi_val = matrix_double_alloc(fit_data->n_out_params, nlines);
    out_values->R_max = 0;
    out_values->best_R_values = best_R_val;
    out_values->chisq_min = 1000;
    out_values->best_chisq_values = best_chi_val;

    printf("Iniciando el ajuste de Williamson-Hall\n");
    if(strcmp(fdata->is_H, "FWHM") == 0)
        if(strcmp(fdata->is_corr, "N") == 0)
            if(fdata->model == 1)
                williamson_hall_plot(nlines, adata, cdata, widths->FWHM, widths->FWHM_err, angles, fit_data, out_values);
            else
            {
                printf("Modelo no aceptado o modelo no compatible con lo ingresado en las opciones 7 y 8\n");
                exit(1);
            }
        else if(strcmp(fdata->is_corr, "Y") == 0)
            if(fdata->model == 2)
                williamson_hall_plot(nlines, adata, cdata, widths->FWHM_corr, widths->FWHM_corr_err, angles, fit_data, out_values);
            else
            {
                printf("Modelo no aceptado o modelo no compatible con lo ingresado en las opciones 7 y 8\n");
                exit(1);
            }
        else
        {
            printf("El texto ingresado en la opción 7 no es válido. Ingrese un caracter valido (Y o N)\n");
            exit(1);
        }
    else if(strcmp(fdata->is_H, "BREADTH") == 0)
        if(strcmp(fdata->is_corr, "N") == 0)
            if(fdata->model == 1)
                williamson_hall_plot(nlines, adata, cdata, widths->breadth, widths->breadth_err, angles, fit_data, out_values);
            else
            {
                printf("Modelo no aceptado o modelo no compatible con lo ingresado en las opciones 7 y 8\n");
                exit(1);
            }
        else if(strcmp(fdata->is_corr, "Y") == 0)
            if(fdata->model == 2)
                williamson_hall_plot(nlines, adata, cdata, widths->breadth_corr, widths->breadth_corr_err, angles, fit_data, out_values);
            else
            {
                printf("Modelo no aceptado o modelo no compatible con lo ingresado en las opciones 7 y 8\n");
                exit(1);
            }
        else
        {
            printf("El texto ingresado en la opción 7 no es válido. Ingrese un caracter valido (y o n)\n");
            exit(1);
        }
    else
    {
        printf("La opcion 8 seleccionada no es valida. Ingrese una opcion valida (FWHM o BREADTH)\n");
        exit(1);
    }

    printf("\nImprimiendo los mejores resultados segun R\n");
    sprintf(name, "%s%s%s_%d_WH_R.dat", fdata->outPath, fdata->filename, fdata->is_H, fdata->model);
    fp_out = fopen(name, "w");
    print_results(fdata, fp_out, out_values->best_R_values, fit_data, nlines, angles, cdata);
    fclose(fp_out);
    /*
    printf("Imprimiendo los mejores resultados segun chi^2\n");
    sprintf(name, "%s%s%s_%d_WH_chi2.dat", fdata->outPath, fdata->filename, fdata->is_H, fdata->model);
    fp_out = fopen(name, "w");
    print_results(fdata, fp_out, out_values->best_chisq_values, fit_data, nlines, angles, cdata);
    fclose(fp_out);
    */
    printf("Liberando memoria\n");
    free_double_matrix(out_values->best_R_values, fit_data->n_out_params);
    free_double_matrix(out_values->best_chisq_values, fit_data->n_out_params);
    free_double_matrix(cov, 2);
    free_double_matrix(dostheta, cdata->npeaks); free_double_matrix(theta, cdata->npeaks);
    free_double_matrix(alpha, cdata->npeaks); free_double_matrix(beta, cdata->npeaks);
    free_double_matrix(FWHM, cdata->npeaks);
    free_double_matrix(breadth, cdata->npeaks);
    free(x); free(y); free(y_err); free(FWHM_err), free(breadth_err);
    free(angles); free(fit_data); free(widths); free(out_values);
    free(fdata); free(cdata); free(adata);
    printf("done!\n");
    return 0;
}
