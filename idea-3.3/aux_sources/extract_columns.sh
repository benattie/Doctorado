#!/bin/bash
#Usage: sh extract_columns list_of_files.txt
#mkdir cut_pole_figures
for file in $(cat $1)
do
  echo "Extrayendo datos de $file"
  awk 'NR > 2' $file > tmp
  sed '1s/^.//' tmp > tmp2
  awk -F" " '{print $1 "    " $2 "    " $3 "    " $4 "    " $5 "    " $7 "    " $8}' tmp2 > cut_pole_figures/int_$file
  awk -F" " '{print $1 "    " $2 "    " $3 "    " $4 "    " $5 "    " $9 "    " $10}' tmp2 > cut_pole_figures/H_$file
  awk -F" " '{print $1 "    " $2 "    " $3 "    " $4 "    " $5 "    " $11 "    " $12}' tmp2 > cut_pole_figures/eta_$file
  awk -F" " '{print $1 "    " $2 "    " $3 "    " $4 "    " $5 "    " $15 "    " $16}' tmp2 > cut_pole_figures/corr_H_$file
  awk -F" " '{print $1 "    " $2 "    " $3 "    " $4 "    " $5 "    " $17 "    " $18}' tmp2 > cut_pole_figures/corr_eta_$file
  rm tmp tmp2
done
echo "done!"
