#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "aux_functions.h"
int main(){
    char out_file[200];
    FILE *fp;
    time_t timer;
    struct tm *zeit;
    int k, n, i, j, neu_ome, neu_gam;
    int anf_ome=91, del_ome=5, ende_ome = 176;
    int anf_gam=0, del_gam=5, ende_gam=359;
    double alpha, beta, twotheta=3.484;

    ///// Angular Transformation to Pole figure coordinate ///
    printf("\n====== Begin angular transformation ====== \n");
    timer = time(NULL); // present time in sec
    zeit = localtime(&timer); // save "time in sec" into structure tm
    //EN ESTE ARCHIVO VOY A GUARDAR TODOS LOS DATOS JUNTOS
    sprintf(out_file, "%s", "omega_gamma2alpha_beta_91176.dat");
    if((fp = fopen(out_file, "w")) == NULL){
        fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", out_file);
        exit(1);
    }
    printf("Printing irregular grid file %s\n", out_file);
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Imprimo el tiempo de ejecucion del programa en el .mtex
    fprintf(fp, "\ntest_ang_tranf.exe: %d-%2d-%2d %2d:%2d:%2d\n", zeit->tm_year + 1900, zeit->tm_mon + 1, zeit->tm_mday, zeit->tm_hour, zeit->tm_min, zeit->tm_sec);
    fprintf(fp, "#2theta theta omega gamma alpha beta\n");
        
    k = 0;//contador del archivo mtex
    n = 1; //indice que me marca el spr
    // tranformacion angular (gamma, omega)-->(alpha,beta)
    for(i = anf_ome; i <= ende_ome; i += del_ome){ //itero sobre \omega
        for(j = anf_gam; j <= ende_gam; j += del_gam){ //itero sobre \gamma
            neu_ome = i;
            neu_gam = j;
            /* transformacion geometrica
            if(neu_ome > 90){
                neu_ome = neu_ome - 90;
                neu_gam = neu_gam + 180;
            }
            */
            if(neu_ome > 90){
                neu_ome = 177 - neu_ome;
            }
            alpha = winkel_al(0.5*twotheta, neu_ome, neu_gam);
            beta  = winkel_be(0.5*twotheta, neu_ome, neu_gam, alpha);
                    
            if(alpha > 90){
                alpha = 180 - alpha;
                beta = 360 - beta;
            }
            //salida del archivo con todos los datos
            fprintf(fp, "%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8d\n", twotheta, 0.5*twotheta, (float)(i), (float)(j), alpha, beta, k);
            //////////////////////////////////////////////////////////////////////////////////////////////////
            k++;
        }//end for routine for(j = anf_gam; j <= ende_gam; j += del_gam)
        n++;
    }//end for routine for(i = anf_ome; i <= ende_ome; i += del_ome)
    fflush(fp);
    fclose(fp);
    printf("\n======= End angular transformation ======= \n");
    return 0;
}
