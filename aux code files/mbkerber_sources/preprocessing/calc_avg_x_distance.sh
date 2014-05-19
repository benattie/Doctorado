1 #!/bin/bash
2
3 #FIXME file checks and exit 1
4
5 datafile=$1
6 tempfile=$1_avg.tmp
7
8 #first clean input and write to tempfile
9 #this will remove the comments and any trailing newlines!
10 #the latter is done by the regexp ^\s*$
11 egrep -v ’(^#|^\s*$)’ $datafile |cut -f 1 > $tempfile
12
13 #get number of lines aka data points
14 nolines=‘cat $tempfile | wc -l‘
15 #echo $nolines
16
17 #get the first x point and the last and do the diff
18 first=( ‘head -1 $tempfile‘ )
19 last=( ‘tail -1 $tempfile‘ )
20
21 #FIXME debug flag
22 #echo "last line = " $last
23 #echo "first line = "$first
24
25 avg=‘calc -p "round((($last)-($first))/$nolines,5)"‘
26 echo $avg
27 rm $tempfile
28 exit 0
