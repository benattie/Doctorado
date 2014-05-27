# Makefile for building C stuff with GSL

FILE1 = pseudo_voigt
FILE2 = array_alloc
CFLAGS = -Wall -O3 -I/usr/include
#CFLAGS = -Wall -O3 -I/usr/include -I. -fopenmp
LIBS = -L/usr/lib -lgsl -lgslcblas -lm
#LIBS = -lgsl -lgslcblas -lm
CC = gcc

%: %.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o -o $@.exe $(LIBS)

# eg. do "make gsl_test" to make gsl_test from gsl_test.c
# then run with "gsl_test 10"

clean:
	rm -f *~ *.o core *.exe *.stackdump
