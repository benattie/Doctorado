/*#include <stdlib.h>
#include <stdio.h>

#include <gsl/gsl_vector.h>
*/
//la idea es hacer una funcion que lea un dif.dat y me saque el vector de las intensidades

gsl_vector * data(char * name, int size){
    FILE * fp;
    //FILE *  fout;
    gsl_vector * x = gsl_vector_alloc(size);
    gsl_vector * y = gsl_vector_alloc(size);
    char buf[100];
    int i;
    float ttheta[size], intens[size];

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
    while(fscanf(fp, "%f", &ttheta[i]) != EOF && fscanf(fp, "%f", &intens[i]) != EOF)
    {//lectura del archivo
        gsl_vector_set (x, i, ttheta[i]);
        gsl_vector_set (y, i, intens[i]);
        i++;
    }
    
    /*
    if((fout = fopen("intens.dat","w")) == NULL )
    {//abro el archivo
        fprintf(stderr,"Error opening file(intens.dat).");
        exit(1);
    }
    
    for (i = 0; i < 1725; i++)
    {
        fprintf (fout, "y_%d = %g\n", i, gsl_vector_get (y, i));
    }

    */

    //cierro archivos y libero variables
    gsl_vector_free (x);
    //gsl_vector_free (y);
    
    fclose (fp);
    //fclose (fout);

    //printf("God's in his heaven\nAll fine with the world\n");
    return y;


}


