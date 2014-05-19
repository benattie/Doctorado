#!/bin/bash
#echo -e ""
#old data_file\tm\tsigma\td\tl0\tq\trho\tre\tms\tepsilon\tst_pr\tres
#for i in $1*$2;do print_sol.sh $i/*xy.sol;done
for i in $1*$2;do print_sol.sh $i/‘basename $1 .dat‘.sol;done
