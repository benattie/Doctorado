#include <stdio.h>
#include <math.h>
#include <stdlib.h>

double winkel_al(double th, double om, double ga)
{
    double   al, rad;
    double  omr, gar, thr;
    double  COSAL;
    double pi = 3.14159;

    rad = pi / 180;
    omr = om * rad;
    gar = ga * rad;
    thr = th * rad;

    /***the multiplication of matrix G and s */
     COSAL = sin(omr) * sin(thr) + cos(omr) * cos(thr) * cos(gar);
     al = (double)(acos(COSAL)) / rad;
     return al;
}

double winkel_be(double thb, double omb, double gab, double alb)
{
    double  be, rad;
    double  thbr, ombr, gabr, albr;
    double  SINALCOSBE, COSBE, SINALSINBE, SINBE;
    double pi = 3.14159;
    rad = pi / 180;
    thbr = thb * rad;
    ombr = omb * rad;
    gabr = gab * rad;
    albr = alb * rad;

    /*** the multiplication of matrix G and s */
    SINALCOSBE = -1* cos(ombr) * sin(thbr) + sin(ombr) * cos(thbr) * cos(gabr);
    
    COSBE = SINALCOSBE / sin(albr);

    SINALSINBE = cos(thbr) * sin(gabr);

    SINBE = SINALSINBE / sin(albr);
    
    be = -1;
    if(COSBE >= 1.0)
    {
        be = 0.0;
        COSBE = 1.0;
    }
    if(COSBE <= -1.0)
    {
        be = 180.0;
        COSBE = -1.0;
    }
    if(be == -1){
        if(COSBE >= 0){
            if(SINBE >= 0)
                be = (double) (acos(COSBE) / rad);
            else
                be = (double) (360 + asin(SINBE) / rad);
        }else{
             if(SINBE >= 0)
                be = (double) (acos(COSBE) / rad);
            else
                be = (double) (360 + atan2(SINBE, COSBE) / rad);
        }
    }
    return be;
}

int main (int argc, char * argv []){
    
    double alpha, beta, theta, omega, gamma;
    FILE *fp;
    if (argc == 4){
        theta = atof(argv[1]);
        omega = atof(argv[2]);
        gamma = atof(argv[3]);
        alpha = winkel_al(theta, omega, gamma);
        beta = winkel_be(theta, omega, gamma, alpha);
        printf("alpha = %lf\nbeta = %lf\n", alpha, beta);
    }else{
        fp = fopen(argv[1], "r");
        while(fscanf(fp, "%lf %lf %lf", &theta, &omega, &gamma) != EOF)
        {
            alpha = winkel_al(theta, omega, gamma);
            beta = winkel_be(theta, omega, gamma, alpha);
            printf("-----------------------\n");
            printf("alpha = %lf\nbeta = %lf\n", alpha, beta);
            printf("-----------------------\n");
        }
        fclose(fp); 
    }

    return 0;
}
