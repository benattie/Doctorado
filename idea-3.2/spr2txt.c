#include <stdlib.h>
#include <stdio.h>
#include <math.h>
//#include <fcntl.h>
//#include <ctype.h>
#include <string.h>
//#include <unistd.h>
//#include <sys/types.h>
//#include <sys/stat.h>
#include <time.h>

#include "pv.c"
#include "read_files.c"

int main(int argc, char ** argv)
{
 char *getval = malloc(sizeof(char) * (1024 + 1));
 int rv = 0;
 int Z, a, b, i, j, k, m, n, x, y, z, count, anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome;
 int BG_l, BG_r;
 int NrSample, star_d, end_d, del_d, numrings;
 int posring_l[15], posring_r[15], ug_l[15], ug_r[15];
 int pixel_number, gamma;
 int seeds_size, bg_size, n_peaks;
 int data[2500], intensity;
 double intens_av[1800], peak_intens_av[10];
 double data1[2500], BG_m, intens[500][10];
 double theta[20], neu_ome, neu_gam, alpha, beta, th;
 double pixel, dist;
 double ***sabo_inten = r3_tensor_double_alloc(40, 500, 10);
 double ***fit_inten = r3_tensor_double_alloc(40, 500, 10), ***fit_inten_err = r3_tensor_double_alloc(40, 500, 10);
 double ***fwhm = r3_tensor_double_alloc(40, 500, 10), ***fwhm_err = r3_tensor_double_alloc(40, 500, 10);
 double ***eta = r3_tensor_double_alloc(40, 500, 10), ***eta_err = r3_tensor_double_alloc(40, 500, 10);
 double ***fwhm_ins = r3_tensor_double_alloc(40, 500, 10), ***eta_ins = r3_tensor_double_alloc(40, 500, 10);
 double ***breadth = r3_tensor_double_alloc(40, 500, 10), ***breadth_ins = r3_tensor_double_alloc(40, 500, 10);
 double ***breadth_err = r3_tensor_double_alloc(40, 500, 10);
 double ** seeds, ** bg_seed;
 char buf_temp[1024], buf[1024], buf1[1024];
 char path_out[150], path [150], filename[100], inform[10];
 char alldatafile[200];
 char marfile[150];
 FILE *fp, *fp1, *fp_IRF, *fp_fit, *fp_all;
 IRF ins;
 time_t timer;
 struct tm *zeit;

 puts("\n***************************************************************************");
 puts("\nPROGRAM: FIT2D_DATA.EXE, Ver. 04.14");
 puts("\nProgram for generating the pole figures from Fit2D data.\nCoodinate-transformation to MTEX-Format.");
 puts("Pole figure in MTEX-readable format xxx_Nr.mtex.");
 puts("\nThe angular values of Omega and Gamma, from the parameter file\n");
 puts("Options: \n 1. Replacement negative intensity values to ZERO\n 2. Intensity correction with LogFile.txt\n");
 puts("Error or suggestion to sangbong.yi@hzg.de");
 puts("Error or suggestion with respect to generalized pole figure routin to benatti@ifir-conicet.gov.ar");
 puts("\n****************************************************************************");
 //LECTURA DEL ARCHIVO para_fit2d.dat
 if((fp = fopen("para_fit2d.dat", "r")) == NULL ){
     fprintf(stderr, "Error opening file para_fit2d.txt\n"); exit(1);
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
    //umbral que determinal cual es la intensidad minima para que ajusto un pico
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%lf", &th); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 20, fp); getval = fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    getval = fgets(buf_temp, 22, fp);
    rv = fscanf(fp, "%d", &numrings); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 50, fp); getval = fgets(buf_temp, 50, fp);

    for(i = 0; i < numrings; i++){ //itera sobre cada pico (0 a 7) -> (1 a 8)
        rv = fscanf(fp, "%lf", &theta[i]); //posicion angular del centro del pico (\theta)
        rv = fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
        rv = fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
        rv = fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
        rv = fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico
    }// End of reading the parameter file for(i=0;i<numrings;i++)
    if(getval == NULL) 
        printf("\nWARNING (fgets): There were problems while reading para_fit2d.dat\n");
    if(rv == 0 || rv == EOF) 
        printf("\nWARNING (fscanf): there were problems reading param data in para_fit2d.dat (%d)\n", rv);

    getval = fgets(buf_temp, 2, fp); //skip line
    //Reading of intrumental width files
    if((fp_IRF = fopen("IRF.dat", "r")) == NULL ){
        fprintf(stderr, "Error opening file IRF.dat\n"); exit(1);
    }
    ins = read_IRF(fp_IRF);
    fclose(fp_IRF);
    if(getval == NULL) 
        printf("\nWARNING (fgets): There were problems while reading IRF.dat\n");

    //Reading of initial parameters
    if((fp_fit = fopen("fit_ini.dat", "r")) == NULL ){
        fprintf(stderr, "Error opening file fit_ini.dat\n"); exit(1);
    }
    getval = fgets(buf, 250, fp_fit);//leo el titulo
    getval = fgets(buf, 250, fp_fit);//leo el encabezado
    rv = fscanf(fp_fit, "%d", &n_peaks);
    rv = fscanf(fp_fit, "%d", &bg_size);
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    bg_seed = matrix_double_alloc(2, bg_size);
    getval = fgets(buf, 250, fp_fit);//skip line
    read_file(fp_fit, seeds, seeds_size, bg_seed, bg_size);
    //print_seeds(seeds[0], seeds_size, bg_seed, bg_size);
    if(getval == NULL) 
        printf("\nWARNING (fgets): There were problems while reading fit_ini.dat\n");

    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, theta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);

    //si le paso el valor de treshold por linea de comandos que se olvide de lo que esta en archivo
    if(argc == 2)
      th = atof(argv[1]);
    //printf("\n\n%lf\n\n", th);
    //getchar();

    for(k = star_d; k <= end_d; k += del_d){ //Iteracion sobre todos los spr  
        //selecciono el archivo spr que voy a procesar
        strcpy(marfile, path);
        strcat(marfile, filename);
        sprintf(buf, "%d", k);
        if(k < 10)
            sprintf(buf1, "0000");
        if(k >= 10 && k < 100)
            sprintf(buf1, "000");
        if(k >= 100)
            sprintf(buf1, "00");
        strcat(marfile, buf1);
        strcat(marfile, buf);
        strcat(marfile, ".");
        strcat(marfile, inform);

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
        memset(intens_av, 0, 1800 * sizeof(double));
        memset(peak_intens_av, 0, 10 * sizeof(double));
        for(n = 0; n < numrings; n++){ //error handler para cuando tenga un bad_fit en el caso spr=1 y gamma=1
            sabo_inten[0][0][n] = -1;
            fit_inten[0][0][n] = -1;
            fwhm[0][0][n] = -1;
            eta[0][0][n] = -1;
            breadth[0][0][n] = -1;
            fwhm_ins[0][0][n] = -1;
            eta_ins[0][0][n] = -1;
            breadth_ins[0][0][n] = -1;
            fit_inten_err[0][0][n] = -1;
            fwhm_err[0][0][n] = -1;
            eta_err[0][0][n] = -1;
            breadth_err[0][0][n] = -1;
        }
        
        //printf("Data Read-in\n");
        for(y = 1; y <= gamma; y++){ //itero sobre todos los difractogramas (360) (recorro el anillo de Debye)
            for(x = 1; x <= pixel_number; x++){ //iteracion dentro de cada uno de los difractogramas (con 1725 puntos) (cada porcion del anillo de Debye)
                //leo la intensidad de cada bin y la paso a formato de entero
                rv = fscanf(fp1, "%le", &data1[x]);
                intens_av[x] += data1[x];
                data[x] = (int)data1[x];
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
                exp_data sync_data = {dist, pixel, pixel_number, ins};
                //structure holding difractograms and fitting information
                err_fit_data fit_errors = {fit_inten_err, fwhm_err, eta_err, breadth_err};
                peak_shape_data shapes = {fwhm, fwhm_ins, eta, eta_ins, breadth, breadth_ins};
                peak_data difra = {numrings, bg_size, k, star_d, y, del_gam, th, data1, bg_seed, fit_inten, &shapes, &fit_errors};
                //Int, fwhm & eta fitting
                pv_fitting(exists, &sync_data, &difra, peak_intens_av, seeds);
                memset(intens_av, 0, 1800 * sizeof(double));
                memset(peak_intens_av, 0, 10 * sizeof(double));
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
        //Imprimo el tiempo de ejecucion del programa en el .mtex
        fprintf(fp_all, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_all, "#        Row       2theta        theta        alpha         beta       raw_int       fit_int            err");
        fprintf(fp_all, "             H            err           eta            err       Breadth            err");
        fprintf(fp_all, "       H_corr             err      eta_corr            err     Breadth_corr         err");
        fprintf(fp_all, "\n");
        
        k = 0;//contador del archivo mtex
        n = 1; //indice que me marca el spr
        // tranformacion angular (gamma, omega)-->(alpha,beta)
        for(i = anf_ome; i <= ende_ome; i += del_ome){ //itero sobre \omega
            for(j = anf_gam; j <= ende_gam; j += del_gam){ //itero sobre \gamma
                neu_ome = i;
                neu_gam = j;
                // transformacion geometrica
                if(neu_ome > 90){
                    neu_ome = neu_ome - 90;
                    neu_gam = neu_gam + 180;
                }
                alpha = winkel_al(theta[m], neu_ome, neu_gam);
                beta  = winkel_be(theta[m], neu_ome, neu_gam, alpha);
                    
                if(alpha > 90){
                    alpha = 180 - alpha;
                    beta = 360 - beta;
                }
                //
                // Veremos si con esto invierto correctamente el hemisferio sur
                /*
                if(neu_ome > 90){
                    if(beta > 0 && beta <= 90)
                        beta = 360 - beta;
                    if(beta > 270 && beta < 360)
                        beta = 360 - beta;
                }
                */


                //correccion de los datos mal ajustados
                if(fwhm[n][j + del_gam][m] == -1.0){
                    smooth(fwhm, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(fwhm_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(breadth, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(breadth_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(fwhm_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(eta_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    smooth(breadth_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                }
                else{
                    if(eta[n][j + del_gam][m] == -1.0){
                        smooth(eta, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(eta_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(breadth, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(breadth_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(eta_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        smooth(breadth_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                    }
                }             
                //salida del archivo con todos los datos
                fprintf(fp_all, "%12d %12.4f %12.4f %12.4f %12.4f %13.5f ", k + 1, 2 * theta[m], theta[m], alpha, beta, sabo_inten[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", fit_inten[n][j + del_gam][m], fit_inten_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", fwhm[n][j + del_gam][m], fwhm_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", eta[n][j + del_gam][m], eta_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", breadth[n][j + del_gam][m], breadth_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", fwhm_ins[n][j + del_gam][m], fwhm_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf ", eta_ins[n][j + del_gam][m], eta_err[n][j + del_gam][m]);
                fprintf(fp_all, "%13.5lf  %13.5lf\n", breadth_ins[n][j + del_gam][m], breadth_err[n][j + del_gam][m]);
                //////////////////////////////////////////////////////////////////////////////////////////////////
                k++;
            }//end for routine for(j = anf_gam; j <= ende_gam; j += del_gam)
            n++;
        }//end for routine for(i = anf_ome; i <= ende_ome; i += del_ome)
        fflush(fp_all);
        fclose(fp_all);
    }// End for(m = 0; m < numrings; m++)
    printf("\n======= End angular transformation ======= \n");
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    free_double_matrix(seeds, 2);
    free_double_matrix(bg_seed, 2);
 }//End of for(Z = 1; Z <= NrSample; Z++)
 fclose(fp);
 free_r3_tensor_double(sabo_inten, 40, 500);
 free_r3_tensor_double(fit_inten, 40, 500);
 free_r3_tensor_double(fit_inten_err, 40, 500);
 free_r3_tensor_double(fwhm, 40, 500);
 free_r3_tensor_double(fwhm_ins, 40, 500);
 free_r3_tensor_double(fwhm_err, 40, 500);
 free_r3_tensor_double(eta, 40, 500);
 free_r3_tensor_double(eta_ins, 40, 500);
 free_r3_tensor_double(eta_err, 40, 500);
 free_r3_tensor_double(breadth, 40, 500);
 free_r3_tensor_double(breadth_ins, 40, 500);
 free_r3_tensor_double(breadth_err, 40, 500);
 printf("\nSólo un sujeto consciente de las fuerzas sociales que guían su práctica puede aspirar a controlar su destino\n");
 return 0;
} //End of Main()
