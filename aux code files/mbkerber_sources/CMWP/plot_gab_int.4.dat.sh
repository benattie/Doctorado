1 #!/bin/bash
2 #plot the data from gabors.int.4.dat
3 plotfile=/tmp/plot$USERNAME‘date +%s%N‘.tmp
4
5 datafile=( $* )
6 re=""
7
8 #echo ${datafile[@]}
9
10 echo -e "">$plotfile
11
12 if [[ ${#datafile[@]} -ge 7 ]];then
13 echo -e "set key off" >> $plotfile
14 fi
15 for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
16 echo -e "set logscale y \n \
17 ${re}plot \""${datafile[$fileno]}"int.4.dat\" using 1:2 with dots title \"meas $fileno\" \n \
18 replot \""${datafile[$fileno]}"int.4.dat\" using 1:3 with lines title \"fit $fileno\"\n \
19 replot \""${datafile[$fileno]}"int.4.dat\" using 1:4 axes x1y2 with lines title \"res $fileno\"\n">>$plotfile
20 re="re"
21 done
22 echo -e "pause -1 \"Hit return to continue\"">>$plotfile
23 gnuplot $plotfile
24 rm -f $plotfile
