#include "funciones.h"

double warren_constants(char * type, int * hkl)
{
    if(strcmp(type, "FCC") == 0)
        return WC_FCC(hkl);
    else
    {
        if(strcmp(type, "BCC") == 0)
           return WC_BCC(hkl);
        else
        {
            if(strcmp(type, "HCP") == 0)
            {
                printf("Aun no esta imnplementada la rutina para la estructura HCP\n");
                exit(1);
            }
            else
            {
                printf("Estructura desconocida\nPor favor ingrese una estructura valida (FCC, BCC o HCP)\n");
                exit(1);
            }
        }
    }
}

double WC_FCC(int *hkl)
{
//u -> #planos que no se ensanchan por fallas de apilamiento
//b -> #planos que si se ensanchan por fallas de apilamiento
    int ax_hkl[3] = {abs(hkl[0]), abs(hkl[1]), abs(hkl[2])};
    gsl_sort_int(ax_hkl, 1, 3); //ordeno el vector de menor a mayor
    int nzeros = count_zeros(ax_hkl, 3), nequal = count_equal(ax_hkl);
    int ub = 0, L0 = 0, SL0 = 0, L0_aux[3]; 
    double h0 = sqrt(pow(ax_hkl[0], 2) + pow(ax_hkl[1], 2) + pow(ax_hkl[2], 2));;
    //6 posibilidades: hhh, 0hh, 00h, hhl, 0hk o hkl
    if(nequal == 3) //hhh
    {
        ub = 8;
        if((ax_hkl[0] % 3) == 0)
            SL0 = 12 * ax_hkl[0];
        else
            SL0 = 6 * ax_hkl[0];
    }
    else //0hh o 0hk o 00h o hhl o hkl
    {
        if(nequal == 2) //0hh o 00h o hhl
        {
            if(nzeros == 2) //00h
            {
                ub = 6;
                L0 = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];
                if((ax_hkl[0] % 3) == 0)
                    SL0 = 6 * L0;
                else
                    SL0 = 0 * L0;
            }
            else //0hh o hhl
            {
                if(nzeros == 1) //0hh
                {
                    ub = 12;
                    L0 = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];
                    if((L0 % 3) != 0)
                        SL0 = 6 * L0;
                    else
                        SL0 = 0 * L0;
                }
                else //hhl
                {
                    ub = 24;
                    if(ax_hkl[0] == ax_hkl[1])// hhl o lhh
                    {
                        L0_aux[0] = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];// == 2h + l (6 repeticiones)
                        L0_aux[1] = abs(ax_hkl[0] + ax_hkl[1] - ax_hkl[2]);// == 2h - l (6 repeticiones)
                        L0_aux[2] = abs(ax_hkl[0] - ax_hkl[1] - ax_hkl[2]);// == l (12 repeticiones)
                        if((L0_aux[0] % 3) != 0)
                            SL0 += 6 * L0_aux[0];
                        if((L0_aux[1] % 3) != 0)
                            SL0 += 6 * L0_aux[1];
                        if((L0_aux[2] % 3) != 0)
                            SL0 += 12 * L0_aux[2];
                    }
                    else// lhh
                    {
                        L0_aux[0] = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];// == 2h + l (6 repeticiones)
                        L0_aux[1] = abs(ax_hkl[0] + ax_hkl[1] - ax_hkl[2]);// == l (12 repeticiones)
                        L0_aux[2] = abs(ax_hkl[0] - ax_hkl[1] - ax_hkl[2]);// == 2h - l (6 repeticiones)
                        if((L0_aux[0] % 3) != 0)
                            SL0 += 6 * L0_aux[0];
                        if((L0_aux[1] % 3) != 0)
                            SL0 += 12 * L0_aux[1];
                        if((L0_aux[2] % 3) != 0)
                            SL0 += 6 * L0_aux[2];
                    }//end if(ax_hkl[0] == ax_hkl[1])
                }//end if(nzeros == 1)
            }//end if(nzeros == 2)
        }
        else //0hk o hkl
        {
            if(nzeros) //0hk
            {   
                ub = 24;
                L0_aux[0] = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];// == h + k
                L0_aux[1] = abs(ax_hkl[0] + ax_hkl[1] - ax_hkl[2]);// == abs(h - k)
                if((L0_aux[0] % 3) != 0)
                    SL0 += 12 * L0_aux[0];
                if((L0_aux[1] % 3) != 0)
                    SL0 += 12 * L0_aux[1];
            }
            else //hkl ordenado en forma creciente
            {
                ub = 48;
                L0_aux[0] = ax_hkl[0] + ax_hkl[1] + ax_hkl[2];// == h + k + l
                L0_aux[1] = abs(ax_hkl[0] + ax_hkl[1] - ax_hkl[2]);// == h + k - l 
                L0_aux[2] = abs(ax_hkl[0] - ax_hkl[1] - ax_hkl[2]);// == h - k - l
                if((L0_aux[0] % 3) != 0)
                    SL0 += 12 * L0_aux[0];
                if((L0_aux[1] % 3) != 0)
                    SL0 += 18 * L0_aux[1];
                if((L0_aux[2] % 3) != 0)
                    SL0 += 18 * L0_aux[2];
            }//end if(nzeros)
        }//end if(nequal == 2)
    }//end if(nequal == 3)]
    return (double)SL0 / (h0 * (double)ub);
}

void set_vector(int * v, int v1, int v2, int v3)
{
    v[0] = v1;
    v[1] = v2;
    v[2] = v3;
}

double WC_BCC(int *hkl)
{
    int error = 1;
    int a[3] = {1, 1, 0}, b[3] = {2, 2, 0}, c[3] = {3, 3, 0};
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 2. / (3. * sqrt(2));
    
    set_vector(a, 2, 0, 0); set_vector(b, 4, 0, 0); set_vector(c, 6, 0, 0);
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 4. / 3.;
    
    set_vector(a, 2, 1, 1); set_vector(b, 4, 2, 2); set_vector(c, 6, 3, 3);
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 2. / sqrt(6);
    
    set_vector(a, 3, 1, 0); set_vector(b, 6, 2, 0); set_vector(c, 9, 3, 0);
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 4. / sqrt(10);
    
    set_vector(a, 2, 2, 2); set_vector(b, 4, 4, 4); set_vector(c, 6, 6, 6);
    printf("%d\n", memcmp(hkl, a, 3 * sizeof(int)));
    printf("%d%d%d\t%d%d%d\n", hkl[0], hkl[1], hkl[2], a[0], a[1], a[2]); 
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 2. / sqrt(3);
    
    set_vector(a, 3, 2, 1); set_vector(b, 6, 4, 2); set_vector(c, 9, 6, 3);
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 5. / (2. * sqrt(14));
    
    set_vector(a, 4, 4, 0); set_vector(b, 5, 5, 0); set_vector(c, 6, 6, 0);
    if(! memcmp(hkl, a, 3 * sizeof(int)) || ! memcmp(hkl, b, 3 * sizeof(int)) || ! memcmp(hkl, c, 3 * sizeof(int)))
        return 2. / (3. * sqrt(2));

    if(error)
    {
        printf("\nLos indices [%d %d %d] no son validos\n", hkl[0], hkl[1], hkl[2]);
        exit(1);
    }
    return 0.0;
}

int count_zeros(int * v, int size)
{
    int i, nzeros = 0;
    for(i = 0; i < size; i++)
        if(v[i] == 0)
            nzeros++;
    return nzeros;
}

int count_equal(int * v)
{
    int nequal = 1000;
    if(v[0] == v[1] && v[0] == v[2])
        nequal = 3;
    if(v[0] == v[1] && v[0] != v[2])
        nequal = 2;
    if(v[0] != v[1] && v[0] == v[2])
        nequal = 2;
    if(v[0] != v[1] && v[0] != v[2])
    {
        if(v[1] == v[2])
            nequal = 2;
        else
            nequal = 1;
    }
    return nequal;
}

double H2(int * hkl)
{
    double h2 = pow(hkl[0], 2), k2 = pow(hkl[1], 2), l2 = pow(hkl[2], 2);
    double num = h2 * k2 + h2 * l2 + k2 * l2;
    double den = pow((h2 + k2 + l2), 2);
    return num / den;
}

double burgers(double a, int * hkl)
{
    return a * sqrt((pow(hkl[0], 2.) + pow(hkl[1], 2.) + pow(hkl[2], 2.))) / 2.;
}

double Chkl(double Ch00, double q, int * hkl)
{
    return Ch00 * (1 - q * H2(hkl));
}

void printf_filedata(file_data *fdata)
{
    printf("outPath: %s\n", fdata->outPath);
    printf("inputPath: %s\n", fdata->inputPath);
    printf("filename: %s\n", fdata->filename);
    printf("fileext: %s\n", fdata->fileext);
    printf("start: %d\n", fdata->start);
    printf("end: %d\n", fdata->end);
    printf("is_corr: %s\n", fdata->is_corr);
    printf("is_H: %s\n", fdata->is_H);
    printf("model: %d\n", fdata->model);
    getchar();
}

void printf_crystaldata(crystal_data *cdata)
{
    int i;
    printf("type: %s\n", cdata->type);
    printf("a: %lf\n", cdata->a);
    printf("burgersv: %lf\n", cdata->burgersv);
    printf("npeaks: %d\n", cdata->npeaks);
    printf("indices:\nn h k l\n");
    for(i = 0; i < cdata->npeaks; i++)
        printf("%d %d %d %d\n", i + 1, cdata->indices[i][0], cdata->indices[i][1], cdata->indices[i][2]);
    printf("\nH^2:\n");
    for(i = 0; i < cdata->npeaks; i++)
        printf("%d %lf\n", i + 1, cdata->H2[i]);
    printf("\nwarrenc^2:\n");
    for(i = 0; i < cdata->npeaks; i++)
        printf("%d %lf\n", i + 1, cdata->warrenc[i]);
    getchar();
}

void printf_auxdata(aux_data *adata)
{
    printf("lambda: %lf\n", adata->lambda);
    printf("delta_min: %lf\n", adata->delta_min);
    printf("delta_step: %lf\n", adata->delta_step);
    printf("delta_max: %lf\n", adata->delta_max);
    printf("q_min: %lf\n", adata->q_min);
    printf("q_step: %lf\n", adata->q_step);
    printf("q_max: %lf\n", adata->q_max);
    printf("Ch00_min: %lf\n", adata->Ch00_min);
    printf("Ch00_step: %lf\n", adata->Ch00_step);
    printf("Ch00_max: %lf\n", adata->Ch00_max);
    getchar();
}

void print_xy(double * x, double * y, double * y_err, int size)
{
    int i;
    printf("\nx    y    y_err\n");
    for(i = 0; i < size; i++)
        printf("%lf   %lf   %lf\n", x[i], y[i], y_err[i]);
    getchar();
}

void print_stats(linear_fit * fit_data, int xsize)
{
    int i;
    printf("\nn_out_params: %d\n", fit_data->n_out_params);
    printf("m = %lf\th = %lf\n", fit_data->m, fit_data->h);
    printf("\nx    y    y_err\n");
    for(i = 0; i < xsize; i++)
        printf("%lf   %lf   %lf\n", fit_data->x[i], fit_data->y[i], fit_data->y_err[i]);
    printf("R = %lf\tchisq = %lf\n", fit_data->R, fit_data->chisq);
    printf ("# covariance matrix:\n");
    printf ("# [ %g, %g\n#   %g, %g]\n", fit_data->covar[0][0], fit_data->covar[0][1], fit_data->covar[0][1], fit_data->covar[1][1]);
    getchar();
}

void read_input(FILE *fp, file_data *fdata, crystal_data *cdata, aux_data *adata)
{
    char buf[500];
    int i = 0, j = 0, v[3];
    //printf("Lectura del primer bloque de datos\n");
    fscanf(fp, "%s %s", buf, fdata -> outPath);
    fgets(buf, 500, fp);
    fgets(buf, 500, fp);
    fgets(buf, 500, fp);

    //printf("Lectura del segundo bloque de datos\n");
    fscanf(fp, "%s %s", buf, fdata -> inputPath);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s", buf, fdata -> filename);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s", buf, fdata -> fileext);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %d", buf, buf, &fdata -> start);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %d", buf, buf, &fdata -> end);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %s", buf, buf, fdata -> is_corr);
    for(j = 0; fdata->is_corr[j]; j++)
        fdata->is_corr[j] = toupper((unsigned char) fdata->is_corr[j]);//convierto lo que lei a mayusculas
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %s %s", buf, buf, buf, fdata -> is_H);
    for(j = 0; fdata->is_H[j]; j++)
        fdata->is_H[j] = toupper((unsigned char) fdata->is_H[j]);//convierto lo que lei a mayusculas
    fgets(buf, 500, fp);
    fscanf(fp, "%s %d", buf, &fdata -> model);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> lambda);
    fgets(buf, 500, fp);
    fgets(buf, 500, fp);

    //printf("Lectura del tercer bloque de datos\n");
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %s", buf, buf, cdata -> type);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %lf", buf, buf, &cdata -> a);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %s %s %s %s %d %d %d", buf, buf, buf, buf, buf, &v[0], &v[1], &v[2]);
    fgets(buf, 500, fp);
    cdata->burgersv = burgers(cdata->a, v);
    fscanf(fp, "%s %s %s %d", buf, buf, buf, &cdata -> npeaks);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> delta_min);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> delta_step);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> delta_max);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> q_min);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> q_step);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> q_max);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> Ch00_min);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> Ch00_step);
    fgets(buf, 500, fp);
    fscanf(fp, "%s %lf", buf, &adata -> Ch00_max);
    fgets(buf, 500, fp);
    fgets(buf, 500, fp);

    //printf("Lectura del cuarto bloque de datos\n");
    fgets(buf, 500, fp);
    fgets(buf, 500, fp);
    cdata->indices = matrix_int_alloc(cdata -> npeaks, 3);
    while(i < cdata->npeaks)
    {
        fscanf(fp, "%d", &cdata -> indices[i][0]);
        fscanf(fp, "%d", &cdata -> indices[i][1]);
        fscanf(fp, "%d", &cdata -> indices[i][2]);
        i++;
    }
}

int read_pole_figures(file_data * fdata, angles_grad * angles, shape_params * widths)
{
    FILE * fp_in;
    char name[500], buf[1000];
    int i, linecount;
    double dbuf;
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
        fgets(buf, 500, fp_in);//skip line
        while(fscanf(fp_in, "%d", &linecount) != EOF)
        {
            //printf("Leyendo linea %d\n", linecount);
            fscanf(fp_in, "%lf", &angles->dostheta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->theta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->alpha_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &angles->beta_grad[i][linecount - 1]);
            fscanf(fp_in, "%lf", &dbuf); //sabo int
            fscanf(fp_in, "%lf", &dbuf); //int
            fscanf(fp_in, "%lf", &dbuf); //error int
            fscanf(fp_in, "%lf", &widths->FWHM[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->FWHM_err[i][linecount - 1]);
            fscanf(fp_in, "%lf", &dbuf); //eta
            fscanf(fp_in, "%lf", &dbuf); //error
            fscanf(fp_in, "%lf", &widths->breadth[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->breadth_err[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->FWHM_corr[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->FWHM_corr_err[i][linecount - 1]);
            fscanf(fp_in, "%lf", &dbuf); //eta_corr
            fscanf(fp_in, "%lf", &dbuf); //error
            fscanf(fp_in, "%lf", &widths->breadth_corr[i][linecount - 1]);
            fscanf(fp_in, "%lf", &widths->breadth_corr_err[i][linecount - 1]);
        }
        fclose(fp_in);
    }//end for routine for(i = fdata->start - 1; i < fdata->end - 1; i++)
    printf("Cada figura de polos consta de %d puntos\n", linecount);
    return linecount;
}

void print_results(file_data * fdata, FILE * fp, double ** fit_results, linear_fit * fit_data, int nlines, angles_grad * angles, crystal_data * cdata)
{
    int i, j;
    double b2 = pow(cdata->burgersv, 2);
    double c = 2 / (M_PI * b2), wh_results[fit_data->n_out_params][nlines];
    if(strcmp(fdata->is_H, "FWHM") == 0)
    {
        fprintf(fp, "# alpha        beta          delta     q       Ch00       D    M^2 \\ro    R    chi2\n");
        for(i = 0; i < nlines; i++)
        {
            wh_results[0][i] = fit_results[0][i]; //delta
            wh_results[1][i] = fit_results[1][i]; //q
            wh_results[2][i] = fit_results[2][i]; //Ch00
            wh_results[3][i] = 0.9 / fit_results[3][i]; //D = 0.9 / h
            wh_results[4][i] = c * pow(fit_results[4][i], 2); //M^2 \ro = alpha * m^2
            wh_results[5][i] = fit_results[5][i]; //R
            wh_results[6][i] = fit_results[6][i]; //chisq
            fprintf(fp, "%d %lf    %lf    ", i + 1, angles->alpha_grad[0][i], angles->beta_grad[0][i]);
            for(j = 0; j < 7; j++)
                fprintf(fp, "%7.5lf  ", wh_results[j][i]);
            fprintf(fp, "\n");
        }
    }
    else
    {
        fprintf(fp, "# alpha        beta          delta     q       Ch00       D    M^2 \\ro    R    chi2\n");
        for(i = 0; i < nlines; i++)
        {
            wh_results[0][i] = fit_results[0][i]; //delta
            wh_results[1][i] = fit_results[1][i]; //q
            wh_results[2][i] = fit_results[2][i]; //Ch00
            wh_results[3][i] = 1.0 / fit_results[3][i]; //D = 1.0 / h
            wh_results[4][i] = c * pow(fit_results[4][i], 2); //M^2 \ro = alpha * m^2
            wh_results[5][i] = fit_results[5][i]; //R
            wh_results[6][i] = fit_results[6][i]; //chisq
            fprintf(fp, "%d %lf    %lf    ", i + 1, angles->alpha_grad[0][i], angles->beta_grad[0][i]);
            for(j = 0; j < 7; j++)
                fprintf(fp, "%7.5lf  ", wh_results[j][i]);
            fprintf(fp, "\n");
        }
    }//end if(strcmp(fdata->is_H, "FWHM") == 0)
}
