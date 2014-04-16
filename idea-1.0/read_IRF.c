#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "pseudo_voigt.h"
#include "array_alloc.h"

double search_nu(char * buf, char * search)
{
    char *token;
    token = strtok(buf, search);
    token = strtok(NULL, search);
    return atof(token);
}

IRF read_IRF(FILE * fp)
{ 
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

    return ins;
}
