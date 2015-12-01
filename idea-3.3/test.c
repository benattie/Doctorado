//#include "pseudo_voigt.h"
//#include "aux_functions.h"
//#include "array_alloc.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#define pi 3.14159265

double winkel_be(double in)
{
    double   be, rad_be;
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
            be = (double) (acos(COSBE) / rad_be);
        else
            be = (double) (360 + asin(SINBE) / rad_be);
    }else{
         if(SINBE >= 0)
            be = (double) (acos(COSBE) / rad_be);
        else
            be = (double) ((acos(COSBE) - 2 * asin(SINBE)) / rad_be);
    }

    return (be);
}

double winkel_be_orig(double thb, double omb, double gab, double alb)
{
    double   be, rad_be, chi_be, phi_be;
    double  thbr, ombr, gabr, albr, phibr, chibr;
    double  SINALCOSBE, COSBE, SINALSINBE, SINBE;
    
    rad_be = pi / 180;
    chi_be = 0.0;
    phi_be = 0.0;
    thbr = thb * rad_be;
    ombr = omb * rad_be;
    gabr = gab * rad_be;
    albr = alb * rad_be;
    chibr = chi_be * rad_be;
    phibr = phi_be * rad_be;

    /*** the multiplication of matrix G and s */
    SINALCOSBE = (cos(ombr) * cos(phibr) - sin(ombr) * sin(phibr) * cos(chibr)) * (-1 * sin(thbr))
               + (sin(ombr) * cos(phibr) + cos(ombr) * sin(phibr) * cos(chibr)) * (cos(thbr) * cos(gabr))
               + (sin(phibr) * sin(chibr) * (cos(thbr) * sin(gabr)));
    
    COSBE = SINALCOSBE / sin(albr);

    SINALSINBE = (sin(ombr) * sin(chibr)) * (-1 * sin(thbr))
               + (-1 * cos(ombr) * sin(chibr)) * (cos(thbr) * cos(gabr))
               + cos(chibr) * (cos(thbr) * sin(gabr));

    SINBE = SINALSINBE / sin(albr);

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

    if(SINBE < 0)
        be = (double) 360 - (acos(COSBE) / rad_be);
    else
        be = (double) acos(COSBE) / rad_be;

    if((omb == 0) && (be > 270.0))
        be = 360 - be;
    if((omb == 0) && (be <= 80.0))
        be = 360 - be;


    return (be);
}

int main(int argc, char **argv)
{
    double a = atof(argv[1]);
    double be = winkel_be(a);
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
