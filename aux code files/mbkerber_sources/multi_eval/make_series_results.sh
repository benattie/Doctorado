#!/bin/bash
#we need the inifile $1
#first set up the variables so we can
if [ ! -e $1 ]; then
read -e -p "Please enter the sample header string>" head
read -e -p "Please enter the sample tail string, incl ext>" tail
read -e -p "Please enter the sample extension string>" extension
echo -e "head=$head\ntail=$tail\nextension=$extension">$1
else
source $1
fi
#next set up the outfilenames for the master csv
mastercsv=‘basename $1 .ini‘.csv
#we produce datafiles with: first part is the evaluation run second the label of the measurement then the rest.
for i in $head*$tail; do
csvname=‘basename $i $extension‘.csv
if [ ! -e $csvname ];then
echo -e "process file $i\n..."
print_multi.sh $i >$csvname
filename=‘basename $i $tail‘
measno=${filename##*$head}
if [ "$extension" == ".dat" ];then
solfile=‘basename $i .dat‘
else
solfile=$i
fi
#remove the stringparts from the file so that just the run number remains
sedscript="s/$i-//;s/$i\//0/;s/${solfile}.sol/\t${measno}/;s/\///;s/filename/run\tmeasno/"
sed -i "$sedscript" $csvname
fi
done
#better we generate all the files and then continue with the processing. this way we can save the results so far.
#now do all thecsv analysis
if [ "$tail" == "$extension" ];then
files=.csv
else
files=‘basename $tail $extension‘.csv
fi
#init the mastercsv with the description head from individual file
title=‘grep measno $head*$files‘
#kick the comment
title=${title##*"measno"}
title=${title//=/}
title=${title//c_s/}
#replace the spacing to include
title="#measno\t"‘echo $title" " | sed -s "s/ /\tabs_err\trel_err\t/g" -‘
#echo -e $title
echo -e "$title">$mastercsv
#debug echo $files
for i in ${head}*$files;do
echo -e "now calculating averages for $i\n"
process_csv.sh $i $mastercsv
if [[ $? != "0" ]];then
echo -e "\n\terror running process_csv.sh \n"
#exit 1
fi
currname=‘basename $i .csv‘
#0...representative solution
#1...the solution with smallest residuum
temp=‘grep rep_sol $currname*.stat‘
rep_sol[0]=${temp#*=}
temp=‘grep min_sol $currname*.stat‘
rep_sol[1]=${temp#*=}
sol_dir_base=$currname$extension
echo $sol_dir_base
if [ "${rep_sol[0]}" == "${rep_sol[1]}" ];then
sol_dir_target[0]="$currname-min_n_rep"
iarray=( 0 )
else
sol_dir_target[0]="$currname-rep"
sol_dir_target[1]="$currname-min"
iarray=( 0 1 )
fi
for i in ${iarray[@]};do
if [[ -d ${sol_dir_target[$i]} ]];then
#echo "Old representative solution found - deleting"
rm -Rf ${sol_dir_target[$i]}
fi
if [ "${rep_sol[$i]}" == "0" ];then
sol_dir=$sol_dir_base
else
sol_dir=$sol_dir_base-${rep_sol[$i]}
fi
cp -R $sol_dir ${sol_dir_target[$i]}
done
done
sort -g $mastercsv >$mastercsv.tmp
mv $mastercsv.tmp $mastercsv
echo -e "...done\n"
exit 0
