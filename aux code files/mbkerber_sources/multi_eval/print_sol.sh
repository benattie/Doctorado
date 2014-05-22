#!/bin/bash
filename=$1
test=‘grep "" $filename‘
if [[ $? -gt 1 ]];then
    echo "file $filename error"
    exit 1
fi

#first check if the fit did not crash in that case we just exit and leave a comment!
# alternative search for "ERROR:"
# in older files there was no "ERROR" so the file is useless if no residuals are in the solfile
if [ ! -z "‘grep "ERROR: the gnuplot solution file has ZERO size." $filename‘" ] \
    || [ -z "‘grep "residuals" $filename‘" ] \
    || [ ! -z "‘grep "ERROR: gnuplot calculated Singular matrix in Invert_RtR()." $filename‘" ] \
    || [ ! -z "‘grep "ERROR: the gnuplot command did not completed successfully" $filename‘" ]; then
    echo "#gnuplot crashed the data could not be fitted - try something else"
    exit 0
fi

#first check if the fit did not crash in that case we just exit and leave a comment!
if [ ! -z "‘grep "%" $filename | grep "e" | grep "e-1"‘" ] \
    || [ ! -z "‘grep "%" $filename |grep "e+"‘" ]; then
    echo "#value error too high or improper value"
    exit 0
fi
#now the search parameters for getting the lines with the results
#we arrange the search as follows: first the residuals as we use them to sort the results
#then m and sigma also for selection of results and the averages
#then the disloc parameters followed by epsilon and st_pr and finally the contrast stuff...
#so our search looks like:
#residuals m sigma d(special treatment needed) L0 rho Re M* epsilon st_pr q=a or a1-a2(hex) or a1-a5(ortho)

#search_array=("m=" "sigma=" "d=" "L0=" "q=" "rho=" "exp(-1/4)" "sqrt(rho)=" "epsilon=" "st_pr=" "residuals")
search_array=("residuals" "m=" "sigma=c_s" "d=" "L0=" "rho=" "Re^\*=" "M^\*=" "epsilon=" "st_pr=")
#echo ${search_array[@]}
#now select the contrast stuff
#test=‘grep "q=" $filename‘
#echo -$test-
if [ ! -z "‘grep "a =" $filename‘" ]; then
    search_array=( ${search_array[@]} "q=a_s" )
    # echo ${search_array[@]}
fi
if [ ! -z "‘grep "a2 =" $filename‘" ]; then
    search_array=( ${search_array[@]} "a1_scaled=" "a2_scaled=" )
    # echo ${search_array[@]}
fi
if [ ! -z "‘grep "a5 =" $filename‘" ]; then
    search_array=( ${search_array[@]} "a3_scaled=" "a4_scaled=" "a5_scaled=" )
    # echo ${search_array[@]}
fi
#chk for indidual contrast
if [ ! -z "‘grep "C_" $filename‘" ]; then
    no_C=‘grep "%" $filename |grep C_ | wc -l‘
    # echo "number of Ci: $no_C"
    for i in ‘seq -s " " 0 $(( $no_C - 1 ))‘; do
        search_array=( ${search_array[@]} "C_${i}" )
        #
        echo ${search_array[@]}
    done
fi
#chk for multiphase
if [ ! -z "‘grep "Phase" $filename‘" ]; then
    line=‘grep "Phase" $filename‘
    nophases=${line##*: }
    for p in ‘seq 1 $nophases‘;do
        search_array=( ${search_array[@]} "m_$p=" "sigma=c_$p" "d_$p=" "L0_$p=" "rho_$p=" "Re_$p^\*=" "M_$p^\*=" "epsilon_$p=" "st_pr_$p=")
        if [ ! -z "‘grep "q=a_$p" $filename‘" ]; then
            search_array=( ${search_array[@]} "q=a_$p" )
            # echo ${search_array[@]}
        fi
        #i did not see such a solfile therefore this is experimental guessing...
        #guess was good worked for polymers :D
        if [ ! -z "‘grep "a2_$p =" $filename‘" ]; then
            search_array=( ${search_array[@]} "a1_$p_scaled=" "a2_$p_scaled=" )
            # echo ${search_array[@]}
        fi
        if [ ! -z "‘grep "a5 =" $filename‘" ]; then
            search_array=( ${search_array[@]} "a3_$p_scaled=" "a4_$p_scaled=" "a5_$p_scaled=" )
            # echo ${search_array[@]}
        fi
    done
fi
#init the counter
i=0
#init the result with the filename
result="$filename"
while [ $i -lt ${#search_array[*]} ]; do
    # echo $i
    # read -p "press key"
    #this is the d= fix as it appears to often in the file
    if [ $i == 3 ]; then
        line=‘grep -A30 "The size parameters:" $filename | grep "${search_array[$i]}" |grep nm‘
        if [ $? -ne 0 ];then line="-1"; fi
    else
        line=‘grep -A30 "The size parameters:" $filename | grep "${search_array[$i]}"‘
        if [ $? -ne 0 ];then line="-1"; fi
    fi
    line=${line##*=}
    line=${line%%nm*}
    line=${line%%"(1/"*}
    line=${line##* : }
    line=${line%%+/-*}
    #debug
    #echo "$i: |$line|"
    #if [ -z $line ]; then line="-1";fi
    result+="\t$line"
    (( i++ ));
done
#take this to see what we did search for:
headline=${search_array[@]}
headline=${headline// /"\t"}
echo -e "#filename\t$headline"
echo -e $result
exit 0
