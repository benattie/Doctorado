1 #!/bin/bash
2
3 if [[ $# != 5 ]]; then
4 echo -e "\n usage:\n\t $0 lambda peakcenter_2theta h k l\n"
5 exit 1
6 fi
7
8  if [[ -z $lambda ]]; then
9   lambda=$1
10 fi
11 if [[ -z $peakcenter ]]; then
12 peakcenter=$2
13 fi
14
15 #echo $lambda $a_lattice
16
17 function calclattice() {
18 h=$1
19 k=$2
20 l=$3
21 #FIXME i want a better way to compute this - bc is nice but there are like no functions defined.... how to improve on that? is there a better alternative
22 #OLD 2theta = echo "scale=10;pos=2*asin($lambda*sqrt(h^2+k^2+l^2)/(a_lattice*2))*180/pi;scale=2; print pos" |bc -l ‘which extensions.bc‘
23
24 #NEW 3dezimal places out via round
25 #maybe use isreal to determine if we are wthin sensible range...
26 # calc_func="round(re(2*asin($lambda*sqrt($h^2+$k^2+$l^2)/($a_lattice*2))*180/pi()),3)"
27 calc_func="round(re( ($lambda/2)*sqrt($h^2+$k^2+$l^2)/sin($peakcenter*pi()/360) ),5)"
28 # echo $calc_func
29 local a_lattice=‘calc -p "$calc_func"‘
30 echo $a_lattice
31 }
32
33 calclattice $3 $4 $5
