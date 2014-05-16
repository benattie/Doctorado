1 #!/bin/bash
2 #input
3 #$1 template basename ending on .
4 #$2 datafile basename not ending on .
5 for i in ini fit.ini q.ini;do
6 cp ${1}${i} ${2}.dat.${i};
7 done
