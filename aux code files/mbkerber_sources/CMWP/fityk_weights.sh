1 #!/bin/bash
2
3 datafile=$1
4 fitykfile=$datafile.fit
5
6 ###############
7 function tofit() {
8 echo -e $@ >> $fitykfile
9 }
10 ##############
11
12 # init fit file
13 echo -e "">$fitykfile
14 #first load the file
15 tofit "@+ < ’${datafile}’"
16
17
18 #tofit "s=sqrt(abs(y))"
19 tofit "s=sqrt(abs(y-0.9))"
20
21 #when we have negative values some can be close to zero causing them to have far too much weight!
22 #fix this problem not here. !
23 #having our BG around 1 we take the lowest value as reference resulting in \pm 1 as scatter and finally shifting that to 1+eps=0.2
24 #tofit "s=(y-1)/abs(min(y-1))+2.2"
25 #tofit "s=s/min(s)"
26
27 tofit "info @0 (x, y, s) > ’${datafile}.weighted.dat’"
28
29 tofit "quit"
30
31 fityk $fitykfile
32 remove_comments.sh ${datafile}.weighted.dat
