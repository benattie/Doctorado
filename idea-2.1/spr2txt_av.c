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

int main()
{
 int Z, i, k, n, x, y;
 int a, b, z, count, c, d, count_minus;
 int BG_l, BG_r;
 int NrSample, star_d, end_d, star_a, end_a, del_d, del_a, rot_p, end_g, numrings;
 int posring_l[15], posring_r[15], ug_l[15], ug_r[15];
 int fd[15], ffinten[15], ffwhm[15], feta[15];

 int pixel_number, gamma, n_av;
 int data[2500], intensity;

 double pixel, dist;
 double ** fit_inten = matrix_double_alloc(500, 10);
 double ** fwhm = matrix_double_alloc(500, 10);
 double ** eta = matrix_double_alloc(500, 10);
 float intens_av[1800], peak_intens_av[10];
 float data1[2500], BG_m, intens[500][10];
 
 char buf_temp[100], buf[100], buf1[100], buf_finten[500], buf_fwhm[500], buf_eta[500];
 char path_out[150], path [150], filename1[100], inform[10], path1[150], inform1[10];
 char outfile[100], linfile[100], fit_intenfile[100], fwhmfile[100], etafile[100];
 char marfile[150];
 char outinten[3000], outfitinten[6000], outfwhm[6000], outeta[6000];
 char minus_zero; 
 char logfile_yn, logfile_yn_temp;
 
 FILE *fp, *fp1, *fp2, *fp3;
 FILE *fp_fitinten, *fp_fitinten_pf, *fp_fwhm, *fp_fwhm_pf, *fp_eta, *fp_eta_pf;

 struct DAT intensss;

 int j, l, m, step, anf_gam, ende_gam, del_gam;
 float anf_ome, ende_ome, del_ome;
 float m_intens, n_intens, nn_intens;
 double m_fintens, n_fintens, nn_fintens;
 double m_fwhm, n_fwhm, nn_fwhm;
 double m_eta, n_eta, nn_eta;
 float theta[20], neu_ome, neu_ome1, neu_gam1, neu_gam, alpha, beta;

 time_t timer;
 struct tm *zeit;

 puts("\n***************************************************************************");
 puts("\nPROGRAM: FIT2D_DATA.EXE, Ver. 03.14");
 puts("\nProgram for generating the pole figures from Fit2D data.\nCoodinate-transformation to MTEX-Format.");
 puts("Pole figure data xxx_Nr.dat Pole figure in MTEX-readable format xxx_Nr.mtex.");
 puts("\nThe angular values of Omega and Gamma, from the parameter file\n");
 puts("Options: \n 1. Replacement negative intensity values to ZERO\n 2. Intensity correction with LogFile.txt\n");
 puts("Error or suggestion to sangbong.yi@hzg.de");
 puts("\n****************************************************************************");
 //LECTURA DEL ARCHIVO para_fit2d.dat
 if((fp = fopen("para_fit2d.dat", "r")) == NULL )
 {
     fprintf(stderr, "Error opening file para_fit2d.txt."); exit(1);
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
    fscanf(fp, "%d", &star_a); fgets(buf_temp, 2, fp);
    //numero asociado al ultimo spr
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &end_d); fgets(buf_temp, 2, fp);
    //angulo (\Omega) final
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &end_a); fgets(buf_temp, 2, fp);
    //delta en los spr
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &del_d); fgets(buf_temp, 2, fp);
    //delta en el angulo \omega
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &del_a); fgets(buf_temp, 2, fp);
    //gamma inicial
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &rot_p); fgets(buf_temp, 2, fp);
    //gamma final
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &end_g); fgets(buf_temp, 2, fp);
    //delta gamma
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &n_av); fgets(buf_temp, 2, fp);
    //Distancia de la muestra al detector
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%lf", &dist); fgets(buf_temp, 2, fp);
    //Distancia que cubre un pixel en el difractograma
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%lf", &pixel); fgets(buf_temp, 2, fp);
    //flag que determina si las cuentas negativas se pasan a 0
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", &minus_zero); fgets(buf_temp, 2, fp);    
    //flag que determina si se genera el archivo .log?
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%s", &logfile_yn_temp); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, 2, fp);
    fgets(buf_temp, 15, fp);
    fgets(buf_temp, 2, fp);
    //numero de picos a analizar 
    fgets(buf_temp, 22, fp);
    fscanf(fp, "%d", &numrings); fgets(buf_temp, 2, fp); 
    //skip lines
    fgets(buf_temp, 22, fp); fgets(buf_temp, 2, fp);
    fgets(buf_temp, 33, fp); fgets(buf_temp, 1, fp);
    //le aviso al usuario el valor del flag que activa o desactiva la creacion del .log
    printf("\n correction log file = %s ", &logfile_yn_temp);
    logfile_yn = logfile_yn_temp;
    //le aviso al usuario el valor del flag que activa o desactiva la correccion de cuentas negativas
    printf("\n correction minus_zero = %s ", &minus_zero);
    //no se para que esta esto
    printf("\n log_file minus_zero = %s  \n" ,&logfile_yn);

    for(i = 0; i < numrings; i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
        fscanf(fp, "%f", &theta[i]); //posicion angular del centro del pico (\theta)
        fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
        fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
        fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
        fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico

    }// End of reading the parameter file for(i=0;i<numrings;i++)

    //Reading of intrumental width files
    FILE *fp_IRF = fopen("IRF.dat", "r");
    IRF ins; //anchos instrumentales
    ins = read_IRF(fp_IRF);
    fclose(fp_IRF);
    //Reading of initial parameters
    FILE * fit_fp;
    int seeds_size, bg_size, n_peaks;
    double ** seeds, ** bg_seed; 
    fit_fp = fopen("fit_ini.dat", "r");
    fgets(buf, 250, fit_fp);//leo el titulo
    fgets(buf, 250, fit_fp);//leo el encabezado
    fscanf(fit_fp, "%d", &n_peaks);
    fscanf(fit_fp, "%d", &bg_size);
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    bg_seed = matrix_double_alloc(2, bg_size);
    fgets(buf, 250, fit_fp);//skip line
    read_file(fit_fp, seeds, seeds_size, bg_seed, bg_size);
    //print_seeds(seeds[0], seeds_size, bg_seed, bg_size);
    fgets(buf_temp, 2, fp); //skip line
    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, theta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);

    k = star_d + 1;  // file index number : star_d to end_d
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
        /*Data Read-In */
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
                intensity = 0; count = 0;
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
            if((y % n_av) == 0)
            {
                int exists = 1;
                if(y == 5) exists = 0; //pregunto si este es el primer archivo con el que estoy trabajando
                average(intens_av, peak_intens_av, n_av, pixel_number, numrings);
                //structure holding syncrotron's information
                exp_data sync_data = {dist, pixel, pixel_number, ins};
                //structure holding difractograms information
                peak_data difra = {numrings, bg_size, k, y, data1, bg_seed, fit_inten, fwhm, eta};
                //Int, fwhm & eta fitting
                pv_fitting(exists, &sync_data, &difra, peak_intens_av, seeds);
                memset(intens_av, 0, 1800 * sizeof(float));
                memset(peak_intens_av, 0, 10 * sizeof(float));
            }
            //if(((y - 1) % 1) == 0) printf("Fin (%d %d)\n", k, y);
        }//end of for routine for(y = 1; y <= gamma; y++)
        
        //A esta altura ya termine de leer y procesar los datos de UN archivo spr. Falta imprimir los resultados a el archivo de salida
        for(d = 0; d < numrings; d++)//itero sobre todos los picos
        { 
            strcpy(outinten, "");
            strcpy(outfitinten, "");
            strcpy(outfwhm, "");
            strcpy(outeta, "");
            count_minus = 0;
            for(c = 1; c <= ((end_g - rot_p) + 1); c++) //itero sobre todo el anillo
            { 
                if(intens[c][d] < 0) //corrijo las intensidades negativas
                { 
                    if((minus_zero == 'y') || (minus_zero == 'Y'))
        		        intens[c][d] = 0; 
                    count_minus++;  
                }
                //escribo la intensidad integrada al archivo correspondiente en formato de diez columnas, separando por bloques los datos de cada pico
                sprintf(buf, "%8.3f", intens[c][d]);
                strcat(outinten, buf);
                if((c % n_av) == 0)
                {
                    sprintf(buf_finten, "%8.3lf ", fit_inten[c][d]);
                    strcat(outfwhm, buf_fwhm);
                    sprintf(buf_fwhm, "%8.5lf ", fwhm[c][d]);
                    strcat(outfwhm, buf_fwhm);
                    sprintf(buf_eta, "%8.5lf ", eta[c][d]);
                    strcat(outeta, buf_eta);
                }
                if((c % 10) == 0)
                    strcat(outinten, "\n");

                if((c % (10 * n_av)) == 0)
                {
                    strcat(outfitinten, "\n");
                    strcat(outfwhm, "\n");
                    strcat(outeta, "\n");
                }


                if(c == ((end_g - rot_p) + 1))
                {
                    strcat(outinten, "\n");
                    strcat(outfitinten, "\n");
                    strcat(outfwhm, "\n");
                    strcat(outeta, "\n");
                }
            }
            write(fd[d], outinten, strlen(outinten));
            write(ffinten[d], outfitinten, strlen(outfitinten));
            write(ffwhm[d], outfwhm, strlen(outfwhm));
            write(feta[d], outeta, strlen(outeta));            
	    
//            if(count_minus >= 1)//te avisa que tuviste picos con intensidades negativas
//                printf("\n!!Number of MINUS intensity in the [%d]th pole figure = %d !!! \n", d + 1, count_minus);
        }//end of for routine for(d = 0; d < numrings; d++)
        fclose(fp1);
        k += del_d; //paso al siguiente spr
    }
    while(k <= end_d); //end of spr iteration
    /*End pole figure data in Machine coordinates*/
    
    printf("\nReduction of the Fit2D-DATA is finished.\n%d pole figure data are generated.\n\n", d);
    
    for(d = 0; d < numrings; d++)
    {
        close(fd[d]);
        close(ffinten[d]);
        close(ffwhm[d]);
        close(feta[d]);
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    /**** Angular Transformation to Pole figure coordinate***/
    /**** LIN2GKSS-ROUTINE **********************************/
    printf("\n====== Begin angular transformation ====== \n");
    timer = time(NULL); // present time in sec
    zeit = localtime(&timer); // save "time in sec" into structure tm
    for(m = 0; m < numrings; m++)//itero sobre todos los picos
    {
        step = 1;//Si step > 1 lo que hago es promediar step's intensidades de la figura de polos en formato maquina
        ////////////////////////////////////////////////////////////////////////////////////////////
        //INTENSIDADES
        //genero string con el nombre del archivo con la figura de polos (intensidades) en el formato maquina
        strcpy(outfile, "");
        strcat(outfile, path_out);
        strcat(outfile, filename1);
        strcat(outfile, "PF_");
        sprintf(buf, "%d", m + 1);
        strcat(outfile, buf);

        if((logfile_yn == 'y')||(logfile_yn == 'Y'))
            strcat(outfile, ".log");
        else
            strcat(outfile, ".dat");
        
        if((fp2 = fopen(outfile, "r")) == NULL )
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", outfile); exit(1);
        }

        //genero el string con los datos en formato MTEX
        strcpy(linfile, "");
        strcat(linfile, path_out);
        strcat(linfile, filename1);
        strcat(linfile, "PF_");
        sprintf(buf, "%d", m + 1);
        strcat(linfile, buf);
        strcat(linfile, ".mtex");

        if((fp1 = fopen(linfile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", linfile); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //genero string con el nombre del archivo con la figura de polos (intensidades fiteadas) en el formato maquina
        strcpy(fit_intenfile, "");
        strcat(fit_intenfile, path_out);
        strcat(fit_intenfile, filename1);
        strcat(fit_intenfile, "INT_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(fit_intenfile, buf);
        strcat(fit_intenfile, ".dat");

        if((fp_fitinten = fopen(fit_intenfile, "r")) == NULL )
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", fit_intenfile); exit(1);
        }

        //genero el string con los datos en formato MTEX
        strcpy(fit_intenfile, "");
        strcat(fit_intenfile, path_out);
        strcat(fit_intenfile, filename1);
        strcat(fit_intenfile, "INT_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(fit_intenfile, buf);
        strcat(fit_intenfile, ".mtex");

        if((fp_fitinten_pf = fopen(fit_intenfile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", fit_intenfile); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //FWHM
        //genero string con el nombre del archivo con la figura de polos (fwhm) en el formato maquina
        strcpy(fwhmfile, "");
        strcat(fwhmfile, path_out);
        strcat(fwhmfile, filename1);
        strcat(fwhmfile, "FWHM_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(fwhmfile, buf);
        strcat(fwhmfile, ".dat");

        if((fp_fwhm = fopen(fwhmfile, "r")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", fwhmfile); exit(1);
        }

        strcpy(fwhmfile, "");
        strcat(fwhmfile, path_out);
        strcat(fwhmfile, filename1);
        strcat(fwhmfile, "FWHM_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(fwhmfile, buf);
        strcat(fwhmfile, ".mtex");

        if((fp_fwhm_pf = fopen(fwhmfile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", fwhmfile); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //ETA
        //genero string con el nombre del archivo con la figura de polos (eta) en el formato maquina
        strcpy(etafile, "");
        strcat(etafile, path_out);
        strcat(etafile, filename1);
        strcat(etafile, "ETA_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(etafile, buf);
        strcat(etafile, ".dat");

        if((fp_eta = fopen(etafile, "r")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", etafile); exit(1);
        }
        
        strcpy(etafile, "");
        strcat(etafile, path_out);
        strcat(etafile, filename1);
        strcat(etafile, "ETA_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(etafile, buf);
        strcat(etafile, ".mtex");

        if((fp_eta_pf = fopen(etafile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).", etafile); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //GRID
        //genero archivo con el grid de la figura de polos
        if((fp3 = fopen("PF_grid.dat", "w")) == NULL )
        {
            fprintf(stderr, "Error opening file PF_grid.dat"); exit(1);
        }
        ////////////////////////////////////////////////////////////////////////////////////////////
        //INTENSIDADES
        //leo el \gamma inicial, el final y el salto
        fgets(buf, 42, fp2);
        fscanf(fp2, "%d", &anf_gam);
        fscanf(fp2, "%d", &ende_gam);
        fscanf(fp2, "%d", &del_gam);
        
        fgets(buf, 2, fp2);//skip line
        
        //leo el \omega inicial, el final y el salto
        fgets(buf, 42, fp2);
        fscanf(fp2, "%f", &anf_ome);
        fscanf(fp2, "%f", &ende_ome);
        fscanf(fp2, "%f", &del_ome);
        
        printf("anf_gam=%5d , end_gam=%5d , del_gam=%5d \nanf_ome=%5.1f , end_ome=%5.1f , del_ome=%5.1f \n\n", anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome);
        //step_ome = abs((ende_ome - anf_ome) / del_ome);
        ////////////////////////////////////////////////////////////////////////////////////////////
        //FITTED INTENSITIES
        strcpy(buf_temp, "");
        fgets(buf_temp, 70, fp_fitinten);
        fgets(buf_temp, 70, fp_fitinten);
        fgets(buf_temp, 70, fp_fitinten);
        ////////////////////////////////////////////////////////////////////////////////////////////
        //FWHM
        strcpy(buf_temp, "");
        fgets(buf_temp, 70, fp_fwhm);
        fgets(buf_temp, 70, fp_fwhm);
        fgets(buf_temp, 70, fp_fwhm);
        ////////////////////////////////////////////////////////////////////////////////////////////
        //ETA
        strcpy(buf_temp, "");
        fgets(buf_temp, 70, fp_eta);
        fgets(buf_temp, 70, fp_eta);
        fgets(buf_temp, 70, fp_eta);
        ////////////////////////////////////////////////////////////////////////////////////////////
        if(ende_ome < anf_ome)
            del_ome = -1 * del_ome;
        
        //Imprimo el tiempo de ejecucion del programa en el .mtex
        fprintf(fp1, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_fitinten_pf, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_fwhm_pf, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
        fprintf(fp_eta_pf, "\nFIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec); 
        
        k = 0;//contador del archvo grid y el de mtex
        //tranformacion angular (gamma, omega)-->(alpha,beta)
        if(ende_ome > anf_ome)
        {
            i = anf_ome;
            while(i <= ende_ome)//itero sobre \omega
            {
                for(j = anf_gam; j <= ende_gam; j += del_gam)//itero sobre \gamma
                {
                    neu_gam1 = j;
                    neu_ome1 = i;
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
                    
                    //if(j % step == 0)
                    //{
                        n_intens = 0.0;
                        n_fintens = 0.0;
                        n_fwhm = 0.0;
                        n_eta = 0.0;
                        //for(l = 1; l <= step; l++)
                        //{
                            fscanf(fp2, "%f", &m_intens);//leo la intensidad de la figura de polos en formato maquina
                            n_intens += m_intens;
                            if((j % n_av) == 0)
                            {
                                fscanf(fp_fitinten, "%lf", &m_fintens);//leo la intesidad fiteada de la figura de polos en formato maquina
                                n_fintens += m_fintens;
                                fscanf(fp_fwhm, "%lf", &m_fwhm);//leo el ancho de pico de la figura de polos en formato maquina
                                n_fwhm += m_fwhm;
                                fscanf(fp_eta, "%lf", &m_eta);//leo el eta de la figura de polos en formato maquina
                                n_eta += m_eta;
                            }
                        //}
                        nn_intens = n_intens / step;
                        nn_fintens = n_fintens / step;
                        nn_fwhm = n_fwhm / step;
                        nn_eta = n_eta / step;

                        if(alpha > 90)
                        {
                            alpha = 180 - alpha;
                            beta = 360 - beta;
                        }
                        else
                            alpha = alpha;
                        
                        //imprimo las intensidades en formato figura de polos, asi como el grid
                        if(theta > 0)
                        {
                            fprintf(fp1, "%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n", k + 1, 2 * theta[m], theta[m], alpha, beta, nn_intens);
                            if((j % n_av) == 0)
                            {
                                fprintf(fp_fitinten_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.3f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, nn_fintens);
                                fprintf(fp_fwhm_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, nn_fwhm);
                                fprintf(fp_eta_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, nn_eta);
                            }
                        }
                        else
                        {
                            fprintf(fp1, "%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n", k + 1, -2 * theta[m], -1 * theta[m], alpha, beta, nn_intens);
                            if((j % n_av) == 0)
                            {
                                fprintf(fp_fitinten_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.3f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, nn_fintens);
                                fprintf(fp_fwhm_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, nn_fwhm);
                                fprintf(fp_eta_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, nn_eta);
                            }
                        }
                        fprintf(fp3, "%11d%10.1f%10.1f%10.4f%10.4f\n", k + 1, neu_ome, neu_gam, alpha, beta); 
                        k++;
                    //}// end if  if(j % step == 0)
                }//end for routine for(j = anf_gam; j <= ende_gam; j += del_gam)
                i += del_ome;
            }//end while routine while(i <= ende_ome)
        }
        else
        {
            i = anf_ome;
            while(i >= ende_ome)
            {
                for(j = anf_gam; j <= ende_gam; j += del_gam)
                {
                    neu_gam = j;
                    neu_ome = i;
                    
                    alpha = winkel_al(theta[m], neu_ome, neu_gam);
                    beta  = winkel_be(theta[m], neu_ome, neu_gam, alpha);
                    
                    fscanf(fp2, "%f", &m_intens);
                    if((j % n_av) == 0)
                    {
                        fscanf(fp_fitinten, "%lf", &m_fintens);                        
                        fscanf(fp_fwhm, "%lf", &m_fwhm);
                        fscanf(fp_eta, "%lf", &m_eta);
                    }
                    if(j % step == 0)
                    {
                        if(alpha > 90)
                        {
                            alpha = 180 - alpha;
                            beta = 360 - beta;
                        }
                        else
                            alpha = alpha;
                        
                        if(theta > 0)
                        {
                            fprintf(fp1, "%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n", k + 1, 2 * theta[m], theta[m], alpha, beta, m_intens);
                            if((j % n_av) == 0)
                            {
                                fprintf(fp_fitinten_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.3f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, m_fintens);
                                fprintf(fp_fwhm_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, m_fwhm);
                                fprintf(fp_eta_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, 2 * theta[m], theta[m], alpha, beta, m_eta);
                            }
                        }
                        else
                        {
                            fprintf(fp1, "%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n", k + 1, -2 * theta[m], -1 * theta[m], alpha, beta, m_intens);
                            if((j % n_av) == 0)
                            {
                                fprintf(fp_fitinten_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.3f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, m_fintens);
                                fprintf(fp_fwhm_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, m_fwhm);
                                fprintf(fp_eta_pf, "%11d%10.4f%10.4f%10.4f%10.4f%12.5f\n", (k + 1) / n_av, -2 * theta[m], -1 * theta[m], alpha, beta, m_eta);
                            }
                        }
                        fprintf(fp3, "%11d%10.1f%10.1f%10.4f%10.4f\n", k + 1, neu_ome, neu_gam, alpha, beta);
                        k++;
                    }
                }//end for routine for(j = anf_gam; j <= ende_gam; j += del_gam)
                i += del_ome;
            }//en while routine while(i >= ende_ome)
        }//end if if(ende_ome > anf_ome)
        fflush(fp1); fflush(fp2); fflush(fp3);
        fflush(fp_fitinten); fflush(fp_fitinten_pf);
        fflush(fp_fwhm); fflush(fp_fwhm_pf);
        fflush(fp_eta); fflush(fp_eta_pf);
        fclose(fp3); fclose(fp1); fclose(fp2);
        fclose(fp_fitinten); fclose(fp_fitinten_pf);
        fclose(fp_fwhm); fclose(fp_fwhm_pf);
        fclose(fp_eta); fclose(fp_eta_pf);
    }/* End for(m = 0; m < numrings; m++)*/
 }/*End of for(Z = 1; Z <= NrSample; Z++) */
 fclose(fp);

 printf("Rock'n'rolla\n");
 return 0;
} /*End of Main()*/
