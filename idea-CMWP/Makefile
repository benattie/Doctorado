# Makefile for building C stuff with GSL

FILE1 = pseudo_voigt
FILE2 = array_alloc
FILE3 = aux_functions
CFLAGS = -Wall -O3 -I/usr/include
LIBS = -L/usr/lib -lgsl -lgslcblas -lm
CC = gcc

idea_cmwp: idea_cmwp.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o $(FILE3).o -o $@.exe $(LIBS)

# eg. do "make gsl_test" to make gsl_test from gsl_test.c
# then run with "gsl_test 10"

%: %.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o $(FILE3).o -o $@.exe $(LIBS)

clean:
	rm -f *~ *.o core *.exe *.stackdump
