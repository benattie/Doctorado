1 #!/bin/bash
2
3 #2del
4 for i in .evaluate_pid .gnuplot_pid .gnuplot_x11_pid .gnu .gnuplot_out .int0.ps .int.bg.dat .int.jpg .int.m.dat .int.ps .int.sol .int.th0.dat .int.th2.dat .int.th.dat .physsol.csv
5 do
6 rm *$i
7 done
8
9  #only for full
10 if [[ $1 == "--all" ]];then
11 for i in .checked .int.4.dat .int.bw.ps .sol .weighted.dat;do
12 rm *$i
13 done
14 fi
