1 #!/bin/bash
2 i=$1
3 mv $i $i.tmp
4 #this will remove the comments and any trailing newlines!
5 #the latter is done by the regexp ^\s*$
6 egrep -v ’(^#|^\s*$)’ $i.tmp > $i
7 # grep -v "#" $i.tmp>$i
8 rm $i.tmp
