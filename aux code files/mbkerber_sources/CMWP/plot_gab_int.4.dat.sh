#!/bin/bash
#plot the data from gabors.int.4.dat
plotfile=/tmp/plot$USERNAME‘date +%s%N‘.tmp

datafile=( $* )
re=""

#echo ${datafile[@]}

echo -e "">$plotfile

if [[ ${#datafile[@]} -ge 7 ]];then
    echo -e "set key off" >> $plotfile
fi
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
    echo -e "set logscale y \n \
    ${re}plot \""${datafile[$fileno]}"int.4.dat\" using 1:2 with dots title \"meas $fileno\" \n \
    replot \""${datafile[$fileno]}"int.4.dat\" using 1:3 with lines title \"fit $fileno\"\n \
    replot \""${datafile[$fileno]}"int.4.dat\" using 1:4 axes x1y2 with lines title \"res $fileno\"\n">>$plotfile
    re="re"
done
echo -e "pause -1 \"Hit return to continue\"">>$plotfile
gnuplot $plotfile
rm -f $plotfile
