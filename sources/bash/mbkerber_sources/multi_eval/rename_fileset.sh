#!/bin/bash
source=$1
target=$2

#if [[ $# -ne 2 || !(-e $source) ]];then
if [[ $# -ne 2 ]];then
	echo -e "usage:"
	echo -e "\t\033[1m‘basename $0‘\033[0m\E[31;47m name of the source \E[37;m target name"
	tput sgr0
	echo -e "takes all files source* and mv them to target*\n\n"
	exit 1
fi

OLDIFS="$IFS"
IFS=$’\n’
j=0 #base array index
declare -a ext #declare extension array
for files in ${source}*;do
   ext[$j]=${files#*$source}
   #echo ${ext[$j]}
   ((j++))
done

for i in ${ext[@]};do
    mv -i $source$i $target$i
done
IFS=$OLDIFS
