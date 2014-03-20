#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "array_alloc.c"
typedef struct IRF
{
    double U;
    double V;
    double W;
    double IG;
    double X;
    double Y;
    double Z;
} IRF;

double search_nu(char * buf, char * search)
{
    char *token;
    token = strtok(buf, search);
    token = strtok(NULL, search);
    return atof(token);
}

int main()
{ 
    FILE *fp = fopen("IRF.dat","r");
    char buf[20];
    char *search = " ";
    IRF ins;
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.U = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.V = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.W = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.IG = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.X = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.Y = search_nu(buf, search);
    if(fgets(buf, 20, fp) == NULL)
        exit(1);
    else
        ins.Z = search_nu(buf, search);
    return 0;
}
