#!/bin/bash
i=$1
mv $i $i.tmp
#this will remove the comments and any trailing newlines!
#the latter is done by the regexp ^\s*$
egrep -v '(^#|^\s*$)' $i.tmp > $i
# grep -v "#" $i.tmp>$i
rm $i.tmp
