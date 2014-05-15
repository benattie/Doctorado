1 #!/bin/bash
2
3 if [[ $# != 5 ]]; then
4 echo -e "\n usage:\n\t $0 lambda a_lattice h k l\n"
5 exit 1
6 fi
7
8  if [[ -z $lambda ]]; then
9   lambda=$1
10 fi
11 if [[ -z $a_lattice ]]; then
12 a_lattice=$2
13 fi
14
15 #echo $lambda $a_lattice
16
17 function calc2theta() {
18 h=$1
19 k=$2
20 l=$3
21 #FIXME i want a better way to compute this - bc is nice but there are like no functions defined.... how to improve on that? is there a better alternative
22 #OLD 2theta = echo "scale=10;pos=2*asin($lambda*sqrt(h^2+k^2+l^2)/(a_lattice*2))*180/pi;scale=2; print pos" |bc -l ‘which extensions.bc‘
23
24 #NEW 3dezimal places out via round
25 #maybe use isreal to determine if we are wthin sensible range...
26 calc_func="round(re(2*asin($lambda*sqrt($h^2+$k^2+$l^2)/($a_lattice*2))*180/pi()),3)"
27 # echo $calc_func
28 local twotheta=‘calc -p "$calc_func"‘
29
30 #h=1;k=1;l=1;lambda=0.154;a_lattice=0.361; calc "2*asin($lambda*sqrt($h^2+$k^2+$l^2)/($a_lattice*2))*180/3.151"
31 # ~43.23273590082128725154
32 #using this we might go to our own shell script to do this for hex,... then we just use 2thetas here and also might have this coded as c...
33 #theta <fcc|hcp|ortho> h k l lambda a ...
34
35 #check if we are below 180\degree and only print if we are!
36 if [[ ${twotheta%.*} -lt 180 ]]; then
37 echo $twotheta
38 else
39 echo "ERROR"
40 exit 1;
41 fi
42 }
43
44 calc2theta $3 $4 $5
