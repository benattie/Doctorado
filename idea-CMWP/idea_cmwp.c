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
//#include "interpolate.c"
#define np 20
#define diffsize 2500
#define nspr 40
#define ngam 500
#define buffsize 2048

int main(int argc, char ** argv)
{
    FILE *fp, *fp1, *fp_fit, *fp_log;
    char buf_temp[buffsize], buf[buffsize], buf1[buffsize], path_out[buffsize], filename1[buffsize], path1[buffsize], inform1[buffsize], marfile[buffsize];
    char *getval = malloc(sizeof(char) * (250 + 1)), resultsf[buffsize], path_base[buffsize], base_filename[buffsize];
    static int del_gam, star_d, av_gam;
    int a, b, i, k, n, x, y, z, count, anf_gam, ende_gam, anf_ome, ende_ome, del_ome, rv, exists, npattern = 1;
    int BG_l, BG_r, end_d, del_d, numrings, posring_l[np], posring_r[np], ug_l[np], ug_r[np];
    int pixel_number, gamma, seeds_size, bg_size, intensity, miller[np], numphases, phase[np];
    int ** data = matrix_int_alloc(ngam, diffsize);
    double av_intensity[np], av_pattern[diffsize], data1[diffsize], BG_m, dos_theta[np], th;
    double pixel, dist, ** seeds, ** bg_seed, *dostheta = vector_double_alloc(np);
    double ***sabo_inten = r3_tensor_double_alloc(nspr, ngam, np), ** intens = matrix_double_alloc(ngam, np);
    double ***fit_inten = r3_tensor_double_alloc(nspr, ngam, np), ***fit_inten_err = r3_tensor_double_alloc(nspr, ngam, np);
    double ***fwhm = r3_tensor_double_alloc(nspr, ngam, np), ***fwhm_err = r3_tensor_double_alloc(nspr, ngam, np);
    double ***eta = r3_tensor_double_alloc(nspr, ngam, np), ***eta_err = r3_tensor_double_alloc(nspr, ngam, np);
    time_t t1, t2, t3, t4;
    double time_spent;
    //tomo el tiempo de ejecucion
    t1 = time(&t1);

    puts("****************************************************************************");
    puts("PROGRAM: IDEA_CMWP.EXE, Ver. XX.XX");
    puts("\nProgram for generating the pole figures from CMWP data.\nCoordinate-transformation to MTEX-Format.");
    puts("Pole figures in MTEX-readable format xxx_Nr.mtex.");
    puts("The angular values of Omega and Gamma, from the parameter file");
    puts("\nIn order to work this executable must be placed in CMWP instalation folder along with the python folder");
    puts("Python 2.7 required");
    puts("\nRun with:\n./idea_cmwp.exe para_cmwp.dat fit_ini.dat");
    puts("./idea_cmwp.exe para_cmwp.dat fit_ini.dat th");
    puts("para_cmwp.dat is a file with all the input parameters (you can use your own)");
    puts("fit_ini.dat is a file with all the seeds for the fits (you can use your own)");
    puts("th is the minimum peak intensity to be fitted (should be between 0 and 10)");
    puts("\nError or suggestions to benatti@ifir-conicet.gov.ar");
    puts("****************************************************************************");
    //imprimir la ayuda y salir
    if(argc != 1)
    {
        if(strcmp(argv[1], "info") == 0 || strcmp(argv[1], "help") == 0)
            exit(0);
    }
    //////////////////////////////////////////////////////////////////////////
    //LECTURA DEL ARCHIVO .ini
    //puts("Ingrese el nombre del archivo con los parámetros de entrada");
    //getval = fgets(buf, sizeof(buf), stdin);
    //sscanf(buf, "%s", buf1);
    if((fp = fopen(argv[1], "r")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", argv[1]);
        exit(1);
    }
    getval = fgets(buf_temp, sizeof(buf_temp), fp);

    // path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path1);   getval = fgets(buf_temp, sizeof(buf_temp), fp);
    // path hacia los archivos de salida
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path_out); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    // lee raiz de los archivos spr (New_Al70R-tex_)
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", filename1); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    // path a los archivos base del CMWP
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path_base); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    // raiz de los archivos base del CMWP
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", base_filename); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //lee la ubicacion de la carpeta de CMWP donde se almacenan todos los resultados
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", resultsf); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //lee la extension de los archivos (spr)
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", inform1); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //numero del primer spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &star_d); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //delta en los spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_d); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //numero del ultimo spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &end_d); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //angulo (\Omega) inicial 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &anf_ome); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //delta en el angulo \omega
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_ome); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //angulo (\Omega) final
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &ende_ome); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //gamma inicial
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &anf_gam); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //cuantos difractogramas del anillo de debye se promedian
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &av_gam); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //delta gamma
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_gam); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //gamma final
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &ende_gam); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //skip lines
    getval = fgets(buf_temp, sizeof(buf_temp), fp);
    getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //Distancia de la muestra al detector
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%lf", &dist); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //Distancia que cubre un pixel en el difractograma
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%lf", &pixel); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //umbral que determinal cual es la intensidad minima para que ajusto un pico
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%lf", &th); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //skip lines
    getval = fgets(buf_temp, 20, fp);
    getval = fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &numrings); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    // numero de fases a analizar
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &numphases); getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //skip lines
    getval = fgets(buf_temp, 50, fp);
    getval = fgets(buf_temp, 50, fp);

    for(i = 0; i < numrings; i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
      rv = fscanf(fp, "%d", &phase[i]);
      rv = fscanf(fp, "%d", &miller[i]);
      rv = fscanf(fp, "%lf", &dos_theta[i]); //posicion angular del centro del pico (\theta)
      rv = fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
      rv = fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
      rv = fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
      rv = fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico
    }
    getval = fgets(buf_temp, sizeof(buf_temp), fp); //skip line
    if(getval == NULL) printf("\nWARNING: There were problems while reading %s\n", argv[1]);
    if(rv == 0 || rv == EOF) printf("\nWARNING: there were problems reading the data in %s (%d)\n", argv[1], rv);
    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = 2Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, dos_theta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);
    fclose(fp);
    // control de que los parametros esten bien ingresados
    if(av_gam > del_gam)
    {
        fprintf(stderr, "Error: Average Gamma > Delta Gamma\n");
        exit(2);
    }

    // End of reading the parameter file
    //////////////////////////////////////////////////////////////////////////
    //Reading of initial parameters
    //puts("Ingrese el nombre del archivo con las semillas para los ajustes");
    //getval = fgets(buf, sizeof(buf), stdin);
    //sscanf(buf, "%s", buf1);
    if((fp_fit = fopen(argv[2], "r")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", argv[2]);
        exit(1);
    }
    getval = fgets(buf, 250, fp_fit);//leo el titulo
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    read_file(fp_fit, seeds, seeds_size);
    if(getval == NULL) printf("\nWARNING: There were problems while reading %s\n", argv[2]);
    fclose(fp_fit);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    strcat(path_base, base_filename);
    strcat(path_base, ".bg-spline.dat");
    if((fp_fit = fopen(path_base, "r")) == NULL)
    {
        fprintf(stderr, "Error opening file %s\n", path_base);
        exit(1);
    }
    //cuento cuantlas lineas tiene el archvio i.e. el numero de puntos de background
    n = 0;
    while(fgets(buf, sizeof(buf), fp_fit) != NULL)
      n++;
    bg_size = n;
    //printf("\nbg_size = %d\n", bg_size);
    //ahora lleno la matriz bg_seed con la posicion e intensidad de los puntos de background
    bg_seed = matrix_double_alloc(2, bg_size);
    rewind(fp_fit);
    n = 0;
    while(fscanf(fp_fit, "%lf", &bg_seed[0][n]) != EOF)
    {
      rv = fscanf(fp_fit, "%lf", &bg_seed[1][n]);
      n++;
    }
    if(rv == EOF) printf("\nWARNING: There were problems while reading background data in %s\n", path_base);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //si le paso el valor de treshold por linea de comandos que se olvide de lo que esta en archivos
    switch(argc)
    {
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        case 4:
            th = atof(argv[4]);
            break;
        default:
            printf("Numero incorrecto de argumentos\nUso correcto:\n");
            printf("./idea_cmwp.exe para_cmwp.dat fit_ini.dat\n./idea_cmwp para_cmwp.dat fit_ini.dat treshold\n");
            exit(1);
    }
    k = star_d;  // file index number : star_d to end_d
    for(k = star_d; k <= end_d; k += del_d) //Iteracion sobre todos los spr
    {
        //selecciono el archivo spr que voy a procesar
        strcpy(marfile, path1);
        strcat(marfile, filename1);
        memset(buf1, 0, sizeof(buf1));
        sprintf(buf1, "%04d.spr", k);
        strcat(marfile, buf1);

        printf("\nReading data from ====>  %s\n", marfile);
        //abro el archivo spr del que voy a sacar las intensdades de los picos
        if((fp1 = fopen(marfile, "r")) == NULL)
        {
            fprintf(stderr, "Error opening READ_file: %s \n", marfile);
            exit(1);
        }
        rv = fscanf(fp1, "%d", &pixel_number); //pixel number = los bin de los difractogramas
        rv = fscanf(fp1, "%d", &gamma); //gamma = cantidad de difractogramas (360 en este caso)
        getval = fgets(buf, 100, fp1); //skip line

        for(n = 0; n < numrings; n++)//error handler para cuando tenga un bad_fit en el caso spr=1 y gamma=1
        {
            sabo_inten[0][0][n] = -1;
            fit_inten[0][0][n] = -1;
            fwhm[0][0][n] = -1;
            eta[0][0][n] = -1;
            fit_inten_err[0][0][n] = -1;
            fwhm_err[0][0][n] = -1;
            eta_err[0][0][n] = -1;
        }
        //Data Read-In
        // printf("Data Read-in\n");
        exists = 0;
        for(y = 0; y <= gamma; y++) //itero sobre todos los difractogramas (360) (recorro el anillo de Debye)
        {
            //printf("gamma = %d\n", y);
            for(x = 1; x <= pixel_number; x++) //iteracion dentro de cada uno de los difractogramas (con 1725 puntos) (cada porcion del anillo de Debye)
            {
                //leo la intensidad de cada bin y la paso a formato de entero
                rv = fscanf(fp1, "%le", &data1[x]);
                data[y][x] = (int)data1[x];
            }
            n = 0; //numero de pico del difractograma
            for(n = 0; n < numrings; n++) //itero sobre todos los picos del difractograma
            {
                intensity = 0;
                count = 0;
                //los bin en donde se encuentra la informacion del bg para el pico n del difractograma
                a = ug_l[n]; 
                b = ug_r[n];
                //valor de background correspondiente al bin del pico adecuado del difractograma correspondiente
                BG_l = data[y][a];
                BG_r = data[y][b];
                //background promedio
                BG_m = ((BG_l + BG_r) / 2.);

                for(z = posring_l[n]; z <= posring_r[n]; z++) //integro el pico
                { 
                    count++;
                    intensity += data[y][z];
                }
                intens[y][n] = ((double)intensity / count) - BG_m;  // Integral values and BG correction
                if(intens[y][n] < 0) intens[y][n] = 0;
            }
            //fiteo del difractograma para la obtencion del ancho de pico y eta
            if((y + 1) % del_gam == 0)
            {
                memset(av_pattern, 0, diffsize * sizeof(double));
                memset(av_intensity, 0, np * sizeof(double));
                average(data, intens, y, av_gam, pixel_number, numrings, av_pattern, av_intensity);
                //guardo las intensidades calculadas a partir del algoritmo de Sang-Bon Yi
                for(n = 0; n < numrings; n++)
                    sabo_inten[k][y][n] = av_intensity[n];
                //structure holding syncrotron's information
                exp_data sync_data = {path_out, filename1, dist, pixel, pixel_number};
                //structure holding difractograms and fitting information
                err_fit_data fit_errors = {fit_inten_err, fwhm_err, eta_err};
                peak_shape_data shapes = {fwhm, eta};
                peak_data difra = {npattern, numrings, bg_size, k, star_d, y + 1, del_gam, th, phase, miller, dostheta, av_pattern, bg_seed, fit_inten, &shapes, &fit_errors};
                //Int, fwhm & eta fitting
                pv_fitting(filename1, exists, &sync_data, &difra, av_intensity, seeds);
                npattern++;
                exists = 1;
            }
            // if((y % del_gam) == 0) printf("Fin (%d %d)\n", k, y);
        }//end of for routine for(y = 1; y <= gamma; y++)
        fclose(fp1);
    }
    //End pole figure data in Machine coordinates//
    printf("\nFinished extracting pole figure data\n");
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    t2 = time(&t2);
    printf("\nBegin CMWP routine\n");
    char cmd[100];
    printf("Go ahead and have a cup of tea, this is gonna take a while\n");
    sprintf(cmd, "python python/cmwp.py %s %s", argv[1], argv[2]);
    rv = system(cmd);
    printf("End CMWP routine with code %d\n", rv);
    t3 = time(&t3);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    printf("Free allocated memory\n");
    free_int_matrix(data, ngam);
    free_double_matrix(intens, ngam);
    free_double_matrix(seeds, 2);
    free_double_matrix(bg_seed, 2);
    free(dostheta);
    free_r3_tensor_double(sabo_inten, nspr, ngam);
    free_r3_tensor_double(fit_inten, nspr, ngam);
    free_r3_tensor_double(fit_inten_err, nspr, ngam);
    free_r3_tensor_double(fwhm, nspr, ngam);
    free_r3_tensor_double(fwhm_err, nspr, ngam);
    free_r3_tensor_double(eta, nspr, ngam);
    free_r3_tensor_double(eta_err, nspr, ngam);
    t4 = time(&t4);
    time_spent = difftime(t4, t1);
    sprintf(buf, "%sexec_time.log", filename1);
    fp_log = fopen(buf, "a");
    sprintf(buf, "---------------------------------------------\n");
    sprintf(buf_temp, "Tiempo de ejecucion total del programa: %.2lf segundos\n", time_spent);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "                                      o %.2lf minutos\n", time_spent / 60.);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "                                      o %.2lf horas\n", time_spent / 3600.);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "---------------------------------------------\n");
    strcat(buf, buf_temp);
    printf("%s", buf);
    fprintf(fp_log, "%s", buf);
    time_spent = difftime(t3, t2);
    sprintf(buf, "---------------------------------------------\n");
    sprintf(buf_temp, "Tiempo de ejecucion total de la rutina CMWP: %.2lf segundos\n", time_spent);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "                                           o %.2lf minutos\n", time_spent / 60.);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "                                           o %.2lf horas\n", time_spent / 3600.);
    strcat(buf, buf_temp);
    sprintf(buf_temp, "---------------------------------------------\n");
    strcat(buf, buf_temp);
    printf("%s", buf);
    fprintf(fp_log, "%s", buf);
    fclose(fp_log);
    sprintf(buf, "cp %sexec_time.log %serrors.log %spvfit_result.log %scmwp_idea_files", filename1, filename1, filename1, path_out);
    rv = system(buf);
    printf("Programa finalizado.\nConsulte los archivos %spvfit_result.log, %serrors.log y exec_time.log para ver mas detalles\n", filename1, filename1);
    printf("\nNo importa la realidad, sólo la verosimilitud\n");
    return 0;
} //End of Main()
