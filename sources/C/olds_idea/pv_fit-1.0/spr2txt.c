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


#define pi 3.141592654
//#define max(x, y) (((x) > (y)) ? (x) : (y))
//#define min(x, y) (((x) < (y)) ? (x) : (y))

struct DAT {float old; float nnew;};

float winkel_al(float, float, float);
float winkel_be(float, float, float, float );

main()
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

 float data1[2500], BG_m, intens[500][10];

 char buf_temp[100], buf[100], buf1[100];
 char path_out[150], path [150], filename[60], filename1[100], inform[10], path1[150], inform1[10];
 char outfile[100], linfile[100];
 char marfile[150];
 char outinten[3000];
 char minus_zero; 
 char logfile_yn, logfile_yn_temp;
 
 FILE *fp, *fp1, *fp2, *fp3, *fp4; 

 struct DAT intensss;

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
 

 for(Z=1;Z<=NrSample;Z++) // FOR-routine: whole routines
 {
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
    
    /* End of reading the parameter file and End of generation of Output-files for(i=0;i<numrings;i++)*/	
    ///////////FINALIZA LA LECTURA DEL ARCHIVO para_fit2d.dat/////////////////////////////////////////
    fgets(buf_temp,2,fp); //skip line

    //imprime en pantalla los datos relevantes de cada pico 
    for(i=0;i<numrings;i++)
        printf("Position of [%d]ring = Theta:%6.3f  %8d%8d%8d%8d\n",i+1,theta[i],posring_l[i],posring_r[i],ug_l[i],ug_r[i]);

    //imprime en cada file_peak el \gamma inicial, final y el paso
    sprintf(buf_temp,"Anf., Ende, Schritt-Gamma:              %8d%8d       1\n",rot_p,end_g);

    for(i=0;i<numrings;i++)
        write(fd[i],buf_temp, strlen(buf_temp));

    //imprime en cada file_peak el \Omega inicial, final y el paso
    sprintf(buf_temp,"Anf., Ende, Schritt-Omega:              %8d%8d%8d\n\n",star_a,end_a,del_a);
    for(i=0;i<numrings;i++)
        write(fd[i],buf_temp, strlen(buf_temp));

    /*Begin ring data read-in and output*/
    
    k = star_d;  // file index number : start_d to end_d
    //Inicio de la escritura del archivo que hace la figura de polos en el sistema de coordenadas de la maquina (\gamma, \Omega)
    do //Interacion sobre todos los spr  
    {

        //selecciono el archivo spr que voy a procesar
        /*Input file*/
        strcpy(marfile, path1);
        strcat(marfile,filename1);
        sprintf(buf,"%d",k);

        if(k<10)
            sprintf(buf1,"0000");
        if(k>=10 && k<100)
            sprintf(buf1,"000");
        if(k>=100)
            sprintf(buf1,"00");
        strcat(marfile,buf1);

        strcat(marfile,buf);
        strcat(marfile,".");

        strcat(marfile,"spr");
	//termina la seleccion del archivo spr

        printf("\nReading data from <====  %s\n", marfile );

        //abro el archivo spr del que voy a sacar las intensdades de los picos
        if((fp1 = fopen(marfile, "r")) == NULL ) //fp1 = puntero al archivo spr que estoy procesando
        {
            fprintf(stderr,"Error opening READ_file: %s \n", marfile);
	    exit(1);
        }

        fscanf(fp1,"%d",&pixel_number); //pixel number = los bin de los difractogramas
        fscanf(fp1,"%d",&gamma); //gamma = cantidad de difractogramas (360 en este caso)

        fgets(buf,100,fp1); //skip line

        printf("pixel=%d gamma=%d\n",pixel_number,gamma);

        /*Data Read-In */

        for(y=1;y<=gamma;y++) //itero sobre todos los difractogramas (360) (recordar que iterar sobre todos los difractogramas implica obtener un valor de intensidad para cada punto del anillo de Debye)
        {
            for(x=1;x<=pixel_number;x++) //iteracion dentro de cada uno de los difractogramas (con 1725 puntos) (cada porcion del anillo de Debye)
            {
                //leo la intensidad de cada bin y la paso a formato de entero (why?)
                fscanf(fp1,"%e",&data1[x]);
                data[x]= (int)data1[x];
            }
          
            n=0; //numero de pico del difractograma

            do //itero sobre todos los picos del difractograma
            {
                intensity=0; count=0;
                //los bin en donde se encuentra la informacion del bg para el pico n del difractograma
                a = ug_l[n]; 
                b = ug_r[n];
                //guarda el valor de background correspondiente a los bin del pico adecuado del difractograma correspondiente (que trabalenguas!!)
                BG_l = data[a];
                BG_r = data[b];
                //background promedio
                BG_m = ((BG_l+BG_r)/2);

                for(z=posring_l[n];z<=posring_r[n];z++) //integro el pico
                { 
                    count++;
                    intensss.nnew =data[z];
                    intensity += intensss.nnew;
                }                                       
           
                /** I think here would the nice place to integrate the peak - fitting or width calculation routine **/
    		    /** because here are the peak data still readable in raw-format**/
		   
    		    intens[y][n]= (intensity/count)-BG_m;  // Integral values and BG correction

                n++;

            }while(n<numrings);
            
        } /*end of the double FOR-routine gamma and pixel number*/
        
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	//////////////LA INFORMACION CRUDA DE LOS DIFRACTOGRAMAS SE ENCUENTRA EN EL VECTOR data[]////////////////
	//////ESTE ES EL LUGAR PARA HACER LA RUTINA QUE HAGA EL FULL PROFILE FITTING DE CADA DIFRACTOGRAMA///////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Aca iria una funcioncita que tome el vector data[], haga el ajuste y devuelva los valores de ancho de pico y eta

	//A esta altura ya termine de leer y procesar los datos de UN archivo spr. Falta imprimir los resultados a el archivo de salida
        for(d=0;d<numrings;d++)//itero sobre todos los picos
        { 
            strcpy(outinten,"");
            count_minus =0;
            
            for(c=1;c<=((end_g - rot_p)+1);c++) //itero sobre todo el anillo
            { 
		if(intens[c][d]<0) //corrijo las intensidades negativas
		{ 
		    if((minus_zero=='y')||(minus_zero=='Y'))
		    intens[c][d]=0; 
		    count_minus++;  
                }
		//escribo la intensidad integrada al archivo correspondiente en formato de diez columnas, separando por bloques los datos de cada pico
		sprintf(buf,"%8.1f",intens[c][d]);
                strcat(outinten,buf);
                if((c%10)==0)
                    strcat(outinten,"\n");
                
		if(c==((end_g - rot_p)+1))
                    strcat(outinten,"\n");
            }//va llenando el buffer de memoria con las intensidades de cada pico y luego lo imprime todo en el archivo (muy eficiente!!)
            write(fd[d], outinten, strlen(outinten));
            
	    //escribir el file con la figura de polos en formato maquina para los ancho de pico
	    
	    
	    if(count_minus>=1)//te avisa que tuviste picos con intensidades negativas
	    {
                printf("\n!!Number of MINUS intensity in the [%d]th pole figure=%d !!! \n",d+1,count_minus);
            } 		 
	}
        
        fclose(fp1);
        
        k += del_d; //paso al siguiente spr
    
    }while(k <= end_d);
     
    /*End pole figure data in Machine coordinates*/
    
    printf("\nReduction of the Fit2D-DATA is finished.\n%d pole figure data are generated.\n\n",d);
    
    for(d=0;d<numrings;d++)
        close(fd[d]);

    ////////////////////////////MODULO DE TRANSFORMACION ANGULAR////////////////////////////////
    ///////////////////////////////////THIS IS THE POST/////////////////////////////////////////
    
    printf("\n====== Begin angular transformation ====== \n");
    
    /**** Angular Transformation to Pole figure coordinate***/
    /**** LIN2GKSS-ROUTINE **********************************/
    
    timer = time(NULL); // present time in sec
    
    zeit = localtime(&timer); // save "time in sec" into structure tm
    
    printf("Unix Time: %d sec\n\n", timer); // began at 1970-1-1 0h0min0sec
    /*
    printf("year: %d\n",   zeit->tm_year + 1900);
    printf("month: %d\n",   zeit->tm_mon + 1);
    printf("day: %d\n\n", zeit->tm_mday);
    
    printf("hour: %d\n",   zeit->tm_hour);
    printf("min: %d\n",   zeit->tm_min);
    printf("sec: %d\n\n", zeit->tm_sec);
    */
    
    for(m=0;m<numrings;m++)//itero sobre todos los picos
    {
        step=1;//Si step > 1 lo que hago es promediar step's intensidades de la figura de polos en formato maquina
        
        //genero string con el nombre del archivo con la figura de polos en el formato maquina
        strcpy(outfile,"");
        strcat(outfile,path_out);
        strcat(outfile,filename1);
        strcat(outfile,"PF_");
        sprintf(buf,"%d",m+1);
        strcat(outfile,buf);
	    if((logfile_yn == 'y')||(logfile_yn == 'Y'))
            strcat(outfile,".log");
	    else
            strcat(outfile,".dat");
        
        if((fp2=fopen(outfile,"r"))== NULL )
        {
          fprintf(stderr,"Error beim oeffnen der Datei(%s).",outfile); exit(1);
        }
        
        //genero el string con los datos en formato MTEX
        strcpy(linfile,"");
        strcat(linfile,path_out);
        strcat(linfile,filename1);
        strcat(linfile,"PF_");
        sprintf(buf,"%d",m+1);
        strcat(linfile,buf);
        strcat(linfile,".mtex");
        
        if((fp1=fopen(linfile,"w"))== NULL )
        {
            fprintf(stderr,"Error beim oeffnen der Datei(%s).",linfile); exit(1);
        }
        
        //genero archivo con el grid de la figura de polos
        if((fp3=fopen("PF_grid.dat","w"))== NULL )
        {
            fprintf(stderr,"Error opening file.writing file"); exit(1);
        }
        
        //leo el \gamma inicial, el final y el salto
        fgets(buf,42,fp2);
        fscanf(fp2,"%d",&anf_gam);
        fscanf(fp2,"%d",&ende_gam);
        fscanf(fp2,"%d",&del_gam);
        
        fgets(buf,2,fp2);//skip line
        
        //leo el \omega inicial, el final y el salto
        fgets(buf,42,fp2);
        fscanf(fp2,"%f",&anf_ome);
        fscanf(fp2,"%f",&ende_ome);
        fscanf(fp2,"%f",&del_ome);
        
        printf("anf_gam=%5d , end_gam=%5d , del_gam=%5d \nanf_ome=%5.1f , end_ome=%5.1f , del_ome=%5.1f \n\n",anf_gam,ende_gam,del_gam,anf_ome,ende_ome,del_ome);
        step_ome=abs((ende_ome-anf_ome)/del_ome);
        
        if(ende_ome<anf_ome)
            del_ome=-1*del_ome;
        
        //Imprimo el tiempo de ejecucion del programa en el .mtex
        fprintf(fp1,"  FIT2D_DATA.exe: %d-%2d-%2d %2d:%2d:%2d\n",zeit->tm_year + 1900,zeit->tm_mon + 1,zeit->tm_mday,zeit->tm_hour,zeit->tm_min,zeit->tm_sec);
        
        k=0;//contador del archvo grid y el de mtex
        //tranformacion angular (gamma, omega)-->(alpha,beta)
        if(ende_ome>anf_ome)
        {
            i=anf_ome;
            while(i<=ende_ome)//itero sobre \omega
            {
                for(j=anf_gam;j<=ende_gam;j+=del_gam)//itero sobre \gamma
                {
                    neu_gam1=j;
                    neu_ome1=i;
                    //transformacion geometrica
		    if(neu_ome1>90)
		    {
                        neu_ome = neu_ome1-90;
                        neu_gam = neu_gam1+180;
                    }
                    else
                    {
                        neu_ome = neu_ome1;
                        neu_gam = neu_gam1;
                    }
                    
                    alpha = winkel_al(theta[m],neu_ome,neu_gam);
                    beta  = winkel_be(theta[m],neu_ome,neu_gam,alpha);
                    
                    if(j%step==0)
                    {
                        n_intens=0;
                        for(l=1;l<=step;l++)
                        {
                            fscanf(fp2,"%f",&m_intens);//leo la intensidad de la figura de polos en formato maquina
                            n_intens += m_intens;
                        }
                        
                        nn_intens=n_intens/step;
                        
                        if(alpha>90)
                        {
                            alpha=180-alpha;
                            beta=360-beta;
		        }
                        else
                            alpha=alpha;
                        
                        //imprimo las intensidades en formato figura de polos, asi como el grid
	                if(theta>0)
                        {
                            fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            ,k+1,2*theta[m],theta[m],alpha,beta,nn_intens);
                        }
                        else
                        {
                            fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            ,k+1,-2*theta[m],-1*theta[m],alpha,beta,nn_intens);
                        }
                        
	                fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
                        ,k+1,neu_ome,neu_gam,alpha,beta); 
                        
                        k++;
                    }
                }
                i+=del_ome;
            }
        }
        else
        {
            i=anf_ome;
            while(i>=ende_ome)
            {
                for(j=anf_gam;j<=ende_gam;j+=del_gam)
                {
                    neu_gam=j;
                    neu_ome=i;
                    
                    alpha = winkel_al(theta[m],neu_ome,neu_gam);
                    
                    beta  = winkel_be(theta[m],neu_ome,neu_gam,alpha);
                    
                    fscanf(fp2,"%f",&m_intens);
                    
                    if(j%step==0)
                    {
                        if(alpha>90)
                        {
                            alpha=180-alpha;
                            beta=360-beta;
    		            }
                        else
                            alpha=alpha;
                        
                        if(theta>0)
                        {
                            fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            ,k+1,2*theta[m],theta[m],alpha,beta,m_intens); 
                        }
                        else
                        {
                            fprintf(fp1,"%11d%10.4f%10.4f%10.4f%10.4f%12.0f\n"
                            ,k+1,-2*theta[m],-1*theta[m],alpha,beta,m_intens);
                        }
                        
                        fprintf(fp3,"%11d%10.1f%10.1f%10.4f%10.4f\n"
                        ,k+1,neu_ome,neu_gam,alpha,beta);
                        
                        k++;
                    }
                }
                i+=del_ome;
            }
        }
        fflush(fp1); fflush(fp2); fflush(fp3);
        fclose(fp3); fclose(fp1); fclose(fp2);
        
    }	/* End for(m=0;m<numrings;m++)*/

 }/*End of for(Z=1;Z<=NrSample;Z++) */

 fclose(fp);

 return (0);
} /*End of Main()*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////DEFINICION DE LAS FUNCIONES DE TRANSFORMACION ANGULAR/////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float winkel_al(float th, float om, float ga)
{
float   al,rad,chi,phi;
double  omr, gar, thr, phir, chir;
double  COSAL;


rad=pi/180;

chi=0.0;

phi=0.0;

omr=om*rad;

gar=ga*rad;

thr=th*rad;

phir=phi*rad;

chir=chi*rad;

/***the multiplication of matrix G and s */

 COSAL=(  ( (-1*cos(omr)*sin(phir)) - (sin(omr)*cos(phir)*cos(chir)) )*(-1*sin(thr)) )
       +( (-1*sin(omr)*sin(phir)) + (cos(omr)*cos(phir)*cos(chir)) ) * (cos(thr)*cos(gar));

 al = (float)(acos(COSAL))/rad;

 return (al);
 }


float winkel_be(float thb, float omb, float gab, float alb)
{
float   be,rad_be,chi_be,phi_be;
double  thbr, ombr, gabr, albr, phibr, chibr;
double  SINALCOSBE,COSBE,SINALSINBE,SINBE;


rad_be = pi/180;

chi_be = 0.0;

phi_be = 0.0;

thbr = thb*rad_be;

ombr = omb*rad_be;

gabr = gab*rad_be;

albr = alb*rad_be;

chibr = chi_be*rad_be;

phibr = phi_be*rad_be;

/*** the multiplication of matrix G and s */

 SINALCOSBE
  = ( cos(ombr)*(-1*sin(thbr)) )+( ( (sin(ombr)*cos(phibr)) + (cos(ombr)*sin(phibr)*cos(chibr)) )*(cos(thbr)*cos(gabr)) );

 COSBE = SINALCOSBE/sin(albr);

 SINALSINBE = cos(thbr)*sin(gabr);

 SINBE = SINALSINBE/sin(albr);

 if(COSBE>1.0)
    {be = 0.0;
     COSBE=1;}
 if(COSBE<-1)
    {be = 180.0;
    COSBE=-1;}

 if(SINBE<0)
      be = (float) 360 - ( acos(COSBE)/rad_be );
   else
      be = (float) acos(COSBE)/rad_be;

 if((omb==0) && (be > 270.0))
   be = 360-be;
 if((omb==0) && (be <= 80.0))
   be = 360-be;

 return (be);
 }
