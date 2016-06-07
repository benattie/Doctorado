#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

int main(){
    printf("Size of int: %zu\n", sizeof(int));
    printf("Size of float: %zu\n", sizeof(float));
    printf("Size of 26*char: %zu\n", sizeof(char[26]));
    printf("CHAR_BIT   = %d\n", CHAR_BIT);    
    return 0;
}
