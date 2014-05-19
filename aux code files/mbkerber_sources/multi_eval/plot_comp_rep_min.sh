#!/bin/bash
#plot the results from gabors.int.4.dat of the minimal residuum solution and the representative solution
#get the basis name from $1 and build both we want to fit both residua and the fits
 
ext=‘grep extension *.ini‘
ext=${ext#*=}
#echo $ext
#FIXME THIS IS NOT ROBUSAT BETTER GET THE DIRS individually and find out the
#int.4.dat file via commandline....
filename=‘basename $1 -rep‘
plotfile=/tmp/plot$USERNAME‘date +%s%N‘.tmp
###############
function toplot() {
echo -e $@ >> $plotfile
}
###############
toplot "set logscale y"
#the profile as measured same for both
toplot "set xlabel \"2{/Symbol q}\""
toplot "set ylabel \"Intensity []\""
toplot "plot \"${filename}-min/${filename}${ext}.int.4.dat\" using 1:2 with dots title \"Measured\""
toplot "replot \"${filename}-min/${filename}${ext}.int.4.dat\" using 1:3 with lines title \"min fit\""
toplot "replot \"${filename}-rep/${filename}${ext}.int.4.dat\" using 1:3 with lines title \"rep fit\""
toplot "replot \"${filename}-min/${filename}${ext}.int.4.dat\" using 1:4 axes x1y2 with lines title \"min residua\""
toplot "set y2tics nomirror"
toplot "set ytics nomirror"
toplot "replot \"${filename}-rep/${filename}${ext}.int.4.dat\" using 1:4 axes x1y2 with lines title \"rep residua\""
toplot "pause -1
#toplot
#toplot
#toplot
#toplot
\"Hit return to continue\""
"set title \"Tr22 Ag1 measurement 0\""
"set terminal postscript color enhanced eps lw 2 font \"Roman,20\" "
"set output \"${filename}_comp_min_rep.eps\" "
"replot; set output"
#toplot "pause -1
\"Hit return to continue\""
gnuplot $plotfile
rm -f $plotfile
