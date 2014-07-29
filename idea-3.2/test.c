#include "pseudo_voigt.h"
#include "aux_functions.h"
#include "array_alloc.h"
#include "interpolate.c"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>


int main(int argc, char **argv)
{
   char alldatafile[500], filename1[500], path_out[500], buf[1024];
   int m, numrings = 7, k[7] = {3330, 3330, 3330, 3330, 3330, 3330, 3330};
   FILE *fp_all, *fp_reg;
    
    //////////////////////////////////////////////////////////////////////////////    
    printf("\n======= Setting regular grid =======\n");
    for(m = 0; m < numrings; m++)
    {
        strcpy(path_out, "/home/benattie/Documents/Doctorado/Git/tmp/interpolate/");
        strcpy(filename1, "Al-AR-M-H-tex_");
        //ARCHIVO CON LOS DATOS EN LA GRILLA IRREGULAR
        strcpy(alldatafile, "");
        strcat(alldatafile, path_out);
        strcat(alldatafile, filename1);
        strcat(alldatafile, "ALL_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(alldatafile, buf);
        strcat(alldatafile, ".mtex");
        if((fp_all = fopen(alldatafile, "r")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", alldatafile);
            exit(1);
        }
        //ARCHIVO CON LOS DATOS EN UNA GRILLA REGULAR
        strcpy(alldatafile, "");
        strcat(alldatafile, path_out);
        strcat(alldatafile, filename1);
        strcat(alldatafile, "REG_PF_");
        sprintf(buf, "%d", m + 1);
        strcat(alldatafile, buf);
        strcat(alldatafile, ".mtex");
        if((fp_reg = fopen(alldatafile, "w")) == NULL)
        {
            fprintf(stderr, "Error beim oeffnen der Datei(%s).\n", alldatafile);
            exit(1);
        }
        printf("Printing regular grid file %s with %d points\n", alldatafile, k[m]);
        interpolate(fp_all, fp_reg, atof(argv[1]), 10, 5, k[m]);
        fclose(fp_all);
        fclose(fp_reg);
    }
    //end for routine for(m = 0; m < numrings; m++)
    printf("\n======= Finished writting regular grid =======\n");
    //////////////////////////////////////////////////////////////////////////////
    return 0;
}
