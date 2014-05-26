#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "array_alloc.h"
#include "aux_functions.h"

void gen_cmwp_files(exists, &sync_data, &difra, zero_peak_index, peak_intens_av, seeds);
{
  
  char buf[1024], out_path[1024], orig_ini[256], orig_qini[256], name_root[256], des[256];
  double start_theta, end_theta;
  int i, start_data, end_data, Nsample;
  FILE *fp;    
///////////////////////////////////////////////////////////////
  if((fp = fopen("para_cmwp.dat", "r")) == NULL)
  {
    fprintf(stderr, "Error opening file: para_cmwp.dat\n"); exit(1);
  }
  fgets(buf, 22, fp);
  fscanf(fp, "%s", out_path);
  fgets(buf, sizeof(buf), fp);
  
  fgets(buf, 22, fp);
  fscanf(fp, "%d", &Nsample);
  fgets(buf, sizeof(buf), fp);

  //field separator
  fgets(buf, sizeof(buf), fp);
  fgets(buf, sizeof(buf), fp);
  
  fgets(buf, 22, fp);
  fscanf(fp, "%s", orig_path);
  fgets(buf, sizeof(buf), fp);
  
  fgets(buf, 22, fp);
  fscanf(fp, "%s", orig_ini);
  fgets(buf, sizeof(buf), fp);

  fgets(buf, 22, fp);
  fscanf(fp, "%s", orig_qini);
  fgets(buf, sizeof(buf), fp);

  fgets(buf, 22, fp);
  fscanf(fp, "%s", name);
  fgets(buf, sizeof(buf), fp);

  //field separator
  fgets(buf, sizeof(buf), fp);
  fgets(buf, sizeof(buf), fp);
  fgets(buf, sizeof(buf), fp);
  fgets(buf, sizeof(buf), fp);
  for(i = 0; i < difra->numrings; i++)
  {
    fscanf(fp, "%d", difra->hkl[i][0]);
    fscanf(fp, "%d", difra->hkl[i][1]);
    fscanf(fp, "%d", difra->hkl[i][2]);
  }
  fclose(fp);
/////////////////////////////////////////////////
  sprintf(buf, "%s%s", orig_path, orig_qini);
  if((fopen(buf, "r")) == NULL)
  {
    fprintf(stderr, "Error opening file: %s\n", buf); exit(1);
  }
  //skip 16 lines
  for(i = 0; i < 16; i++)
    fgets(buf, sizeof(buf), fp);
  fgets(buf, 5, fp);
  fscanf(fp, "%lf", start_theta);
  fgets(buf, sizeof(buf), fp);
  start_data = theta2bin(start_theta, sync_data->pixel, sync_data->dist);

  fgets(buf, 5, fp);
  fscanf(fp, "%lf", end_theta);
  fgets(buf, sizeof(buf), fp);
  end_data = theta2bin(end_theta, sync_data->pixel, sync_data->dist);
  fclose(fp);
////////////////////////////////////////////////
  if(exists == 0)
  {
    sprintf(buf, "mkdir -p %sspr_%d", out_path, difra -> spr);
    system(buf);
  }
  sprintf(buf, "%sspr_%d", out_path, difra->spr);
  strcpy(out_path, buf);
 
  //los archivos necesarios para el ajuste
  if(exists == 0)
  {
    sprintf(orig, "%s%s_s%d_g%d.dat.ini", orig_path, ini);
    sprintf(dest, "%s%s_s%d_g%d.dat.ini", orig_path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
    sprintf(orig, "%s%s_s%d_g%d.dat.fit.ini", orig_path, ini);
    sprintf(dest, "%s%s_s%d_g%d.dat.fit.ini", orig_path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
    sprintf(orig, "%s%s_s%d_g%d.dat.ini", orig_path, qini);
    sprintf(dest, "%s%s_s%d_g%d.dat.ini", orig_path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
  }
  else
  {
    sprintf(orig, "%s%s_s%d_g%d.dat.ini", path, name, difra->spr, difra->gamma - difra->start_gam);
    sprintf(dest, "%s%s_s%d_g%d.dat.ini", path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
    sprintf(orig, "%s%s_s%d_g%d.dat.fit.ini", path, name, difra->spr, difra->gamma - difra->start_gam);
    sprintf(dest, "%s%s_s%d_g%d.dat.fit.ini", path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
    sprintf(orig, "%s%s_s%d_g%d.dat.q.ini", path, name, difra->spr, difra->gamma - difra->start_gam);
    sprintf(dest, "%s%s_s%d_g%d.dat.q.ini", path, name, difra->spr, difra->gamma);
    sprintf(buf, "/bin/cp %s %s", orig, dest);
  }

  //imprimo el archivo con los datos del difractograma (int vs 2theta)
  sprintf(buf, "%s%s_s%d_g%d.dat", out_path, name, difra->spr, difra->gamma);
  fp = fopen(buf, "w");
  for(i = start_data; i < end_data; i++)
    fprintf("%lf %lf\n", bin2theta(i, sync_data->pixel, sync_data->dist), difra->intensity[i]);
  fclose(fp);
  //imprimo el archivo con los puntos de background
  sprintf(buf, "%s%s_s%d_g%d.bg-spline.dat", out_path, name, difra->spr, difra->gamma);
  fp = fopen(buf, "w");
  for(i = 0; i < difra->n_bg; i++)
    fprintf("%lf %lf\n", difra->bg[0][i], difra->bg[1][i]);
  fclose(fp);
  //imprimo el archivo con las posiciones y los indices de los picos
  sprintf(buf, "%s%s_s%d_g%d.peak-index.dat", path, name, difra->spr, difra->gamma);
  fp = fopen(buf, "w");
  for(i = 0; i < difra->numrings; i++)
    if(zero_peak_index[i] == 0)
      fprintf("%.5lf %.3lf %d%d%d 0\n", difra->ttheta[i], difra->intens[i], difra->hkl[i][0], difra->hkl[i][1], difra->hkl[i][2]);
  fclose(fp);
   
  //falta generar el archivo con el ensanchamiento por stacking faults
}
