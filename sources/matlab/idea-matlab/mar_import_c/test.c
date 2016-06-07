#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <time.h>
#ifndef __sgi
#include <stdlib.h>
#endif
#ifdef __unix__
#include <unistd.h>
#elif __MSDOS__ || __WIN32__ || _MSC_VER
#include <io.h>
#endif
#include "mar345_header.h"
#include "utils.h"
#include "pck.h"

/*
 * Definitions
 */
#define STRING 0
#define INTEGER 1
#define FLOAT 2
#define WORD short int

WORD * vector_WORD_alloc(int size)
{
    WORD * vector = (WORD *) malloc(size * sizeof(WORD));
    if(vector == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    return vector;
}

void print_img2file(FILE *fp, WORD * img)
{
    int i, j, k=0;
    for(i=0; i<3450; i++)
    {
        for(j=0; j<3450; j++)
        {
            fprintf(fp, " %hd", img[k]);
            k++;
        }
        fprintf(fp, "\n");
    }
}

int main(int argc, char *argv[]){
    // Leer el header de marfile
    FILE *fp = fopen(argv[1], "r");
    MAR345_HEADER h;
    h = Getmar345Header(fp);
    fclose(fp);
 
    // Sacar la informacion del header a un archivo
    FILE *fp_out = fopen(argv[2], "w");
    Writemar345Header(fp_out, h); 
    fclose(fp_out);

    // Saco las intenidades de las imagenes
    fp = fopen(argv[1], "r");
    fp_out = fopen(argv[3], "w");
    WORD * img = vector_WORD_alloc(11902500); 
    memset(img, 0, 11902500 * sizeof(WORD));
    get_pck(fp, img);
    print_img2file(fp_out, img);
    fclose(fp);
    fclose(fp_out);
    free(img);
    printf("Done!\n");
    return 0;
}
