#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_randist.h>
#include "pseudo_voigt.h"
//FUNCION BACKGROUND (INTERPOLACION LINEAL)
int main()
{
    double I0[7], I0_data[7], H_data = 0.04472, eta_data = 0.383873, shift_H_data[7];
    double k[7], x, x_i=-1000, x_f=1000, step=0.001, sum =0;

     
    I0[0] = 7.10; I0[1] = 119.25; I0[2] = 1.81;
    I0[3] = 13.24; I0[4] = 10.07; I0[5] = 24.06;
    I0[6] = 0.86; 
    
    I0_data[0] = 287. - 23.; I0_data[1] = 4352.0 - 23.; I0_data[2] = 71.0 - 23.;
    I0_data[3] = 411.0 - 23.; I0_data[4] = 46.00 - 23.; I0_data[5] = 298.0 - 23.;
    I0_data[6] = 53.0 - 23.;

    shift_H_data[0] = -0.021891; shift_H_data[1] = -0.021955; 
    shift_H_data[2] = -0.013464; shift_H_data[3] = -0.016474; 
    shift_H_data[4] = -0.014054; shift_H_data[5] = 0.339872; 
    shift_H_data[6] = -0.010070;
    
    int i;
    for( i = 0; i < 7; i++)
    {
        k[i] = pseudo_voigt(0., 1.,  eta_data, H_data + shift_H_data[i])  / pseudo_voigt_n(0., 0., eta_data, H_data + shift_H_data[i]);
//        k[i] = I0_data[i] / pseudo_voigt_n(0., 0., eta_data, H_data + shift_H_data[i]);
        sum = 0;
        for(x = x_i; x < x_f; x += step)
        {
            sum  += pseudo_voigt_n(x, 0., eta_data, H_data + shift_H_data[i]);
        }
        printf("sum = %.6lf\t%.3lf\n", sum * step, k[i] * sum * step - I0[i]);
    }

    return 0;
}
