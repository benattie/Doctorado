# Makefile for building C stuff with GSL
#
FILE0 = spr2txt
FILE1 = pseudo_voigt
FILE2 = array_alloc
FILE3 = aux_functions
CFLAGS = -Wall -O3 -I/usr/local/include
LIBS = -L/usr/local/lib -lgsl -lgslcblas -lm
CC = gcc

idea: spr2txt.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $(FILE0).c -o $(FILE0).o
	$(CC) $(FILE0).o $(FILE1).o $(FILE2).o $(FILE3).o -o idea.exe $(LIBS)

%: %.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o $(FILE3).o -o $@.exe $(LIBS)

clean:
	rm -f *~ *.o core *.exe *.stackdump
