#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#include <ctype.h>
#include <gsl/gsl_math.h>
#include "array_alloc.h"

double sferical_to_cartesian_x(double alfx, double btax);
double sferical_to_cartesian_y(double alfy, double btay);
double sferical_to_cartesian_z(double alfz, double btaz);
double trans_pc_ab_al(double ph, double ch, double ome2, double th2, double bt_korr, double chii, double chia);
double trans_pc_ab_be(double ph_b, double ch_b, double ome2_b, double th2_b, double bt_korr_b, double chii_b, double chia_b);
void average_top(double ** ibm, int step_be);
double distance(double dx, double dy, double dz);

void interpolate(FILE * fp1, FILE *fp2, double act_cntare, int step_al1, int step_be1, int points)
{
  char *getval = malloc(sizeof(char) * (1024 + 1));
  int rv = 0;
  char   buf[1024];
  int    i, j, n, k, count, z, step_al, step_be;
  double schwellenwert, wandel, hpi, bt, al, spatprodukt, weightf;
  double alr, btr, step_alr, step_ber;
  double **ibm_rint = matrix_double_alloc(370, 100), ***ibm_fint = r3_tensor_double_alloc(2, 370, 100);
  double ***ibm_shapes = r3_tensor_double_alloc(6, 370, 100), ***ibm_corr_shapes = r3_tensor_double_alloc(6, 370, 100);
  double ***ibm_n = r3_tensor_double_alloc(6, 370, 100), **ibm_gewichte = matrix_double_alloc(370, 100);
  double ***ibmpos = r3_tensor_double_alloc(370, 100, 3), **grid_width = matrix_double_alloc(370, 100);
  double xein_3d, yein_3d, zein_3d;
  double z_theta, omega, phi, chi, alpha, beta;
  double raw_int, fintens[2], shapes[6], corr_shapes[6];
  
  //FILE *fp = fopen("xyx.dat", "w");

  getval = fgets(buf, 1024, fp1);//skip line
  getval = fgets(buf, 1024, fp1);//skip line
  getval = fgets(buf, 1024, fp1);//skip line
  
  wandel = M_PI / 180;//radian
  hpi = M_PI / 2;
  schwellenwert = 1 - act_cntare / 100;
  step_be = (int) 360 / step_be1;
  step_al = (int) (90 / step_al1) + 1;
  //salto angular en radianes
  step_alr = step_al1 * wandel;
  step_ber = step_be1 * wandel;

  //printf("Inicializando las matrices\n");
  //fprintf(fp, "#x y z\n");
  for(i = 1; i <= step_be; i++)
  {
      for(j = 1; j <= step_al; j++)
      {
          //posicion angular (en grados) de los puntos de la grilla regular
          bt = (i - 1) * step_be1;
          al = (j - 1) * step_al1;
          //posicion angular (en radianes) de los puntos de la grilla regular
          btr = bt * wandel;
          alr = al * wandel;
          //coseno del ancho angular de la grilla
          grid_width[i][j] = fabs(sin(alr) * sin(alr + step_alr) * cos(btr) * cos(btr + step_ber) + 
                                  sin(alr) * sin(alr + step_alr) * sin(btr) * sin(btr + step_ber) + 
                                  cos(alr) * cos(alr + step_alr));
          //semi-distancia maxima entre dos puntos de la grilla
          ibm_gewichte[i][j] = 0;
          ibm_rint[i][j] = 0;
          ibm_fint[0][i][j] = 0;
          ibm_fint[1][i][j] = 0;
          for(n = 0; n < 6; n++)
          {
            ibm_shapes[n][i][j] = 0;
            ibm_corr_shapes[n][i][j] = 0;
            ibm_n[n][i][j] = 0;
          }
          ibmpos[i][j][0] = sferical_to_cartesian_x(bt * wandel, al * wandel);
          ibmpos[i][j][1] = sferical_to_cartesian_y(bt * wandel, al * wandel);
          ibmpos[i][j][2] = sferical_to_cartesian_z(bt * wandel, al * wandel);
          //fprintf(fp, "%lf %lf %lf\n", ibmpos[i][j][0], ibmpos[i][j][1], ibmpos[i][j][2]);
      }
  }
  //fclose(fp);
  //printf("Leyendo archivo con grilla irregular");
  //fp = fopen("xyxeindata.dat", "w");
  //fprintf(fp, "#x y z I\n");
  z = 1;
  while(z <= points)//itero sobre todos los puntos del archivo mtex
  {
      rv = fscanf(fp1, "%d%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf", 
                                        &count, &z_theta, &omega, &chi, &phi, &raw_int, &fintens[0], &fintens[1],
                                        &shapes[0], &shapes[1], &shapes[2], &shapes[3], &shapes[4], &shapes[5], &shapes[0],
                                        &corr_shapes[1], &corr_shapes[2], &corr_shapes[3], &corr_shapes[4], &corr_shapes[5]);
      if(chi > 90)
      {
        printf("chi = %lf in line %d\n", chi, count); 
        chi = 90;
      }
      if(chi < 0)
      {
        printf("chi = %lf in line %d\n", chi, count); 
        chi = 0;
      }
      alpha = chi;
      //alpha = 90 - chi;
      beta = phi;
      xein_3d = sferical_to_cartesian_x(beta * wandel, alpha * wandel);
      yein_3d = sferical_to_cartesian_y(beta * wandel, alpha * wandel);
      zein_3d = sferical_to_cartesian_z(beta * wandel, alpha * wandel);
      //fprintf(fp, "%.5lf %.5lf %.5lf %.5lf\n", xein_3d, yein_3d, zein_3d, fintens[0]);
      for(i = 1; i <= step_be; i++)
      {
         for(j = 1; j <= step_al; j++)
         {
            spatprodukt = fabs(xein_3d * ibmpos[i][j][0] + yein_3d * ibmpos[i][j][1] + zein_3d * ibmpos[i][j][2]);
            if (spatprodukt >= schwellenwert)
            {
              weightf = cos(((1 - spatprodukt) / (act_cntare / 100)) * hpi);
              //weightf = 1.0;
              //weightf = sin(alpha * wandel);
              ibm_rint[i][j] += weightf * raw_int;
              ibm_fint[0][i][j] += weightf * fintens[0];
              ibm_fint[1][i][j] += weightf * fintens[1];
              ibm_gewichte[i][j] += weightf;
              //sumo sin peso las cosas que hay que sumar sin peso
              for(n = 0; n < 6; n++)
              {
                if(shapes[n] > 0.0)
                {
                  ibm_shapes[n][i][j] += shapes[n];
                  ibm_corr_shapes[n][i][j] += corr_shapes[n];
                  ibm_n[n][i][j]++;
                }
              }
            }
          }
      }
      z++;
  }//end while routine while(z <= points)
  //fclose(fp);
  //printf("Promediando en la grilla regular\n");
  for(i = 1; i <= step_be; i++)
  {
      for(j = 1; j <= step_al; j++)
      {
          if(ibm_gewichte[i][j] == 0)
          {
            ibm_rint[i][j] = 0;
            ibm_fint[0][i][j] = 0;
            ibm_fint[1][i][j] = 0;
          }
          else
          {
            ibm_rint[i][j] /= ibm_gewichte[i][j];
            ibm_fint[0][i][j] /= ibm_gewichte[i][j];
            ibm_fint[1][i][j] /= ibm_gewichte[i][j];
          }
          for(n = 0; n < 6; n++)
          {
            if(ibm_n[n][i][j] == 0)
            {
                ibm_shapes[n][i][j] = 0;
                ibm_corr_shapes[n][i][j] = 0;
            }
            else
            {
                ibm_shapes[n][i][j] /= ibm_n[n][i][j];
                ibm_corr_shapes[n][i][j] /= ibm_n[n][i][j];
            }
          }
      }//end for routine for(j = 1; j <= step_al; j++)
  }//end for routine for(i = 1; i <= step_be; i++)

  //printf("Promediando la cupula\n");
  average_top(ibm_rint, step_be);
  average_top(ibm_fint[0], step_be);
  average_top(ibm_fint[1], step_be);
  for(n = 0; n < 6; n++)
  {
    average_top(ibm_shapes[n], step_be);
    average_top(ibm_corr_shapes[n], step_be);
  }
  
  //printf("Salida de datos a la grilla regular\n");
  //Imprimo el tiempo de ejecucion del programa en el .mtex
  fprintf(fp2, "#        Row       2theta        theta        alpha         beta       raw_int       fit_int            err");
  fprintf(fp2, "             H            err           eta            err       Breadth            err");
  fprintf(fp2, "       H_corr             err      eta_corr            err     Breadth_corr         err");
  fprintf(fp2, "\n");
  k = 1;
  for(j = 1; j <= step_al; j++)
  {
      for(i = 1; i <= step_be; i++)
      {
        bt = (i - 1) * step_be1;
        al = (j - 1) * step_al1;
        //salida del archivo con todos los datos
        fprintf(fp2, "%12d %12.4lf %12.4lf %12.4lf %12.4lf %13.5lf ", k, z_theta, omega, al, bt, ibm_rint[i][j]);
        fprintf(fp2, "%13.5lf  %13.5lf ", ibm_fint[0][i][j], ibm_fint[1][i][j]);
        for(n = 0; n < 6; n++)
          fprintf(fp2, "%13.5lf  ", ibm_shapes[n][i][j]);
        for(n = 0; n < 6; n++)
          fprintf(fp2, "%13.5lf  ", ibm_corr_shapes[n][i][j]);
        fprintf(fp2, "\n");
        fflush(fp2);
        k++;
      }
  }
  //printf("Liberando memoria\n");
  free_r3_tensor_double(ibm_fint, 2, 370);
  free_r3_tensor_double(ibm_shapes, 6, 370);
  free_r3_tensor_double(ibm_corr_shapes, 6, 370);
  free_r3_tensor_double(ibmpos, 370, 100);
  free_r3_tensor_double(ibm_n, 6, 370);
  free_double_matrix(grid_width, 370);
  free_double_matrix(ibm_rint, 370);
  free_double_matrix(ibm_gewichte, 370);
  if(getval == NULL) printf("\nWARNING (fgets): There were problems while reading irregular grid data files\n");
  if(rv == 0 || rv == EOF) printf("\nWARNING (fscanf): there were problems reading param data in irregular grid data files (%d)\n", rv);
  //printf("Fin interpolate\n");
}//end interpolate

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

void average_top(double ** ibm, int step_be)
{
    int i;
    double zw = 0;
    for(i = 1; i <= step_be; i++)
        zw = zw + ibm[i][1];
    
    zw = zw / step_be;

    for(i = 1; i <= step_be; i++)
        ibm[i][1] = zw;
}

double distance(double dx, double dy, double dz)
{
  double d2 = pow(dx, 2) + pow(dy, 2.0) + pow(dz, 2.0);
  return sqrt(d2);
}
