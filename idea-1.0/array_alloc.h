#ifndef ARRAY_ALLOC_H_   /* Include guard */
#define ARRAY_ALLOC_H_

//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>

double * vector_double_alloc(int size);
int * vector_int_alloc(int size);
double ** matrix_double_alloc(int nrow, int ncol);
int ** matrix_int_alloc(int nrow, int ncol);
void free_int_matrix(int ** matrix, int nrow);
void free_double_matrix(double ** matrix, int nrow);

#endif
