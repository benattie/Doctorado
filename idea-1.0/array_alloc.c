#include "array_alloc.h"

double * vector_double_alloc(int size)
{
    double * vector = (double *) malloc(size * sizeof(double));
    if(vector == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    return vector;
}


int * vector_int_alloc(int size)
{
    int * vector = (int *) malloc(size * sizeof(int));
    if(vector == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    return vector;
}


double ** matrix_double_alloc(int nrow, int ncol)
{
    int i;
    double ** matrix = (double **) malloc(nrow * sizeof(double *));
    if(matrix == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    for(i = 0; i < nrow; i++)
    {
        matrix[i] = (double *) malloc(ncol * sizeof(double));
        if(matrix[i] == NULL)
        {   
            printf("Out of memory\n");
            exit (1);
        }
    }
    return matrix;
}


int ** matrix_int_alloc(int nrow, int ncol)
{
    int i;
    int ** matrix = (int **) malloc(nrow * sizeof(int *));
    if(matrix == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    for(i = 0; i < nrow; i++)
    {
        matrix[i] = (int *) malloc(ncol * sizeof(int));
        if(matrix[i] == NULL)
        {   
            printf("Out of memory\n");
            exit (1);
        }
    }
    return matrix;
}

void free_int_matrix(int ** matrix, int nrow)
{
    int i;
    for(i = 0; i < nrow; i++)
    {
        free(matrix[i]);
    }
    free(matrix);
}

void free_double_matrix(double ** matrix, int nrow)
{
    int i;
    for(i = 0; i < nrow; i++)
    {
        free(matrix[i]);
    }
    free(matrix);
}
