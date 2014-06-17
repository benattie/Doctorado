#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#include <ctype.h>
#include <gsl/gsl_math.h>

double sferical_to_cartesian_x(double alfx, double btax);
double sferical_to_cartesian_y(double alfy, double btay);
double sferical_to_cartesian_z(double alfz, double btaz);
double trans_pc_ab_al(double ph, double ch, double ome2, double th2, double bt_korr, double chii, double chia);
double trans_pc_ab_be(double ph_b, double ch_b, double ome2_b, double th2_b, double bt_korr_b, double chii_b, double chia_b);

int main()
{
  int    q = 0, i, j, num, m, k,  count, z, points, step_al, step_be, step_al1, step_be1;
  double act_cntare, schwellenwert, wandel, bt, al, spatprodukt, weightf;
  double ibm_data[370][100], ibm_gewichte[370][100], ibmpos[370][100][3];
  double intens, intensitaet, zw, xein_3d, yein_3d, zein_3d;
  double z_theta, omega, phi, chi, alpha, beta, intens_err;
  char   filename[60], filename1[60], buf[300];
  FILE   *fp, *fp1, *fp2, *fp3;

  puts("\n***************************************************************************");
  puts("\nPROGRAM: interpolate.EXE, Ver. Aug 2013");
  puts("\nProgram for interpolating the pole figure intensities to regular grids.");
  puts("\nControlling parameters: \n interpolating level (1 fast ~ 10 slow and wider area)\n angular grid = 1~10 ONLY INTEGER\n DO NOT USE decimal numbers e.g. 2.5\n");
  puts("Error or suggestion to sangbong.yi@hzg.de");
  puts("\n****************************************************************************");

  if((fp = fopen("PARA_INTER.dat", "r")) == NULL )
  {
      fprintf(stderr, "Error opening file(PARA_INTER.dat).\n");
      exit(1);
  }

  fgets(buf, 200, fp);//skip line
  fscanf(fp, "%d", &num);//leo el numero de archivos a convertir

  printf("\nNumber of the interpolating files = %d\n\n", num);

  fgets(buf, 2, fp);//skip line
  fgets(buf, 200, fp);//skip line
  fgets(buf, 200, fp);//skip line
  fgets(buf, 200, fp);//skip line
  fgets(buf, 200, fp);//skip line

  if((fp3 = fopen("running_result.txt", "w")) == NULL )
  {
        fprintf(stderr, "Error beim oeffnen der Datei(running_result).\n");
        exit(1);
  }

  m = 0;
  while(m < num)//itero sobre todos los archivos que figuran en el para_inter.dat
  {
    q = 0;
    fscanf(fp, "%s%lf%d%d%d%s", filename, &act_cntare, &step_al1, &step_be1, &points, filename1);
    //printf("%s %lf %d %d %d %s\n", filename, act_cntare, step_al1, step_be1, points, filename1);
    if((fp1 = fopen(filename, "r")) == NULL)//abro el archivo mtex
    {
        fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", filename);
        exit(1);
    }
    fgets(buf, 200, fp1);//skip line

    wandel = M_PI / 180;//radian
    //si voy a trabajar sin pesos solo tengo que incluir los valores que caen dentro de la celda
    schwellenwert = 0.5 * (cos(step_be1 * wandel) * (cos(step_al1 * wandel) - cos(step_al1 * wandel)) + cos(step_al1 * wandel) + cos(step_al1 * wandel));

    step_be = (int) 360 / step_be1;
    step_al = (int) (90 / step_al1) + 1;

    printf("Input = %s, Alpha= %d degree * %d steps, Beta= %d degree* %d steps, Interpolation level= %7.5lf, Points= %5d, Output = %s\n", filename, step_al1, step_al, step_be1, step_be, schwellenwert, points, filename1);

    for(i = 1; i <= step_be; i++)//inicializo las matrices de datos y posicion
    {
        for(j = 1; j <= step_al; j++)
        {
            ibm_data[i][j] = 0;
            ibm_gewichte[i][j] = 0;
            bt = (i - 1) * step_be1;
            al = (j - 1) * step_al1;
            ibmpos[i][j][0] = sferical_to_cartesian_x(bt * wandel, al * wandel);
            ibmpos[i][j][1] = sferical_to_cartesian_y(bt * wandel, al * wandel);
            ibmpos[i][j][2] = sferical_to_cartesian_z(bt * wandel, al * wandel);
        }
    }
    z = 1;
    intensitaet = 0;
    while(z <= points)//itero sobre todos los puntos del archivo mtex
    {
        fscanf(fp1, "%d%lf%lf%lf%lf%lf%lf", &count, &z_theta, &omega, &chi, &phi, &intens, &intens_err);
        fgets(buf, 200, fp1);//skip line

        if(intens < 0)
            intensitaet = 0;
        else
            intensitaet = 1e5 * intens;//multiplico las intensidades por un factor para que los anchos de pico me queden enteros
      
        if(chi >= 90) chi = 90;
        if(chi <= 0)  chi = 0;
        
        if(fabs(z_theta / 2 - omega) < 0.1)
        {
            //alpha= chi;
    	    //alpha = 90 - chi; no se porque pusieron esta rotacion, para mi no deberia estar
            //beta = phi;
            q++;
        }
        alpha = chi;
        beta = phi;
        xein_3d = sferical_to_cartesian_x(beta * wandel, alpha * wandel);
        yein_3d = sferical_to_cartesian_y(beta * wandel, alpha * wandel);
        zein_3d = sferical_to_cartesian_z(beta * wandel, alpha * wandel);

        fprintf(fp3,"%d  al%7.1lf  be%7.1lf  x%7.4lf y%7.4lf z%7.4lf schwellenwert%8.5lf \n ", z, alpha, beta, xein_3d, yein_3d, zein_3d, schwellenwert);

        for(i = 1; i <= step_be; i++)
        {
           for(j = 1; j <= step_al; j++)
           {
              spatprodukt = fabs(xein_3d * ibmpos[i][j][0] + yein_3d * ibmpos[i][j][1] + zein_3d * ibmpos[i][j][2]);
              if (spatprodukt >= schwellenwert)
              { 
                weightf = 1;
                ibm_data[i][j] = ibm_data[i][j] + weightf * intensitaet;
                ibm_gewichte[i][j] = ibm_gewichte[i][j] + weightf;    
              }
            }
        }
        z++;
    }//end while routine while(z <= points)
  
    for(i = 1; i <= step_be; i++)
        for(j = 1; j <= step_al; j++)
        {
            if(ibm_gewichte[i][j] == 0)
                ibm_data[i][j] = 0;
            else
                ibm_data[i][j] = ibm_data[i][j] / ibm_gewichte[i][j];
        }

    zw = 0;
    for(i = 1; i <= step_be; i++)
        zw = zw + ibm_data[i][1];
    zw = zw / step_be;

    for(i = 1; i <= step_be; i++)
        ibm_data[i][1] = zw;

    if((fp2 = fopen(filename1, "w")) == NULL)
    {
        fprintf(stderr, "Error beim oeffnen der Datei(%s).", filename1);
        exit(1);
    }

    k = 1;
    for(j = 1; j <= step_al; j++)
    {
        for(i = 1; i <= step_be; i++)
        {
           fprintf(fp2, "%7.0lf ", ibm_data[i][j]);

            if((k % 10) == 0)
                fprintf(fp2, "\n");
            k++;
        }
    }

    k = 1;
    fprintf(fp2, "\n");
    fclose(fp1);
    fclose(fp2);
    if(q - points)
      printf("Check for theta-2theta mismatch in %d points\n", q - points);
    else
      printf("OK\n");
    m++;
  }//end while routine while(m < num)
  fclose(fp);
 
  return 0;
}//end main

double sferical_to_cartesian_x(double btax, double alfx)
{
    double xv;
    xv = cos(btax) * sin(alfx);
    return xv;
}

double sferical_to_cartesian_y(double btay, double alfy)
{
    double yv;
    yv = sin(btay) * sin(alfy);
    return yv;
}

double sferical_to_cartesian_z(double btaz, double alfz)
{
    double zv;
    zv = cos(alfz);
    return zv;
}
