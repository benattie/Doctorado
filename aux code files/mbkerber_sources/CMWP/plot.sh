#!/bin/bash
temp=/tmp/plot$USERNAME‘date +%s%N‘.tmp
datafile=( $* )
re=""
axis=""
using="" #"using 1:6"
echo -e "">$temp

if [[ ${#datafile[@]} -ge 7 ]];then
    echo -e "set key off" >> $temp
fi
#echo -e "set logscale y">>$temp
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
    echo -e "${re}plot \""${datafile[$fileno]}"\" $using with lines" $axis >>$temp
    re="re"
    # axis="axis x1y2"
done
#echo -e "set terminal postscript color enhanced">>$temp
#echo -e "set output \"temp.eps\"">>$temp
#echo -e "replot">>$temp

echo -e "pause -1 \"Hit return to continue\"">>$temp
gnuplot $temp #--noraise
#rm -f $temp
