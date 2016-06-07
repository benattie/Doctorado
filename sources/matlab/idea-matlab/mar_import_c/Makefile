# Makefile for building C stuff with GSL
#
FILE0 = test
FILE1 = mar345_header
FILE2 = utils
FILE3 = swap
FILE4 = pck
CFLAGS = -Wall -O3 -I/usr/include
LIBS = -L/usr/lib -lgsl -lgslcblas -lm
CC = gcc

idea: test.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $(FILE4).c -o $(FILE4).o
	$(CC) $(CFLAGS) -c $(FILE0).c -o $(FILE0).o
	$(CC) $(FILE0).o $(FILE1).o $(FILE2).o $(FILE3).o $(FILE4).o -o test.exe $(LIBS)

%: %.c
	$(CC) $(CFLAGS) -c $(FILE1).c -o $(FILE1).o
	$(CC) $(CFLAGS) -c $(FILE2).c -o $(FILE2).o
	$(CC) $(CFLAGS) -c $(FILE3).c -o $(FILE3).o
	$(CC) $(CFLAGS) -c $(FILE4).c -o $(FILE4).o
	$(CC) $(CFLAGS) -c $@.c -o $@.o
	$(CC) $@.o $(FILE1).o $(FILE2).o $(FILE3).o $(FILE4).o -o $@.exe $(LIBS)

clean:
	rm -f *~ *.o core *.exe *.stackdump
