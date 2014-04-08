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

void free_double_matrix(double ** matrix, int nrow)
{
    int i;
    for(i = 0; i < nrow; i++)
    {
        free(matrix[i]);
    }
    free(matrix);
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

double *** r3_tensor_double_alloc(int d1, int d2, int d3)
{
    int i, j;
    double *** tensor = (double ***) malloc(d1 * sizeof(double **));
    if(tensor == NULL)
    {
        printf("Out of memory\n");
        exit (1);
    }
    for(i = 0; i < d1; i++)
    {
        tensor[i] = (double **) malloc(d2 * sizeof(double *));
        if(tensor[i] == NULL)
        {   
            printf("Out of memory\n");
            exit (1);
        }
        for(j = 0; j < d2; j++)
        {
            tensor[i][j] = (double *) malloc(d2 * sizeof(double));
            if(tensor[i][j] == NULL)
            {   
                printf("Out of memory\n");
                exit (1);
            }
        }
    }
    return tensor;
}

void free_r3_tensor_double(double *** tensor, int d2, int d3)
{
    int i, j;
    for(i = 0; i < d2; i++)
    {
        for(j = 0; j < d3; j++)
        {
            free(tensor[i][j]);
        }
        free(tensor[i]);
    }
    free(tensor);
}

