#!/bin/bash

#FIXME file checks and exit 1

datafile=$1
tempfile=$1_avg.tmp

#first clean input and write to tempfile
#this will remove the comments and any trailing newlines!
#the latter is done by the regexp ^\s*$
egrep -v ’(^#|^\s*$)’ $datafile |cut -f 1 > $tempfile

#get number of lines aka data points
nolines=‘cat $tempfile | wc -l‘
#echo $nolines

#get the first x point and the last and do the diff
first=( ‘head -1 $tempfile‘ )
last=( ‘tail -1 $tempfile‘ )

#FIXME debug flag
#echo "last line = " $last
#echo "first line = "$first

avg=‘calc -p "round((($last)-($first))/$nolines,5)"‘
echo $avg
rm $tempfile
exit 0
