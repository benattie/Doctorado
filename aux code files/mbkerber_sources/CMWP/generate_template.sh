#!/bin/bash
#input
#$1 template basename ending on .
#$2 datafile basename not ending on .
for i in ini fit.ini q.ini;do
cp ${1}${i} ${2}.dat.${i};
done
