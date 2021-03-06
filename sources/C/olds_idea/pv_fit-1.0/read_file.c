/*#include <stdlib.h>
#include <stdio.h>

#include <gsl/gsl_vector.h>
*/
//la idea es hacer una funcion que lea un dif.dat y me saque el vector de las intensidades

void data(char name[15], int size, gsl_vector * x, gsl_vector * y){
    FILE * fp;
    char buf[100];
    int i;
    double ttheta[size], intens[size];

    if((fp = fopen(name, "r")) == NULL )
    {//abro el archivo
        fprintf(stderr,"Error opening file(%s).", name);
        exit(1);
    }
    
    //lectura del encabezado
    fgets(buf,100,fp);
    //printf("%s\n", buf);
    fgets(buf,2,fp);
    //printf("%s\n", buf);
    
    i = 0;
    while(fscanf(fp, "%lf", &ttheta[i]) != EOF && fscanf(fp, "%lf", &intens[i]) != EOF)
    {//lectura del archivo
        gsl_vector_set (x, i, ttheta[i]);
        gsl_vector_set (y, i, intens[i]);
        i++;
    }
    //cierro archivos y libero variables
    fclose (fp);
}


