# Makefile for building C stuff with GSL

#CFLAGS = -Wall -O3 -I/usr/include
CFLAGS = -Wall 
#LIBS = -L/usr/lib -lgsl -lgslcblas -lm
LIBS = -lgsl -lgslcblas -lm
CC = gcc

%: %.c
#	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@
	$(CC) $(CFLAGS) -c $@.c
	$(CC) $@.o -o $@.exe $(LIBS)

# eg. do "make gsl_test" to make gsl_test from gsl_test.c
# then run with "gsl_test 10"

clean:
	rm -f *~ *.o core *.exe
