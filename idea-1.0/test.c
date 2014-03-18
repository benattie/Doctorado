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

int main()
{
 int Z, i, k, n, x, y;
 int a, b, z, count, c, d, count_minus;
 int BG_l, BG_r;
 int NrSample, star_d, end_d, star_a, end_a, del_d, del_a, rot_p, end_g, numrings;
 int posring_l[15], posring_r[15], ug_l[15], ug_r[15];
 int fd[15], fi[15];
 int pixel_number, gamma;
 int data[2500], intensity;
 int stepnum, maxpos, minpos;

 double pixel, dist;
 float data1[2500], BG_m, intens[500][10];

 char buf_temp[100], buf[100], buf1[100];
 char path_out[150], path [150], filename[60], filename1[100], inform[10], path1[150], inform1[10];
 char outfile[100], linfile[100];
 char marfile[150];
 char outinten[3000];
 char minus_zero; 
 char logfile_yn, logfile_yn_temp;
 
 FILE *fp, *fp1, *fp2, *fp3, *fp4; 

 int   j,l,m,step,anf_gam,ende_gam,del_gam,num;
 float step_ome,anf_ome,ende_ome,del_ome,weg;
 float m_intens,n_intens,nn_intens;
 float theta[20],neu_ome,neu_ome1,neu_gam1,neu_gam,alpha,beta;
 float alpha90;
 float diode[200], max_diode, min_diode, max_diode_temp, min_diode_temp, ratio, inten, new_int;

 time_t timer;
 struct tm *zeit;

 puts("\n***************************************************************************");
 puts("\nPROGRAM: FIT2D_DATA.EXE, Ver. Aug. 2013");
 puts("\nProgram for generating the pole figures from Fit2D data.\nCoodinate-transformation to MTEX-Format.");
 puts("Pole figure data xxx_Nr.dat Pole figure in MTEX-readable format xxx_Nr.mtex.");
 puts("\nThe angular values of Omega and Gamma, from the parameter file\n");
 puts("Options: \n 1. Replacement negative intensity values to ZERO\n 2. Intensity correction with LogFile.txt\n");
 puts("Error or suggestion to sangbong.yi@hzg.de");
 puts("\n****************************************************************************");


 if((fp=fopen("para_fit2d.dat","r"))== NULL )
     {fprintf(stderr,"Error opening file(para_fit2d.txt)."); exit(1);}
 //////////////////////INICIA LA LECTURA DEL ARCHIVO para_fit2d.dat/////////////////////////////////////////////
 //path hacia los archivos, probablemente los de salida, pero no estoy seguro (C:\Users\Bolmaro\Experim\Sabo\dat\) 
 fgets(buf_temp,22,fp);
 fscanf(fp,"%s",&path_out);   fgets(buf_temp,2,fp);
 //numero de muestras a trabajar (1)
 fgets(buf_temp,22,fp);
 fscanf(fp,"%d",&NrSample);   fgets(buf_temp,2,fp);
printf("%d\n", NrSample);
 
    //skip lines
    fgets(buf_temp,2,fp);
    fgets(buf_temp,60,fp);
    fgets(buf_temp,2,fp);
    
    //path hacia los spr (encabezado + 360 filas x 1725 columnas) (son 37) 
    fgets(buf_temp,22,fp);
    fscanf(fp,"%s",&path);   fgets(buf_temp,2,fp);

    //lee raiz de los archivos spr (New_Al70R-tex_)
    fgets(buf_temp,22,fp);
    fscanf(fp,"%s",&filename1); fgets(buf_temp,2,fp);

    //lee la extension de los archivos (spr)
    fgets(buf_temp,22,fp);
    fscanf(fp,"%s",&inform); fgets(buf_temp,2,fp);

    //pasa los contenidos de path e inform hacia path1 e inform1 (why?)
    strcpy(path1,path); strcpy(inform1,inform);
    
    //numero asociado al primer spr (relacionado con omega)
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&star_d); fgets(buf_temp,2,fp);
    
    //angulo (\Omega) inicial
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&star_a); fgets(buf_temp,2,fp);
    
    //numero asociado al ultimo spr
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&end_d); fgets(buf_temp,2,fp);
    
    //angulo (\Omega) final
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&end_a); fgets(buf_temp,2,fp);
    
    //delta en los spr
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&del_d); fgets(buf_temp,2,fp);
    
    //delta en el angulo \omega
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&del_a); fgets(buf_temp,2,fp);
    
    //gamma inicial
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&rot_p); fgets(buf_temp,2,fp);
    
    //gamma final
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&end_g); fgets(buf_temp,2,fp);
    
    //Distancia de la muestra al detector
    fgets(buf_temp,22,fp);
    fscanf(fp,"%lf",&dist); fgets(buf_temp,2,fp);
    
    //Distancia que cubre un pixel en el difractograma
    fgets(buf_temp,22,fp);
    fscanf(fp,"%lf",&pixel); fgets(buf_temp,2,fp);

    printf("%lf\t%lf\n", pixel, dist);

    //flag que determina si las cuentas negativas se pasan a 0
    fgets(buf_temp,22,fp);
    fscanf(fp,"%s",&minus_zero); fgets(buf_temp,2,fp);    

    //flag que determina si se genera el archivo .log?
    fgets(buf_temp,22,fp);
    fscanf(fp,"%s",&logfile_yn_temp); fgets(buf_temp,2,fp);
    
    //skip lines
    fgets(buf_temp,2,fp);
    fgets(buf_temp,15,fp);
    fgets(buf_temp,2,fp);

    //numero de picos a analizar 
    fgets(buf_temp,22,fp);
    fscanf(fp,"%d",&numrings); fgets(buf_temp,2,fp); 
    //skip lines
    fgets(buf_temp,22,fp); fgets(buf_temp,2,fp);
    fgets(buf_temp,33,fp); fgets(buf_temp,2,fp);
    
    //le aviso al usuario el valor del flag que activa o desactiva la creacion del .log
    printf("\n correction log file = %s ",&logfile_yn_temp);
    logfile_yn = logfile_yn_temp;
    
    //le aviso al usuario el valor del flag que activa o desactiva la correccion de cuentas negativas
    printf("\n correction minus_zero = %s ",&minus_zero);
    
    //no se para que esta esto
    printf("\n log_file minus_zero = %s  \n",&logfile_yn);


    ////FINALIZA LA LECTURA DEL ARCHIVO para_fit2d.dat (SALVO LA POSICION DE LOS PICOS, QUE OCURRE EN EL LOOP SOBRE numrings)////

    for(i=0;i<numrings;i++) //itera sobre cada pico (0 a 7) -> (1 a 8)
    {
        fscanf(fp,"%f",&theta[i]); //posicion angular del centro del pico (\theta o $2\theta?)
        fscanf(fp,"%d",&posring_l[i]); //bin a la izquierda del pico
        fscanf(fp,"%d",&posring_r[i]); //bin a la derecha del pico
        fscanf(fp,"%d",&ug_l[i]); //bin de bg a la izquierda del pico
        fscanf(fp,"%d",&ug_r[i]); //bin de bg a la derecha del pico

        strcpy(outfile, "");
        strcat(outfile, path_out);
	strcat(outfile, filename1);
        strcat(outfile,"PF_");

	sprintf(buf,"%d",i+1);
        strcat(outfile,buf);
        strcat(outfile,".dat");

	//despues de todas las lineas str* genera un string de nombre C:\Users\Bolmaro\Experim\Sabo\dat\New_Al70R-tex_PF_(1 al 8).dat 
        //abre un archivo para cada pico (lo voy a llamar de ahora en adelante file_peak)
        if((fd[i]=open(outfile,O_CREAT|O_TRUNC|O_RDWR,S_IREAD|S_IWRITE))<0)
        { 
            printf("Cannot open OUTPUT file.(for %d ring)",i+1); exit(1);
        }
    }
    

    //End of reading the parameter file and End of generation of Output-files for(i=0;i<numrings;i++)	
    ///////////FINALIZA LA LECTURA DEL ARCHIVO para_fit2d.dat/////////////////////////////////////////
    fgets(buf_temp,2,fp); //skip line

    //imprime en pantalla los datos relevantes de cada pico 
    for(i=0;i<numrings;i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n",i+1,theta[i],posring_l[i],posring_r[i],ug_l[i],ug_r[i]);

    return 0;
}
