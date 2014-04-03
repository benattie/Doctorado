//PROGRAMA PARA ENCONTRAR RAICES COMPLEJAS DE UN POLINOMIO ARBITRARIO

#include <gsl/gsl_poly.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>

double g(double eta)
{
    return 0.72928 * eta + 0.19289 * pow(eta, 2.0) + 0.07783 * pow(eta, 3.0);
}


int main()
{
    int i, size = 5;//grado del polinomio
    double eta, b[4] = {2.69269, 2.42843, 4.47163, 0.07842},  a[size + 1], z[2 * size];
    FILE *fp_out = fopen("HG_Hvseta.dat", "w");
    gsl_poly_complex_workspace * poly_ws = gsl_poly_complex_workspace_alloc(size + 1);
    
    fprintf(fp_out, "eta  ");
    for(i = 0; i < size; i++)
    {
        fprintf(fp_out, "z_re[%d]  z_im[%d]  ", i, i);
    }
    fprintf(fp_out, "\n");

    for(eta = 0; eta <= 1; eta += 0.01)
    {
        a[0] = pow(g(eta), 5.0) - 1;
        a[1] = b[3] * pow(g(eta), 4.0);
        a[2] = b[2] * pow(g(eta), 3.0);
        a[3] = b[1] * pow(g(eta), 2.0);
        a[4] = b[0] * g(eta);
        a[5] = 1.0;
        //determino las raices del polinomio
        gsl_poly_complex_solve (a, size + 1, poly_ws, z);
        //imprimo los resultados en un archivo
        fprintf(fp_out, "%.2lf  ", eta);
        for(i = 0; i < size; i++)
        {
            fprintf(fp_out, "%.5lf  %.5lf  ", z[2 * i], z[2 * i + 1]);
        }
        fprintf(fp_out, "\n");
    }

    gsl_poly_complex_workspace_free (poly_ws);
    fclose(fp_out);
    return 0;
}

