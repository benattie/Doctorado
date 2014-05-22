#!/bin/bash
final_run=$1
targetdir=$2

if [[ $# != 2 ]]; then
echo -e "\n usage:\n\t $0 final_run_number target_dir\n"
exit 1
fi
if [[ ! -d $targetdir ]];then
echo -e "\tTarget Dir $targetdir does not exist!"
read -e -n 1 -p " To create it press ’y’ any other key cancels>" doit
if [[ $doit == ’y’ ]];then
mkdir $targetdir
else
exit 1
fi
fi
for i in *-${1};do
if [[ $i == "*-${1}" ]];then
echo -en "\tnothing to do\n"
exit 1
fi
source_basename=‘basename $i -$final_run‘
echo -en "\t moving $source_basename \n"
