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
    FILE *fp, *fp1, *fp_fit;
    char buf_temp[100], buf[100], buf1[100], path_out[150], filename1[100], inform[10], path1[150], inform1[10], marfile[150], minus_zero[1];
    int Z, a, b, i, j, k, m, n, x, y, z, count, anf_gam, ende_gam, del_gam, anf_ome, ende_ome, del_ome;
    int BG_l, BG_r, star_d, end_d, del_d, numrings, posring_l[15], posring_r[15], ug_l[15], ug_r[15];
    int pixel_number, gamma, seeds_size, bg_size, n_peaks, data[2500], intensity, miller[15];
    float intens_av[1800], peak_intens_av[10], data1[2500], BG_m, intens[500][10];
    float theta[20], neu_ome, neu_ome1, neu_gam1, neu_gam, alpha, beta, th;
    double pixel, dist, ** seeds, ** bg_seed, *dostheta = vector_double_alloc(15);
    double ***sabo_inten = r3_tensor_double_alloc(40, 500, 10);
    double ***fit_inten = r3_tensor_double_alloc(40, 500, 10), ***fit_inten_err = r3_tensor_double_alloc(40, 500, 10);
    double ***fwhm = r3_tensor_double_alloc(40, 500, 10), ***fwhm_err = r3_tensor_double_alloc(40, 500, 10);
    double ***eta = r3_tensor_double_alloc(40, 500, 10), ***eta_err = r3_tensor_double_alloc(40, 500, 10);
    double ***breadth = r3_tensor_double_alloc(40, 500, 10), ***breadth_err = r3_tensor_double_alloc(40, 500, 10);

    puts("\n****************************************************************************");
    puts("\nPROGRAM: IDEA_CMWP.EXE, Ver. XX.XX");
    puts("\nProgram for generating the pole figures from CMWP data.\nCoordinate-transformation to MTEX-Format.");
    puts("\nPole figures in MTEX-readable format xxx_Nr.mtex.");
    puts("\nThe angular values of Omega and Gamma, from the parameter file");
    puts("\nIn order to work this executable must be placed in CMWP instalation folder along with the python folder");
    puts("\nPython 2.7 required");
    puts("\nError or suggestions to benatti@ifir-conicet.gov.ar");
    puts("\n****************************************************************************");
    //////////////////////////////////////////////////////////////////////////
    //LECTURA DEL ARCHIVO para_fit2d.dat
    if((fp = fopen("para_cmwp.dat", "r")) == NULL)
    {
        fprintf(stderr, "Error opening file para_cmwp.dat\n");
        exit(1);
    }
    fgets(buf_temp, sizeof(buf_temp), fp);

    //path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    fgets(buf_temp, 22, fp); fscanf(fp, "%s", path1);   fgets(buf_temp, 2, fp);
    //path hacia los archivos de salida
    fgets(buf_temp, 22, fp); fscanf(fp, "%s", path_out); fgets(buf_temp, 2, fp);
    //lee raiz de los archivos spr (New_Al70R-tex_)
    fgets(buf_temp, 22, fp); fscanf(fp, "%s", filename1); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, sizeof(buf_temp), fp);
    fgets(buf_temp, sizeof(buf_temp), fp);
    //lee la extension de los archivos (spr)
    fgets(buf_temp, 22, fp); fscanf(fp, "%s", inform1); fgets(buf_temp, 2, fp);
    //numero del primer spr
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &star_d); fgets(buf_temp, 2, fp);
    //delta en los spr
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &del_d); fgets(buf_temp, 2, fp);
    //numero del ultimo spr
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &end_d); fgets(buf_temp, 2, fp);
    //angulo (\Omega) inicial 
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &anf_ome); fgets(buf_temp, 2, fp);
    //delta en el angulo \omega
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &del_ome); fgets(buf_temp, 2, fp);
    //angulo (\Omega) final
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &ende_ome); fgets(buf_temp, 2, fp);
    //gamma inicial
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &anf_gam); fgets(buf_temp, 2, fp);
    //delta gamma
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &del_gam); fgets(buf_temp, 2, fp);
    //gamma final
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &ende_gam); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, sizeof(buf_temp), fp);
    fgets(buf_temp, sizeof(buf_temp), fp);
    //Distancia de la muestra al detector
    fgets(buf_temp, 22, fp); fscanf(fp, "%lf", &dist); fgets(buf_temp, 2, fp);
    //Distancia que cubre un pixel en el difractograma
    fgets(buf_temp, 22, fp); fscanf(fp, "%lf", &pixel); fgets(buf_temp, 2, fp);
    //umbral que determinal cual es la intensidad minima para que ajusto un pico
    fgets(buf_temp, 22, fp); fscanf(fp, "%f", &th); fgets(buf_temp, 2, fp);
    //flag que determina si las cuentas negativas se pasan a 0
    fgets(buf_temp, 22, fp); fscanf(fp, "%s", minus_zero); fgets(buf_temp, 2, fp); 
    //skip lines
    fgets(buf_temp, 20, fp);
    fgets(buf_temp, 20, fp);
    //numero de picos a analizar 
    fgets(buf_temp, 22, fp); fscanf(fp, "%d", &numrings); fgets(buf_temp, 2, fp);
    //skip lines
    fgets(buf_temp, 50, fp);
    fgets(buf_temp, 50, fp);

    for(i = 0; i < numrings; i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
      fscanf(fp, "%d", &miller[i]);
      fscanf(fp, "%f", &theta[i]); //posicion angular del centro del pico (\theta)
      fscanf(fp, "%d", &posring_l[i]); //bin a la izquierda del pico
      fscanf(fp, "%d", &posring_r[i]); //bin a la derecha del pico
      fscanf(fp, "%d", &ug_l[i]); //bin de bg a la izquierda del pico
      fscanf(fp, "%d", &ug_r[i]); //bin de bg a la derecha del pico
    }
    fgets(buf_temp, 2, fp); //skip line
    fclose(fp);
    // End of reading the parameter file
    //////////////////////////////////////////////////////////////////////////
    //Reading of initial parameters
    if((fp_fit = fopen("fit_ini.dat", "r")) == NULL)
    {
        fprintf(stderr, "Error opening file fit_ini.dat\n");
        exit(1);
    }
    fgets(buf, 250, fp_fit);//leo el titulo
    seeds_size = 4 * numrings + 2;
    seeds = matrix_double_alloc(2, seeds_size);
    read_file(fp_fit, seeds, seeds_size);
    fclose(fp_fit);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //podria agregar un argumento para que el archivo de con los puntos de ruido lo saque de la linea de comandos
    if((fp_fit = fopen("bg-spline.dat", "r")) == NULL)
    {
        fprintf(stderr, "Error opening file bg-spline.dat\n");
        exit(1);
    }
    //cuento cuantlas lineas tiene el archvio i.e. el numero de puntos de background
    n = 0;
    while(fscanf(fp_fit, "%lf", &bg_seed[0][0]) != EOF)
    {
      fscanf(fp_fit, "%lf", &bg_seed[1][0]);
      n++;
    }
    bg_size = n;
    free_double_matrix(bg_seed, 2);
    //ahora lleno la matriz bg_seed con la posicion e intensidad de los puntos de background
    bg_seed = matrix_double_alloc(2, bg_size);
    rewind(fp_fit);
    n = 0;
    while(fscanf(fp_fit, "%lf", &bg_seed[0][n]) != EOF)
    {
      fscanf(fp_fit, "%lf", &bg_seed[1][n]);
      n++;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //si le paso el valor de treshold por linea de comandos que se olvide de lo que esta en archivo
    if(argc == 2)
      th = atof(argv[1]);

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
            fprintf(stderr, "Error opening READ_file: %s \n", marfile);
            exit(1);
        }
        fscanf(fp1, "%d", &pixel_number); //pixel number = los bin de los difractogramas
        fscanf(fp1, "%d", &gamma); //gamma = cantidad de difractogramas (360 en este caso)
        fgets(buf, 100, fp1); //skip line

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
    printf("\nBegin CMWP routine\n");
    printf("Go ahead and have a cup of tea, this is gonna take a while\n");
    int rv;
    char cmd[100] = "python python/cmwp.py";
    rv = system(cmd);
    printf("\nEnd CMWP routine\n");
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
    printf("\nNo importa la realidad, sólo la verosimilitud\n");
    return 0;
} //End of Main()
