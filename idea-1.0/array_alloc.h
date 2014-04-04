#ifndef ARRAY_ALLOC_H_   /* Include guard */
#define ARRAY_ALLOC_H_

//HEADERS BASICOS
#include <stdlib.h>
#include <stdio.h>
//allocacion de vectores de tamaño size
double * vector_double_alloc(int size);
int * vector_int_alloc(int size);

//allocacion de matrices de tamaño nrow x ncol
double ** matrix_double_alloc(int nrow, int ncol);
void free_double_matrix(double ** matrix, int nrow);
int ** matrix_int_alloc(int nrow, int ncol);
void free_int_matrix(int ** matrix, int nrow);

//allocacion de tensores de rango 3 de tamaño d1 x d2 x d3
double *** r3_tensor_double_alloc(int d1, int d2, int d3);
void free_double_r3_tensor(double *** tensor, int d2, int d3);

#endif
