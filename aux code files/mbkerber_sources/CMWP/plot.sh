1 #!/bin/bash
2 temp=/tmp/plot$USERNAME‘date +%s%N‘.tmp
3 datafile=( $* )
4 re=""
5 axis=""
6 using="" #"using 1:6"
7 echo -e "">$temp
8
9  if [[ ${#datafile[@]} -ge 7 ]];then
10 echo -e "set key off" >> $temp
11 fi
12 #echo -e "set logscale y">>$temp
13 for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
14 echo -e "${re}plot \""${datafile[$fileno]}"\" $using with lines" $axis >>$temp
15 re="re"
16 # axis="axis x1y2"
17 done
18 #echo -e "set terminal postscript color enhanced">>$temp
19 #echo -e "set output \"temp.eps\"">>$temp
20 #echo -e "replot">>$temp
21
22
23 echo -e "pause -1 \"Hit return to continue\"">>$temp
24 gnuplot $temp #--noraise
25 #rm -f $temp
