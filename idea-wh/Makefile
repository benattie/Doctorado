# Makefile for building C stuff with GSL

FILE1 = array_alloc
FILE2 = funciones
CFLAGS = -Wall -O3 -I/usr/include
LIBS = -lgsl -lgslcblas -lm
CC = gcc

williamsonhall: williamsonhall.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o -o $@.exe $(LIBS)

# eg. do "make gsl_test" to make gsl_test from gsl_test.c
# then run with "gsl_test 10"

clean:
	rm -f *~ *.o core *.exe *.stackdump
