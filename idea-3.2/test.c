//#include "pseudo_voigt.h"
//#include "aux_functions.h"
//#include "array_alloc.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define pi 3.14159265

float winkel_be(float in)
{
    float   be, rad_be;
    double  COSBE, SINBE;
    
    rad_be = pi / 180;
    
    COSBE = cos(in * rad_be);
    SINBE = sin(in * rad_be);

    if(COSBE > 1.0)
    {
        be = 0.0;
        COSBE = 1.0;
    }
    if(COSBE < -1)
    {
        be = 180.0;
        COSBE = -1.0;
    }

    if(COSBE >= 0){
        if(SINBE >= 0)
            be = (float) (acos(COSBE) / rad_be);
        else
            be = (float) (360 + asin(SINBE) / rad_be);
    }else{
         if(SINBE >= 0)
            be = (float) (acos(COSBE) / rad_be);
        else
            be = (float) ((acos(COSBE) - 2 * asin(SINBE)) / rad_be);
    }

    return (be);
}

int main(int argc, char **argv)
{
    float a = atof(argv[1]);
    float be = winkel_be(a);
    printf("ingreso %f, egreso %f\n", a, be);
    a += 90;
    be = winkel_be(a);
    printf("ingreso %f, egreso %f\n", a, be);
    a += 90;
    be = winkel_be(a);
    printf("ingreso %f, egreso %f\n", a, be);
    a += 90;
    be = winkel_be(a);
    printf("ingreso %f, egreso %f\n", a, be);
    a += 90;
    be = winkel_be(a);
    printf("ingreso %f, egreso %f\n", a, be);
    return 0;
}
