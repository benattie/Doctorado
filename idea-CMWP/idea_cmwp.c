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

struct DAT {float old; float nnew;};

int main(int argc, char ** argv)
{
    struct DAT intensss;
    FILE *fp, *fp1, *fp_fit, *fp_log;
    char buf_temp[1024], buf[1024], buf1[1024], path_out[1024], filename1[1024], path1[1024], inform1[1024], marfile[1024];
    char *getval = malloc(sizeof(char) * (250 + 1)), resultsf[1024], path_base[1024], base_filename[1024], minus_zero[1];
    static int del_gam, star_d;
    int a, b, i, k, n, x, y, z, count, anf_gam, ende_gam, anf_ome, ende_ome, del_ome, rv;
    int BG_l, BG_r, end_d, del_d, numrings, posring_l[15], posring_r[15], ug_l[15], ug_r[15];
    int pixel_number, gamma, seeds_size, bg_size, data[2500], intensity, miller[15];
    float intens_av[1800], peak_intens_av[10], data1[2500], BG_m, intens[500][10];
    float theta[20], th;
    double pixel, dist, ** seeds, ** bg_seed, *dostheta = vector_double_alloc(15);
    double ***sabo_inten = r3_tensor_double_alloc(40, 500, 10);
    double ***fit_inten = r3_tensor_double_alloc(40, 500, 10), ***fit_inten_err = r3_tensor_double_alloc(40, 500, 10);
    double ***fwhm = r3_tensor_double_alloc(40, 500, 10), ***fwhm_err = r3_tensor_double_alloc(40, 500, 10);
    double ***eta = r3_tensor_double_alloc(40, 500, 10), ***eta_err = r3_tensor_double_alloc(40, 500, 10);
    double ***breadth = r3_tensor_double_alloc(40, 500, 10), ***breadth_err = r3_tensor_double_alloc(40, 500, 10);
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
    puts("\nRun with:\n./idea_cmwp.exe\n./idea_cmwp.exe flag\n./idea_cmwp.exe flag th");
    puts("flag = 1 if you want to run CMWP and flag = 0 if you only want to create fitting files");
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
    //LECTURA DEL ARCHIVO para_fit2d.dat
    if((fp = fopen("para_cmwp.dat", "r")) == NULL)
    {
        fprintf(stderr, "Error opening file para_cmwp.dat\n");
        exit(1);
    }
    getval = fgets(buf_temp, sizeof(buf_temp), fp);

    //path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path1);   getval = fgets(buf_temp, 2, fp);
    //path hacia los archivos de salida
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path_out); getval = fgets(buf_temp, 2, fp);
    //lee raiz de los archivos spr (New_Al70R-tex_)
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", filename1); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", path_base); getval = fgets(buf_temp, 2, fp);
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", base_filename); getval = fgets(buf_temp, 2, fp);
    //lee la ubicacion de la carpeta de CMWP donde se almacenan todos los resultados
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", resultsf); getval = fgets(buf_temp, 2, fp);
    //lee la extension de los archivos (spr)
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", inform1); getval = fgets(buf_temp, 2, fp);
    //numero del primer spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &star_d); getval = fgets(buf_temp, 2, fp);
    //delta en los spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_d); getval = fgets(buf_temp, 2, fp);
    //numero del ultimo spr
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &end_d); getval = fgets(buf_temp, 2, fp);
    //angulo (\Omega) inicial 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &anf_ome); getval = fgets(buf_temp, 2, fp);
    //delta en el angulo \omega
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_ome); getval = fgets(buf_temp, 2, fp);
    //angulo (\Omega) final
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &ende_ome); getval = fgets(buf_temp, 2, fp);
    //gamma inicial
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &anf_gam); getval = fgets(buf_temp, 2, fp);
    //delta gamma
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &del_gam); getval = fgets(buf_temp, 2, fp);
    //gamma final
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &ende_gam); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, sizeof(buf_temp), fp);
    getval = fgets(buf_temp, sizeof(buf_temp), fp);
    //Distancia de la muestra al detector
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%lf", &dist); getval = fgets(buf_temp, 2, fp);
    //Distancia que cubre un pixel en el difractograma
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%lf", &pixel); getval = fgets(buf_temp, 2, fp);
    //umbral que determinal cual es la intensidad minima para que ajusto un pico
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%f", &th); getval = fgets(buf_temp, 2, fp);
    //flag que determina si las cuentas negativas se pasan a 0
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%s", minus_zero); getval = fgets(buf_temp, 2, fp); 
    //skip lines
    getval = fgets(buf_temp, 20, fp);
    getval = fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    getval = fgets(buf_temp, 22, fp); rv = fscanf(fp, "%d", &numrings); getval = fgets(buf_temp, 2, fp);
    //skip lines
    getval = fgets(buf_temp, 50, fp);
    getval = fgets(buf_temp, 50, fp);

    for(i = 0; i < numrings; i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
      rv = fscanf(fp, "%d", &miller[i]);
      rv = fscanf(fp, "%f", &theta[i]); //posicion angular del centro del pico (\theta)
      rv = fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
      rv = fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
      rv = fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
      rv = fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico
    }
    getval = fgets(buf_temp, 2, fp); //skip line
    if(getval == NULL) printf("\nWARNING: There were problems while reading para_cmwp.dat\n");
    if(rv == 0 || rv == EOF) printf("\nWARNING: there were problems reading peal data in para_cmwp.dat (%d)\n", rv);
    //imprime en pantalla los datos relevantes de cada pico 
    for(i = 0; i < numrings; i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n", i + 1, theta[i], posring_l[i], posring_r[i], ug_l[i], ug_r[i]);
    fclose(fp);
    // End of reading the parameter file
    //////////////////////////////////////////////////////////////////////////
    //Reading of initial parameters
    if((fp_fit = fopen("fit_ini.dat", "r")) == NULL)
    {
        fprintf(stderr, "Error opening file fit_ini.dat\n");
        exit(1);
    }
    getval = fgets(buf, 250, fp_fit);//leo el titulo
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    read_file(fp_fit, seeds, seeds_size);
    if(getval == NULL) printf("\nWARNING: There were problems while reading fit_ini.dat\n");
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
    int flag = 1;
    switch(argc)
    {
        case 1:
            break;
        case 2:
            flag = atoi(argv[1]);
            break;
        case 3:
            flag = atoi(argv[1]);
            th = atof(argv[2]);
            break;
        default:
            printf("Numero incorrecto de argumentos\nUso correcto:\n");
            printf("./idea_cmwp.exe \n./idea_cmwp flag\n./idea_cmwp flag treshold\n");
    }
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

        memset(intens_av, 0, 1800 * sizeof(float));
        memset(peak_intens_av, 0, 10 * sizeof(float));
        for(n = 0; n < numrings; n++)//error handler para cuando tenga un bad_fit en el caso spr=1 y gamma=1
        {
            sabo_inten[0][0][n] = -1;
            fit_inten[0][0][n] = -1;
            fwhm[0][0][n] = -1;
            eta[0][0][n] = -1;
            breadth[0][0][n] = -1;
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
                rv = fscanf(fp1, "%e", &data1[x]);
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
                BG_m = ((BG_l + BG_r) / 2.);

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
                exp_data sync_data = {path_out, filename1, dist, pixel, pixel_number};
                //structure holding difractograms and fitting information
                err_fit_data fit_errors = {fit_inten_err, fwhm_err, eta_err, breadth_err};
                peak_shape_data shapes = {fwhm, eta, breadth};
                peak_data difra = {numrings, bg_size, k, star_d, y, del_gam, th, miller, dostheta, data1, bg_seed, fit_inten, &shapes, &fit_errors};
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
    //End pole figure data in Machine coordinates//
    printf("\nFinish extracting pole figure data\n");
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    t2 = time(&t2);

    printf("\nBegin CMWP routine\n");
    char cmd[100], do_run[2];
    if(argc < 2)// si no le pase el dato por linea de comandos lo tomo de pantalla
    {
        printf("Run CMWP? [(y)/n]\n(If you choose n only configuration and fitting files will be created)\n");
        rv = scanf("%s", do_run);
        if(rv == 0 || rv == EOF) printf("Error de lectura\n");
        do_run[0] = tolower((unsigned char) do_run[0]);
        if(strcmp(do_run, "n") == 0)
            flag = 0;
        else
            flag = 1;
    }
    if(flag == 1)
        printf("Go ahead and have a cup of tea, this is gonna take a while\n");
    sprintf(cmd, "python python/cmwp.py %d", flag);
    rv = system(cmd);
    printf("End CMWP routine with code %d\n", rv);
    t3 = time(&t3);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    printf("Free allocated memory\n");
    free_double_matrix(seeds, 2);
    free_double_matrix(bg_seed, 2);
    free(dostheta);
    free_r3_tensor_double(sabo_inten, 40, 500);
    free_r3_tensor_double(fit_inten, 40, 500);
    free_r3_tensor_double(fit_inten_err, 40, 500);
    free_r3_tensor_double(fwhm, 40, 500);
    free_r3_tensor_double(fwhm_err, 40, 500);
    free_r3_tensor_double(eta, 40, 500);
    free_r3_tensor_double(eta_err, 40, 500);
    free_r3_tensor_double(breadth, 40, 500);
    free_r3_tensor_double(breadth_err, 40, 500);
    t4 = time(&t4);
    time_spent = difftime(t4, t1);
    fp_log = fopen("error.log", "a");
    sprintf(buf_temp, "---------------------------------------------\n");
    sprintf(buf_temp, "Tiempo de ejecucion total del programa: %.2lf segundos\n", time_spent);
    sprintf(buf_temp, "                                      o %.2lf minutos\n", time_spent / 60.);
    sprintf(buf_temp, "                                      o %.2lf horas\n", time_spent / 3600.);
    sprintf(buf_temp, "---------------------------------------------\n");
    printf("%s", buf_temp);
    fprintf(fp_log, "%s", buf_temp);

    time_spent = difftime(t3, t2);
    sprintf(buf_temp, "---------------------------------------------\n");
    sprintf(buf_temp, "Tiempo de ejecucion total de la rutina CMWP: %.2lf segundos\n", time_spent);
    sprintf(buf_temp, "                                           o %.2lf minutos\n", time_spent / 60.);
    sprintf(buf_temp, "                                           o %.2lf horas\n", time_spent / 3600.);
    sprintf(buf_temp, "---------------------------------------------\n");
    printf("%s", buf_temp);
    fprintf(fp_log, "%s", buf_temp);
    fclose(fp_log);

    printf("\nNo importa la realidad, sólo la verosimilitud\n");
    return 0;
} //End of Main()
