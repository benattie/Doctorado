#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <fcntl.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#include "pv.c"
#include "read_files.c"

struct DAT {float old; float nnew;};

int main(int argc, char ** argv)
{
 int Z, a, b, i, j, k, m, n, x, y, z, count, anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome;
 int BG_l, BG_r;
 int NrSample, star_d, end_d, del_d, numrings;
 int posring_l[15], posring_r[15], ug_l[15], ug_r[15];
 int pixel_number, gamma;
 int seeds_size, bg_size, n_peaks;
 int data[2500], intensity;
 float intens_av[1800], peak_intens_av[10];
 float data1[2500], BG_m, intens[500][10];
 float theta[20], neu_ome, neu_ome1, neu_gam1, neu_gam, alpha, beta, th;
 double pixel, dist;
 double ***sabo_inten = r3_tensor_double_alloc(40, 500, 10);
 double ***fit_inten = r3_tensor_double_alloc(40, 500, 10), ***fit_inten_err = r3_tensor_double_alloc(40, 500, 10);
 double ***fwhm = r3_tensor_double_alloc(40, 500, 10), ***fwhm_err = r3_tensor_double_alloc(40, 500, 10);
 double ***eta = r3_tensor_double_alloc(40, 500, 10), ***eta_err = r3_tensor_double_alloc(40, 500, 10);
 double ***fwhm_ins = r3_tensor_double_alloc(40, 500, 10), ***eta_ins = r3_tensor_double_alloc(40, 500, 10);
 double ***breadth = r3_tensor_double_alloc(40, 500, 10), ***breadth_ins = r3_tensor_double_alloc(40, 500, 10);
 double ***breadth_err = r3_tensor_double_alloc(40, 500, 10);
 double ** seeds, ** bg_seed;
 char buf_temp[100], buf[100], buf1[100];
 char path_out[150], path [150], filename1[100], inform[10], path1[150], inform1[10];
 char alldatafile[200];
 char marfile[150];
 char minus_zero[1], logfile_yn_temp[1];
 FILE *fp, *fp1, *fp_IRF, *fp_fit, *fp_all;
 IRF ins;
 struct DAT intensss;
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
 if((fp = fopen("para_fit2d.dat", "r")) == NULL )
 {
     fprintf(stderr, "Error opening file para_fit2d.txt\n"); exit(1);
 }
 //path hacia los archivos de salida
 fgets(buf_temp, 22, fp);
 fscanf(fp, "%s", path_out);   fgets(buf_temp, 2, fp);
 //numero de muestras a trabajar (1)
 fgets(buf_temp, 22, fp);
 fscanf(fp, "%d", &NrSample);   fgets(buf_temp, 2, fp);

 for(Z = 1; Z <= NrSample; Z++) // FOR-routine: whole routines
 {
    //skip lines
    fgets(buf_temp, 2, fp);
    fgets(buf_temp, 60, fp);
    fgets(buf_temp, 2, fp);
    //path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", path);   fgets(buf_temp, 2, fp);
    //lee raiz de los archivos spr (New_Al70R-tex_)
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", filename1); fgets(buf_temp, 2, fp);
    //lee la extension de los archivos (spr)
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", inform); fgets(buf_temp, 2, fp);
    //pasa los contenidos de path e inform hacia path1 e inform1 (why?)
    strcpy(path1, path); strcpy(inform1, inform);
    //numero asociado al primer spr (relacionado con omega)
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &star_d); fgets(buf_temp, 2, fp);
    //angulo (\Omega) inicial 
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &anf_ome); fgets(buf_temp, 2, fp);
    //numero asociado al ultimo spr
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &end_d); fgets(buf_temp, 2, fp);
    //angulo (\Omega) final
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &ende_ome); fgets(buf_temp, 2, fp);
    //delta en los spr
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &del_d); fgets(buf_temp, 2, fp);
    //delta en el angulo \omega
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &del_ome); fgets(buf_temp, 2, fp);
    //gamma inicial
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &anf_gam); fgets(buf_temp, 2, fp);
    //gamma final
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &ende_gam); fgets(buf_temp, 2, fp);
    //delta gamma
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &del_gam); fgets(buf_temp, 2, fp);
    //Distancia de la muestra al detector
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%lf", &dist); fgets(buf_temp, 2, fp);
    //Distancia que cubre un pixel en el difractograma
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%lf", &pixel); fgets(buf_temp, 2, fp);
    //umbral que determinal cual es la intensidad minima para que ajusto un pico
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%f", &th); fgets(buf_temp, 2, fp);
    //flag que determina si las cuentas negativas se pasan a 0
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", minus_zero); fgets(buf_temp, 2, fp); 
    //flag que determina si se genera el archivo .log?
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", logfile_yn_temp); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, 20, fp);
    fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &numrings); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, 50, fp);
    fgets(buf_temp, 50, fp);
    //le aviso al usuario el valor del flag que activa o desactiva la creacion del .log
    printf("\nCorrection log file = %s", logfile_yn_temp);
    //le aviso al usuario el valor del flag que activa o desactiva la correccion de cuentas negativas
    printf("\nCorrection minus_zero = %s\n", minus_zero);

    for(i = 0; i < numrings; i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
        fscanf(fp, "%f", &theta[i]); //posicion angular del centro del pico (\theta)
        fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
        fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
        fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
        fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico

    }// End of reading the parameter file for(i=0;i<numrings;i++)
    fgets(buf_temp, 2, fp); //skip line
    //Reading of intrumental width files
    if((fp_IRF = fopen("IRF.dat", "r")) == NULL )
    {
        fprintf(stderr, "Error opening file IRF.dat\n"); exit(1);
    }
    ins = read_IRF(fp_IRF);
    fclose(fp_IRF);
    //Reading of initial parameters
    if((fp_fit = fopen("fit_ini.dat", "r")) == NULL )
    {
        fprintf(stderr, "Error opening file fit_ini.dat\n"); exit(1);
    }
    fgets(buf, 250, fp_fit);//leo el titulo
    fgets(buf, 250, fp_fit);//leo el encabezado
    fscanf(fp_fit, "%d", &n_peaks);
    fscanf(fp_fit, "%d", &bg_size);
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    bg_seed = matrix_double_alloc(2, bg_size);
    fgets(buf, 250, fp_fit);//skip line
    read_file(fp_fit, seeds, seeds_size, bg_seed, bg_size);
    //print_seeds(seeds[0], seeds_size, bg_seed, bg_size);
    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, theta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);

    //si le paso el valor de treshol por linea de comandos que se olvide de lo que esta en archivo
    if(argc == 2)
      th = atof(argv[1]);
    //printf("\n\n%lf\n\n", th);
    //getchar();

    k = star_d;  // file index number : star_d to end_d
    do //Iteracion sobre todos los spr  
    {
        //selecciono el archivo spr que voy a procesar
        strcpy(marfile, path1);
        strcat(marfile, filename1);
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
        strcat(marfile, "spr");

        printf("\nReading data from <====  %s\n", marfile);
        //abro el archivo spr del que voy a sacar las intensdades de los picos
        if((fp1 = fopen(marfile, "r")) == NULL)
        {
            fprintf(stderr, "Error opening READ_file: %s \n", marfile); exit(1);
        }
        fscanf(fp1, "%d", &pixel_number); //pixel number = los bin de los difractogramas
        fscanf(fp1, "%d", &gamma); //gamma = cantidad de difractogramas (360 en este caso)
        fgets(buf, 100, fp1); //skip line

        //printf("pixel=%d gamma=%d\n", pixel_number, gamma);
        memset(intens_av, 0, 1800 * sizeof(float));
        memset(peak_intens_av, 0, 10 * sizeof(float));
        for(n = 0; n < numrings; n++)//error handler para cuando tenga un bad_fit en el caso spr=1 y gamma=1
        {
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
        //Data Read-In
        //printf("Data Read-in\n");
        for(y = 1; y <= gamma; y++) //itero sobre todos los difractogramas (360) (recorro el anillo de Debye)
        {
            for(x = 1; x <= pixel_number; x++) //iteracion dentro de cada uno de los difractogramas (con 1725 puntos) (cada porcion del anillo de Debye)
            {
                //leo la intensidad de cada bin y la paso a formato de entero
                fscanf(fp1, "%e", &data1[x]);
                intens_av[x] += data1[x];
                data[x] = (int)data1[x];
            }
            n = 0; //numero de pico del difractograma
            do //itero sobre todos los picos del difractograma
            {
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

                for(z = posring_l[n]; z <= posring_r[n]; z++) //integro el pico
                { 
                    count++;
                    intensss.nnew = data[z];
                    intensity += intensss.nnew;
                }                                       
                intens[y][n] = (intensity / count) - BG_m;  // Integral values and BG correction
                if(intens[y][n] >= 0) 
                    peak_intens_av[n] += intens[y][n];
                n++;
            }
            while(n < numrings);
            //fiteo del difractograma para la obtencion del ancho de pico y eta
            if((y % del_gam) == 0)
            {
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
                memset(intens_av, 0, 1800 * sizeof(float));
                memset(peak_intens_av, 0, 10 * sizeof(float));
            }
            //if((y % del_gam) == 0) printf("Fin (%d %d)\n", k, y);
        }//end of for routine for(y = 1; y <= gamma; y++)
        fclose(fp1);
        k += del_d; //paso al siguiente spr
    }
    while(k <= end_d); //end of spr iteration
    /*End pole figure data in Machine coordinates*/
    printf("\nFinish extracting pole figure data in Machine coordinates\n");
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    /**** Angular Transformation to Pole figure coordinate***/
    /**** LIN2GKSS-ROUTINE **********************************/
    printf("\n====== Begin angular transformation ====== \n");
    timer = time(NULL); // present time in sec
    zeit = localtime(&timer); // save "time in sec" into structure tm
    for(m = 0; m < numrings; m++)//itero sobre todos los picos
    {
        //EN ESTE ARCHIVO VOY A GUARDAR TODOS LOS DATOS JUNTOS
        strcpy(alldatafile, "");
        strcat(alldatafile, path_out);
        strcat(alldatafile, filename1);
        strcat(alldatafile, "ALL_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(alldatafile, buf);
        strcat(alldatafile, ".mtex");

        if((fp_all = fopen(alldatafile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", alldatafile); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //Imprimo el tiempo de ejecucion del programa en el .mtex
        fprintf(fp_all, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_all, "#        Row       2theta        theta        alpha         beta       raw_int       fit_int            err");
        fprintf(fp_all, "             H            err           eta            err       Breadth            err");
        fprintf(fp_all, "       H_corr             err      eta_corr            err     Breadth_corr         err");
        fprintf(fp_all, "\n");
        
        k = 0;//contador del archvo grid y el de mtex
        n = 1; //indice que me marca el spr
        //tranformacion angular (gamma, omega)-->(alpha,beta)
        for(i = anf_ome; i <= ende_ome; i += del_ome)//itero sobre \omega
        {
            for(j = anf_gam; j <= ende_gam; j += del_gam)//itero sobre \gamma
            {
                neu_ome1 = i;
                neu_gam1 = j;
                //transformacion geometrica
                if(neu_ome1 > 90)
                {
                    neu_ome = neu_ome1 - 90;
                    neu_gam = neu_gam1 + 180;
                }
                else
                {
                    neu_ome = neu_ome1;
                    neu_gam = neu_gam1;
                } 
                alpha = winkel_al(theta[m], neu_ome, neu_gam);
                beta  = winkel_be(theta[m], neu_ome, neu_gam, alpha);
                    
                if(alpha > 90)
                {
                    alpha = 180 - alpha;
                    beta = 360 - beta;
                }
                else
                    alpha = alpha;
///////////////////////////////////////////////////////RUTINA DE CORRECCION DE DATOS//////////////////////////////////////////////////////////
                if(fit_inten[n][j + del_gam][m] == 0.0)
                {
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
                else
                {
                    if(fwhm[n][j + del_gam][m] <= 0.0)
                    {
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
                    else
                    {
                        if(eta[n][j + del_gam][m] <= 0.0)
                        {
                            smooth(eta, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(eta_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(breadth, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(breadth_err, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(fwhm_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(eta_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                            smooth(breadth_ins, n, j + del_gam, m, star_d, del_d, end_d, del_gam, del_gam, ende_gam);
                        }
                    }
                }
////////////////////////////////////////////////////////RUTINA DE CORRECCION DE DATOS////////////////////////////////////////////////////////
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
    }/* End for(m = 0; m < numrings; m++)*/
    printf("\n======= End angular transformation ======= \n");
 }/*End of for(Z = 1; Z <= NrSample; Z++) */
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
} /*End of Main()*/
