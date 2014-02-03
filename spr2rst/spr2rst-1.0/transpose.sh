#!/bin/bash

file="$1"
sed 1d $file > aux.txt
dos2unix aux.txt
less aux.txt | tr -s ' ' > aux2.txt
sed -i 's/ /,/' pp.dat
cols=`head -n 1 pp.dat | wc -w`
for (( i=1; i <= $cols; i++))
do cut -d ' ' -f $i pp.dat | tr $'\n' $'\t' | sed -e "s/\t$/\n/g" >> output
done
rm aux.txt aux2.txt
pp
