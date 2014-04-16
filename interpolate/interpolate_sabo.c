#include<stdlib.h>
#include<stdio.h>
#include <math.h>
#include <ctype.h>

float sferical_to_cartesian_x(float alfx, float btax);
float sferical_to_cartesian_y(float alfy, float btay);
float sferical_to_cartesian_z(float alfz, float btaz);
float trans_pc_ab_al(float ph, float ch, float ome2, float th2, float bt_korr, float chii, float chia);
float trans_pc_ab_be(float ph_b, float ch_b, float ome2_b, float th2_b, float bt_korr_b, float chii_b, float chia_b);

main()
{
int    i, j, ipunkt, num, m, k,  count,z,points,step_al, step_be,step_al1, step_be1;
float  act_cntare, schwellenwert, pi, wandel, hpi, bt, al, spatprodukt,weightf;
float  ibm_data[370][100],ibm_gewichte[370][100],ibmpos[370][100][3];
float  intens, intensitaet, zw, xein_3d,yein_3d,zein_3d;
float  z_theta, omega, phi, chi, alpha, beta;
float  polar, azi;
char   filename[60], filename1[60],buf[300];
FILE   *fp,*fp1,*fp2, *fp3;


 puts("\n***************************************************************************");
 puts("\nPROGRAM: interpolate.EXE, Ver. Aug 2013");
 puts("\nProgram for interpolating the pole figure intensities to regular grids.");
 puts("\nControlling parameters: \n interpolating level (1 fast ~ 10 slow and wider area)\n angular grid = 1~10 ONLY INTEGER\n DO NOT USE decimal numbers e.g. 2.5\n");
 puts("Error or suggestion to sangbong.yi@hzg.de");
 puts("\n****************************************************************************");


  if((fp=fopen("para_inter.dat","r"))== NULL )
    {fprintf(stderr,"Error opening file(para_inter_m.dat)."); exit(1);}

  fgets(buf,200,fp);//skip line
  fscanf(fp,"%d",&num);//leo el numero de archivos a convertir

  printf("\nNumber of the interpolating files = %d\n\n",num);

  fgets(buf,2,fp);//skip line
  fgets(buf,200,fp);//skip line
  fgets(buf,200,fp);//skip line
  fgets(buf,200,fp);//skip line

  //printf("buf=%s",buf);

  if((fp3=fopen("running_result.txt","w"))== NULL )
    {fprintf(stderr,"Error beim oeffnen der Datei(running_result)."); exit(1);}

m=0;

while(m<num)//itero sobre todos los archivos que figuran en el para_inter.dat
 {
    fscanf(fp,"%s%f%d%d%d%s",&filename,&act_cntare,&step_al1,&step_be1,&points,&filename1);
    //printf("%s %f %d %d %d %s\n", filename, act_cntare, step_al1, step_be1, points, filename1);

    if((fp1=fopen(filename,"r"))== NULL )//abro el archivo mtex
    {fprintf(stderr,"Error beim oeffnen der Datei(%s).",filename); exit(1);}

   fgets(buf,200,fp1);

  ipunkt = 0;
  schwellenwert = 1 - act_cntare / 100;
  pi = 3.141592654;
  wandel = pi/180;
  hpi = pi/2;

  step_be=(int) 360/step_be1;
  step_al=(int) (90/step_al1)+1;

  printf("Input = %s, Alpha= %d degree * %d steps, Beta= %d degree* %d steps, Interpolation level= %4.2f, Points= %5d, Output = %s\n",filename,step_al1,step_al,step_be1,step_be,schwellenwert,points,filename1);

  for(i=1;i<=step_be;i++)//inicializo las matrices de datos y posicion
   for(j=1;j<=step_al;j++)
    {
     ibm_data[i][j] = 0;
     ibm_gewichte[i][j] = 0;
     bt = (i-1)*step_be1;
     al = (j-1)*step_al1;

     ibmpos[i][j][1]=sferical_to_cartesian_x(bt*wandel,al*wandel);
     ibmpos[i][j][2]=sferical_to_cartesian_y(bt*wandel,al*wandel);
     ibmpos[i][j][3]=sferical_to_cartesian_z(bt*wandel,al*wandel);

    }
  z=1;
  
  intensitaet = 0;
  float aux = 0;
  while(z<=points)//itero sobre todos los puntos del archivo mtex
  {
    fscanf(fp1,"%d%f%f%f%f%f",&count,&z_theta,&omega,&chi,&phi,&intens);
    fgets(buf,200,fp1);

    aux = intensitaet; //valor viejo a la variable auxiliar
    if(intens<=0){
        intensitaet = 0;
        /*z++;
        continue;*/
        //intensitaet = aux;

    }
    else
    {
        intensitaet = intens;
    }
      
    if(chi>=90) chi=90;
    if(chi<=0)  chi=0;

    if(fabs((double)(z_theta/2 - omega)) < 0.1)
    {
	alpha = 90-chi;
	beta = phi;
    }
    else
    {
	alpha=trans_pc_ab_al(phi,chi,omega,z_theta/2,0,90,0);
        beta=trans_pc_ab_be(phi,chi,omega,z_theta/2,0,90,0);
    }

    xein_3d=sferical_to_cartesian_x(beta*wandel, alpha*wandel);
    yein_3d=sferical_to_cartesian_y(beta*wandel, alpha*wandel);
    zein_3d=sferical_to_cartesian_z(beta*wandel, alpha*wandel);

    fprintf (fp3,"%d  al%7.1f  be%7.1f  x%7.4f y%7.4f z%7.4f schwellenwert%7.4f \n ",z,alpha, beta,xein_3d,yein_3d, zein_3d,schwellenwert);

  for(i=1;i<=step_be;i++)
   for(j=1;j<=step_al;j++)
    {
      spatprodukt = fabs((double)((xein_3d*ibmpos[i][j][1]) + yein_3d*ibmpos[i][j][2]
                         + zein_3d*ibmpos[i][j][3] ));

       if (spatprodukt >= schwellenwert)
        { 
	  weightf = cos ((1-spatprodukt)/(act_cntare/100)*hpi);
	  ibm_data[i][j] = ibm_data[i][j]+weightf*intensitaet;
	  ibm_gewichte[i][j] = ibm_gewichte[i][j] + weightf;    
	}
    } //for

  z++;
  }//while

  
  for(i=1;i<=step_be;i++)
   for(j=1;j<=step_al;j++)
     {
       if(ibm_gewichte[i][j] == 0)
          ibm_data[i][j]=0;
       else
          ibm_data[i][j]=ibm_data[i][j]/ibm_gewichte[i][j];
     }

  zw=0;

  for(i=1;i<=step_be;i++)
      zw=zw+ibm_data[i][1];

  zw=zw/step_be;

  for(i=1;i<=step_be;i++)
      ibm_data[i][1]=zw;

  if((fp2=fopen(filename1,"w"))== NULL )
    {fprintf(stderr,"Error beim oeffnen der Datei(%s).",filename1); exit(1);}


	k=1;

  for(j=1;j<=step_al;j++)
   for(i=1;i<=step_be;i++)
    {
       fprintf(fp2,"%8.1f",ibm_data[i][j]);

	   if((k%10)==0)
        fprintf(fp2,"\n");

      k++;
    }

  k=1;

  fprintf(fp2,"\n");

  fclose(fp1);
  fclose(fp2);
  m++;
}//while

fclose(fp);

}

float sferical_to_cartesian_x(float btax, float alfx)
{
float xv;

xv= cos((double)btax)*sin((double)alfx);

return (xv);
}

float sferical_to_cartesian_y(float btay, float alfy)
{
float yv;

yv= sin((double)btay)*sin((double)alfy);

return (yv);
}

float sferical_to_cartesian_z(float btaz, float alfz)
{
float zv;

zv= cos((double)alfz);
//printf("function %7.1f%7.1f,%7.4f",alfz/(3.141592654/180),btaz/(3.141592654/180),zv);

return (zv);
}

float trans_pc_ab_al(float ph, float ch, float ome2, float th2, float bt_korr, float chii, float chia)
{
   double   dwandel, dpi;
   double   dch,dal,dbt,dth,dchn,dchii,dchia,dpih,dom;
   float    bta2,alf2;

   dpi      = 3.141592654;
   dpih     = dpi/2;
   dwandel  = dpi/180;

   dchii = (double) chii;
   dchia = (double) chia;
   dch = (double) ch;
   dom = (double) ome2;
   dth = (double) th2;

   if(dchia > dchii) dchn = dch-dchia;
   else              dchn = 90-(dch-dchia);

   dal = cos((dth-dom)*dwandel)*cos(dchn*dwandel);

   alf2 = (float) acos(dal)/dwandel;

return (alf2);
}

float trans_pc_ab_be(float ph_b, float ch_b, float ome2_b, float th2_b, float bt_korr_b, float chii_b, float chia_b)
{
   double   dwandel_b, dpi_b;
   double   dch_b,dal_b,dbt_b,dth_b,dchn_b,dchii_b,dchia_b,dpih_b,dom_b;
   float    bta2_b,alf2_b;

   dpi_b      = 3.141592654;
   dpih_b     = dpi_b/2;
   dwandel_b  = dpi_b/180;

   dchii_b = (double) chii_b;
   dchia_b = (double) chia_b;
   dch_b = (double) ch_b;
   dom_b = (double) ome2_b;
   dth_b = (double) th2_b;

   if(dchia_b > dchii_b) 
   dchn_b = dch_b-dchia_b;
   else              
   dchn_b = 90-(dch_b-dchia_b);

   
   dbt_b = asin((cos((dth_b-dom_b)*dwandel_b)*sin(dchn_b*dwandel_b)/sin(dal_b+dpih_b) ))/dwandel_b;

   
   bta2_b = (float) dbt_b + ph_b + bt_korr_b;

   if (bta2_b > 360) 
   bta2_b = bta2_b - 360;
   
   if (bta2_b < 0) 
   bta2_b = 360 + bta2_b;

return (bta2_b);
}
