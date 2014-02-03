#!/bin/bash

file="$1"
lines=`cat $file | wc -l`
cols=`head -n 1 $file | wc -w`

#for (( i=1; i<=$lines; i++ ))
#do
# sed -i "$is/^/a$i /" $file 
#done

for (( i=1; i<=$cols; i++ ))
do
 awk '{print $i > "hola"}' $file 
done
