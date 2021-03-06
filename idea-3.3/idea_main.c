#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <time.h>

#include "pv.c"
#include "read_files.c"

#define Np 20
#define Nbins 2500
#define MSPR 1000
#define MPTRN 400
#define MSTR 1024

int main(int argc, char ** argv)
{
 char *getval = malloc(sizeof(char) * (MSTR + 1));
 int rv = 0;
 int Z, a, b, i, j, k, m, n, x, y, z, count, anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome;
 int BG_l, BG_r;
 int NrSample, star_d, end_d, del_d, numrings, npattern = 1;
 int posring_l[Np], posring_r[Np], ug_l[Np], ug_r[Np];
 int pixel_number, gamma;
 int seeds_size, bg_size, n_peaks;
 int data[Nbins], intensity;
 double intens_av[Nbins], peak_intens_av[Np];
 double data1[Nbins], BG_m, intens[512][Np];
 double twotheta[Np], neu_ome, neu_gam, alpha, beta, th;
 double pixel, dist;
 double ***sabo_inten = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***fit_inten = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***fit_inten_err = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***pos = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***pos_err = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***fwhm = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***fwhm_err = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***eta = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***eta_err = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***fwhm_ins = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***eta_ins = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***breadth = r3_tensor_double_alloc(MSPR, MPTRN, Np), ***breadth_ins = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ***breadth_err = r3_tensor_double_alloc(MSPR, MPTRN, Np);
 double ** seeds, ** bg_seed;
 char buf_temp[MSTR], buf[MSTR], buf1[MSTR];
 char path_out[MSTR], path [MSTR], filename[MSTR], inform[16], printfit[16], widthcorr[16];
 char alldatafile[MSTR];
 char marfile[MSTR];
 FILE *fp, *fp1, *fp_IRF, *fp_fit, *fp_all;
 IRF ins;
 SAMPLE_INFO sample;
 time_t timer;
 struct tm *zeit;

 puts("\n***************************************************************************");
 puts("\nPROGRAM: FIT2D_DATA.EXE, Ver. 04.14");
 puts("\nProgram for generating the pole figures from Fit2D data.\nCoodinate-transformation to MTEX-Format.");
 puts("Pole figure in MTEX-readable format xxx_Nr.mtex.");
 puts("\nThe angular values of Omega and Gamma, from the parameter file\n");
 puts("Error or suggestion to sangbong.yi@hzg.de");
 puts("Error or suggestion with respect to generalized pole figure routin to benatti@ifir-conicet.gov.ar");
 puts("Run with ./idea.exe parameter_file.dat fit_ini.ini IRF.dat");
 puts("Run with ./idea.exe parameter_file.dat fit_ini.ini IRF.dat treshold");
 puts("\n****************************************************************************");
 //LECTURA DEL ARCHIVO para_fit2d.dat
 if((fp = fopen(argv[1], "r")) == NULL ){
     fprintf(stderr, "Error opening file %s\n", argv[1]); exit(1);
 }
 //path hacia los archivos de salida
 getval = fgets(buf_temp, 22, fp);
 rv = fscanf(fp, "%s", path_out); getval = fgets(buf_temp, 2, fp);
 //numero de muestras a trabajar (1)
 getval = fgets(buf_temp, 22, fp);
 rv = fscanf(fp, "%d", &NrSample); getval = fgets(buf_temp, 2, fp);

 for(Z = 1; Z <= NrSample; Z++) // FOR-routine: whole routines
 {
    //skip lines
    getval = fgets(buf_temp, 2, fp); getval = fgets(buf_temp, 60, fp);
    getval = fgets(buf_temp, 2, fp);
    //path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%s", path);   getval = fgets(buf_temp, 2, fp);
    //lee raiz de los archivos spr (New_Al70R-tex_)
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%s", filename); getval = fgets(buf_temp, 2, fp);
    //lee la extension de los archivos (spr)
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%s", inform); getval = fgets(buf_temp, 2, fp);
    //numero asociado al primer spr (relacionado con omega)
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &star_d); getval = fgets(buf_temp, 2, fp);
    //angulo (\Omega) inicial 
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &anf_ome); getval = fgets(buf_temp, 2, fp);
    //numero asociado al ultimo spr
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &end_d); getval = fgets(buf_temp, 2, fp);
    //angulo (\Omega) final
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &ende_ome); getval = fgets(buf_temp, 2, fp);
    //delta en los spr
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &del_d); getval = fgets(buf_temp, 2, fp);
    //delta en el angulo \omega
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &del_ome); getval = fgets(buf_temp, 2, fp);
    //gamma inicial
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &anf_gam); getval = fgets(buf_temp, 2, fp);
    //gamma final
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &ende_gam); getval = fgets(buf_temp, 2, fp);
    //delta gamma
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &del_gam); getval = fgets(buf_temp, 2, fp);
    //Distancia de la muestra al detector
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%lf", &dist); getval = fgets(buf_temp, 2, fp);
    //Distancia que cubre un pixel en el difractograma
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%lf", &pixel); getval = fgets(buf_temp, 2, fp);
    //umbral que determina cual es la intensidad minima para que ajusto un pico
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%lf", &th); getval = fgets(buf_temp, 2, fp);
    // pregunto si imprimo los archivos con los ajustes
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%1s", printfit); getval = fgets(buf_temp, 2, fp);
    // ask wether I should take into account the thickness of the sample
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%1s", widthcorr); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 20, fp); getval = fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &numrings); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 50, fp); getval = fgets(buf_temp, 50, fp);

    for(i = 0; i < numrings; i++){ //itera sobre cada pico (0 a 7) -> (1 a 8)
        rv = fscanf(fp, "%lf", &twotheta[i]); //posicion angular del centro del pico (2*\theta)
        rv = fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
        rv = fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
        rv = fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
        rv = fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico
    }// End of reading the parameter file for(i=0;i<numrings;i++)
    // close parameter file
    fclose(fp);

    if(getval == NULL) 
        printf("\nWARNING (fgets): There were problems while reading %s\n", argv[1]);
    if(rv == 0 || rv == EOF) 
        printf("\nWARNING (fscanf): there were problems reading param data in %s (%d)\n", argv[1], rv);

    //Reading of intrumental width files
    if((fp_IRF = fopen(argv[3], "r")) == NULL ){
        fprintf(stderr, "Error opening file %s\n", argv[3]); exit(1);
    }
    read_IRF(fp_IRF, &ins, &sample);
    fclose(fp_IRF);

    //Reading of initial parameters
    if((fp_fit = fopen(argv[2], "r")) == NULL ){
        fprintf(stderr, "Error opening file %s\n", argv[2]); exit(1);
    }
    getval = fgets(buf, 250, fp_fit);//leo el titulo
    getval = fgets(buf, 250, fp_fit);//leo el encabezado
    rv = fscanf(fp_fit, "%d", &n_peaks);
    rv = fscanf(fp_fit, "%d", &bg_size);
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    bg_seed = matrix_double_alloc(2, bg_size);
    getval = fgets(buf, 250, fp_fit);//skip line
    if(getval == NULL) 
        printf("\nWARNING (fgets): There were problems while reading %s\n", argv[2]);

    read_file(fp_fit, seeds, seeds_size, bg_seed, bg_size);
    fclose(fp_fit);

    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, twotheta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);

    //si le paso el valor de treshold por linea de comandos que se olvide de lo que esta en archivo
    if(argc == 5)
      th = atof(argv[4]);
    //printf("\n\n%lf\n\n", th);
    //getchar();
    timer = time(NULL); // present time in sec
    zeit = localtime(&timer); // save "time in sec" into structure tm
    sprintf(buf, "%sfit_results.log", filename);
    if((fp_fit = fopen(buf, "w")) == NULL ){
        fprintf(stderr, "Error opening file %s\n", buf); exit(1);
    }
    fprintf(fp_fit, "\n------------------------------------------");
    fprintf(fp_fit, "\nIDEA FIT RESULTS: %2d-%2d-%4d %2d:%2d:%2d\n", zeit->tm_mday, zeit->tm_mon + 1, zeit->tm_year + 1900, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
    fprintf(fp_fit, "\n------------------------------------------\n");
    fclose(fp_fit); 
    char cmd[100];
    printf("Create fitting result directory\n");
    sprintf(cmd, "mkdir %sfitted_pattern", path_out);
    printf("done!\n");
    fflush(stderr);
    rv = system(cmd);

    for(k = star_d; k <= end_d; k += del_d){ //Iteracion sobre todos los spr  
        //selecciono el archivo spr que voy a procesar
        strcpy(marfile, path);
        strcat(marfile, filename);
        memset(buf1, 0, sizeof(buf1));
        sprintf(buf1, "%04d.%s", k, inform);
        strcat(marfile, buf1);

        printf("\nReading data from <====  %s\n", marfile);
        //abro el archivo spr del que voy a sacar las intensdades de los picos
        if((fp1 = fopen(marfile, "r")) == NULL){
            fprintf(stderr, "Error opening READ_file: %s \n", marfile); exit(1);
        }
        rv = fscanf(fp1, "%d", &pixel_number); //pixel number = los bin de los difractogramas
        rv = fscanf(fp1, "%d", &gamma); //gamma = cantidad de difractogramas (360 en este caso)
        getval = fgets(buf, 100, fp1); //skip line
        if(getval == NULL) 
            printf("\nWARNING (fgets): There were problems while reading pixel number in %s\n", marfile);
        if(rv == 0 || rv == EOF) 
            printf("\nWARNING (fscanf): there were problems reading pixel number in %s (%d)\n", marfile, rv);

        //printf("pixel=%d gamma=%d\n", pixel_number, gamma);
        memset(intens_av, 0, Nbins * sizeof(double));
        memset(peak_intens_av, 0, Np * sizeof(double));
        for(n = 0; n < numrings; n++){ //error handler para cuando tenga un bad_fit en el caso spr=1 y gamma=1
            sabo_inten[0][0][n] = -1;
            fit_inten[0][0][n] = -1;
            pos[0][0][n] = -1;
            fwhm[0][0][n] = -1;
            eta[0][0][n] = -1;
            breadth[0][0][n] = -1;
            fwhm_ins[0][0][n] = -1;
            eta_ins[0][0][n] = -1;
            breadth_ins[0][0][n] = -1;
            fit_inten_err[0][0][n] = -1;
            pos_err[0][0][n] = -1;
            fwhm_err[0][0][n] = -1;
            eta_err[0][0][n] = -1;
            breadth_err[0][0][n] = -1;
        }

        //printf("Data Read-in\n");
        for(y = 1; y <= gamma; y++){ //itero sobre todos los difractogramas (360) (recorro el anillo de Debye)
            for(x = 1; x <= pixel_number; x++){ //iteracion dentro de cada uno de los difractogramas (con 1725 puntos) (cada porcion del anillo de Debye)
                //leo la intensidad de cada bin y la paso a formato de entero
                rv = fscanf(fp1, "%le", &data1[x]);
                intens_av[x] += fabs(data1[x]);
                data[x] = abs((int)data1[x]);
                if(rv == 0 || rv == EOF) 
                    printf("\nWARNING (fscanf): there were problems reading data in column %d, line %d in %s (%d)\n", x, y, marfile, rv);
            }
            for(n = 0; n < numrings; n++){ //itero sobre todos los picos del difractograma
                intensity = 0;
                count = 0;
                //los bin en donde se encuentra la informacion del bg para el pico n del difractograma
                a = ug_l[n]; 
                b = ug_r[n];
                //valor de background correspondiente al bin del pico adecuado del difractograma correspondiente
                BG_l = data[a];
                BG_r = data[b];
                //background promedio
                BG_m = ((BG_l + BG_r) / 2);

                for(z = posring_l[n]; z <= posring_r[n]; z++){ //integro el pico
                    count++;
                    intensity += data[z];
                }                                       
                intens[y][n] = (intensity / count) - BG_m;  // Integral values and BG correction
                if(intens[y][n] >= 0) 
                    peak_intens_av[n] += intens[y][n];
            }
            // fiteo del difractograma para la obtencion del ancho de pico y eta
            if((y % del_gam) == 0){
                int exists = 1;
                if(y == del_gam) exists = 0; //pregunto si este es el primer archivo con el que estoy trabajando
                average(intens_av, peak_intens_av, del_gam, pixel_number, numrings);
                //guardo las intensidades calculadas a partir del algoritmo de Sang-Bon Yi
                for(n = 0; n < numrings; n++)
                    sabo_inten[k][y][n] = peak_intens_av[n];
                //structure holding syncrotron's information
                exp_data sync_data = {dist, pixel, pixel_number, ins, sample, path_out, filename, printfit, widthcorr};
                //structure holding difractograms and fitting information
                err_fit_data fit_errors = {fit_inten_err, pos_err, fwhm_err, eta_err, breadth_err};
                peak_shape_data shapes = {fwhm, fwhm_ins, eta, eta_ins, breadth, breadth_ins};
                int omega = k * del_ome - del_ome; // el angulo omega correspondiente al archivo spr k
                //peak_data difra = {numrings, bg_size, k, star_d, omega, y, del_gam, th, data1, bg_seed, fit_inten, pos, &shapes, &fit_errors};
                peak_data difra = {npattern, numrings, bg_size, k, star_d, omega, y, del_gam, th, intens_av, bg_seed, fit_inten, pos, &shapes, &fit_errors};
                //Int, fwhm & eta fitting
                //printf("Start fitting\n");
                pv_fitting(exists, &sync_data, &difra, peak_intens_av, seeds);
                npattern++;
                memset(intens_av, 0, Nbins * sizeof(double));
                memset(peak_intens_av, 0, Np * sizeof(double));
            } // if((y % del_gam) == 0) printf("Fin (%d %d)\n", k, y);
        } // end of for routine for(y = 1; y <= gamma; y++)
        fclose(fp1);
    } // end of spr iteration
    
    printf("\nFinish extracting pole figure data in Machine coordinates\n");
    
    ///// Angular Transformation to Pole figure coordinate ///
    printf("\n====== Begin angular transformation ====== \n");
    timer = time(NULL); // present time in sec
    zeit = localtime(&timer); // save "time in sec" into structure tm
    for(m = 0; m < numrings; m++){ //itero sobre todos los picos
        //EN ESTE ARCHIVO VOY A GUARDAR TODOS LOS DATOS JUNTOS
        strcpy(alldatafile, "");
        strcat(alldatafile, path_out);
        strcat(alldatafile, filename);
        strcat(alldatafile, "PF_");
        sprintf(buf, "%d", m + 1);
        strcat(alldatafile, buf);
        strcat(alldatafile, ".mtex");

        if((fp_all = fopen(alldatafile, "w")) == NULL){
            fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", alldatafile);
            exit(1);
        }
        printf("Printing irregular grid file %s\n", alldatafile);
        ////////////////////////////////////////////////////////////////////////////////////////////
        //Print header and execution time in the .mtex file
        fprintf(fp_all, "FIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_all, "Row       2theta      err       omega       gamma       alpha       beta 	     ");
        fprintf(fp_all, "raw_int     fit_int     err         FWHM        err         eta         err         ");
        fprintf(fp_all, "FWHM_corr   err         eta_corr    err\n");
        
        k = 1;// Pole figure number
        n = star_d; // spr index
        // Angular transformation (gamma, omega)-->(alpha,beta)
        for(i = anf_ome; i <= ende_ome; i += del_ome){ //itero sobre \omega
            for(j = anf_gam; j <= ende_gam; j += del_gam){ //itero sobre \gamma
                neu_ome = i;
                neu_gam = j;
                alpha = winkel_al(0.5*twotheta[m], neu_ome, neu_gam);
                beta  = winkel_be(0.5*twotheta[m], neu_ome, neu_gam, alpha);
                if(beta < 0)
                    beta = beta + 360.;
                // Thickness correction for intensities
                if(strcmp(widthcorr, "y") == 0 || strcmp(widthcorr, "Y") == 0){
                    double fw = correction_factor(sample, neu_ome, twotheta[m]);
                    sabo_inten[n][j + del_gam][m] /= fw;
                    fit_inten[n][j + del_gam][m] /= fw;
                    fit_inten_err[n][j + del_gam][m] /= fw;            
                }

                //correccion de los datos mal ajustados
                if(fwhm[n][j + del_gam][m] == -1.0){
                    smooth(fwhm, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(fwhm_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(fwhm_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                }
                else{
                    if(eta[n][j + del_gam][m] == -1.0){
                        smooth(eta, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(eta_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(eta_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    }
                }             
                //salida del archivo con todos los datos
                fprintf(fp_all, "%5d\t%8.4lf\t%8.4lf\t", k, pos[n][j + del_gam][m], pos_err[n][j + del_gam][m]);
                fprintf(fp_all, "%8.2f\t%8.2f\t", (float)(i), (float)(j));
                fprintf(fp_all, "%8.4lf\t%8.4lf\t%8.5lf\t", alpha, beta, sabo_inten[n][j + del_gam][m]);
                fprintf(fp_all, "%8.5lf\t%8.5lf\t", fit_inten[n][j + del_gam][m], fit_inten_err[n][j + del_gam][m]);
                fprintf(fp_all, "%8.5lf\t%8.5lf\t", fwhm[n][j + del_gam][m], fwhm_err[n][j + del_gam][m]);
                fprintf(fp_all, "%8.5lf\t%8.5lf\t", eta[n][j + del_gam][m], eta_err[n][j + del_gam][m]);
                fprintf(fp_all, "%8.5lf\t%8.5lf\t", fwhm_ins[n][j + del_gam][m], fwhm_err[n][j + del_gam][m]);
                fprintf(fp_all, "%8.5lf\t%8.5lf\t", eta_ins[n][j + del_gam][m], eta_err[n][j + del_gam][m]);
                fprintf(fp_all, "\n");
                //////////////////////////////////////////////////////////////////////////////////////////////////
                k++;
            }//end for routine for(j = anf_gam; j <= ende_gam; j += del_gam)
            n+=del_d;
        }//end for routine for(i = anf_ome; i <= ende_ome; i += del_ome)
        fflush(fp_all);
        fclose(fp_all);
    }// End for(m = 0; m < numrings; m++)
    printf("\n======= End angular transformation ======= \n");
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    free_double_matrix(seeds, 2);
    free_double_matrix(bg_seed, 2);
 }//End of for(Z = 1; Z <= NrSample; Z++)
 free_r3_tensor_double(sabo_inten, MSPR, MPTRN);
 free_r3_tensor_double(fit_inten, MSPR, MPTRN);
 free_r3_tensor_double(fit_inten_err, MSPR, MPTRN);
 free_r3_tensor_double(pos, MSPR, MPTRN);
 free_r3_tensor_double(pos_err, MSPR, MPTRN);
 free_r3_tensor_double(fwhm, MSPR, MPTRN);
 free_r3_tensor_double(fwhm_ins, MSPR, MPTRN);
 free_r3_tensor_double(fwhm_err, MSPR, MPTRN);
 free_r3_tensor_double(eta, MSPR, MPTRN);
 free_r3_tensor_double(eta_ins, MSPR, MPTRN);
 free_r3_tensor_double(eta_err, MSPR, MPTRN);
 free_r3_tensor_double(breadth, MSPR, MPTRN);
 free_r3_tensor_double(breadth_ins, MSPR, MPTRN);
 free_r3_tensor_double(breadth_err, MSPR, MPTRN);
 printf("\nSólo un sujeto consciente de las fuerzas sociales que guían su práctica puede aspirar a controlar su destino\n");
 return 0;
} //End of Main()
