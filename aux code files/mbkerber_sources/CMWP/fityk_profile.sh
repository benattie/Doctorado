#!/bin/bash

#FIXME we can use wc -w to count word entries in the index.dat file. thus we can check for nopeaks*3 words and if not => warning!

#make it multiphase, using an array with the params and make just a peaklist over this we loop!
#sample multiphase data:
#dat.ini:
#la=0.3
#bb=0.212132
#C0=0.3065
#wavelength=0.15406
#la_1=.288
#bb_1=0.203647
#C0_1=0.32
#
#.dat.fit.ini
#init_a=2.0
#init_b=3.0
#init_c=1.0
#init_d=80.0
#init_e=0.05
#init_epsilon=1.0
#init_a_1=1.0
#init_b_1=3.0
#init_c_1=1.0
#init_d_1=80.0
#init_e_1=0.05
#scale_a=1.0
#scale_b=1.0
#scale_c=1.0
#scale_d=1.0
#scale_e=1.0


#defaults

#important stuff first:
lambda="0.1540562" #nm Cu K_{\alpha1}
a_lattice="0.352394" #nm Ni
#peaklist to be taken as from m
peaks="[111;200;220;311;222;400]"

datarange=(35.2 115.6)
# background test needs the range where we determine the scatter and the height of the BG level
#this are the vector indices for the begin and end. keep it around 100 points as i had troubles with interp with less at inel data
bgvalrange=(10 200)

ch00="0.32"

#less common to be changed
peakrange="0.2"
peaksearchrange="0.5"
peakfunc="SplitPearson7"
peakfunc_bg=$peakfunc #alternative for bg fit
peaktune="3.0"

#fitted bg full all over the place
#bgpoints=(38.2 59.3 68.3 84.0 114.37)
#bgrange="1.0"

#bg_enevlope procedure:
#put out the bgpoints,
#get the height of the scattering by doing a test on thescattering before, maybe using the envelope function => max(abs(outer-inner))
#fit the bgfunc just from scratch; then
# A = (%bgfunc(x)-delta<y and y<%bgfunc(x)+delta)
#fit
# A = (y<%bgfunc(x)+delta*tuneparam)
# output the remaining stuff into .nopeaks (maybe fit again with peaks before)
# run doenvelope.m substract that from the profile, scaling missing lets do it as we did it here
#now we should have a perfectly cleaned profile!

bg_rm_method="envelope" #pp envelope constant
bgfunc="Polynomial4" #Constant Linear Cubic Polynomial4 Polynomial6
bg_envelope_tuneparam="1.8" #fudge factor for the export of the bg info.
bgfinal=1.0 #the final level of the BG we scale to that value
bgfinallevel=$bgfinal #we can alter the position of the actual BG as set...
bgfinalfit="n" # y/n || to fit the bg or not
scatter_scale="1.0" #scale the scatter
bg_envelope_2delrange=( 0,0 ) # the x pairs where the data needs to be deleted... if we have a peak from x1 to x2 and another one from x3 to x4 then
#=( x1,x2 x3,x4)
bg_envelope_fit="n" #we either fit the peaks or use fixed ranges bg_envelope_2delrange
bg_pp_range=( ${datarange[0]},${datarange[1]} ) #example: ( min1,max1 min2,max2 min3,max3 )

case $bgfunc in
Constant)
no_bg_par=1
;;
Linear)
no_bg_par=2
;;
Polynomial4)
no_bg_par=5
;;
Polynomial5)
no_bg_par=6
;;
Polynomial6)
no_bg_par=7
;;
 *)
 echo -e "unkown BG Func: $bgfunc"
 exit 1
 ;;
 esac

 #FIXME still want to sort the final files like the peak-index.dat...
 ####################################################
 #parse the command line
 ####################################################

 # Note that we use ‘"$@"’ to let each command-line parameter expand to a
 # separate word. The quotes around ‘$@’ are essential!
 # We need TEMP as the ‘eval set --’ would nuke the return value of getopt.
 TEMP=‘getopt -o c: --long config: \
 -- "$@"‘

 #echo "getopt says: $TEMP"

 #check if we get answers
 if [[ $? != 0 ]] ; then echo "Getopt error must exit..." >&2 ; exit 1 ; fi

 #i dont know why we do that try to find out but it is essential!
 #i think it sets the input string to the getopt modified thing
 eval set -- "$TEMP"

 while true ; do
 case "$1" in
 -c|--config)
 echo "using config file \‘$2’" ;
 configfile=$2
 #should be caught by getopt
 # if [[ -n $configfile ]];then
 if [[ -e $configfile ]];then
 source $configfile
 else
 echo -e "error config file \‘$configfile’ not found\nexiting..."
 exit 1
 fi
 # fi
 shift 2 ;;
 --) shift ; break ;;
 *) echo "Internal error (no agruments?)! $1" ; exit 1 ;;
 esac
 done
 #The Remaining arguments:
 for arg do
 # echo remains: $arg
 datafile=$arg
 done
 ####################################################
 #we want to overload sample specific data - for example:
 # the lattice parameter in the karlsruhe data shifts!
 #to include this we load per default a datafile.local.ini
 if [[ -e $datafile.local.ini ]];then
 source $datafile.local.ini
 fi
 ### the datafile ###
 echo "using data file: $datafile"
 if [[ -e $datafile.orig ]];then
 rm $datafile
 else
 mv $datafile $datafile.orig
 if [ "$?" != "0" ];then
 echo "error making backup file of $datfile"
 exit 1;
 fi
 fi
 fitykfile=$datafile.fit
 peaksfile=$datafile.peaks
 ###############
 function calc2theta() {
 calc2theta.sh $lambda $a_lattice $1 $2 $3
 if [[ $? == 1 ]];then
 exit 1
 fi
 }

 ###############
 function tofit() {
 echo -e $@ >> $fitykfile
 }
 ###############
 function minusplus() {
 local result_array
 result_array[1]=‘calc -p $1+$2‘
 result_array[0]=‘calc -p $1-$2‘
 echo "${result_array[@]}"
 }

 #####################################
 #first we want to get our peaks
 #clean the brackets
 peaks=${peaks#*[}
 #echo $peaks
 peaks=${peaks%*]}
 #echo $peaks
 #declare your peak list array
 declare -a peakarray
 IFS=";" #set seperation char
 peakarray=( $peaks )
 IFS=" "

 declare -a peakpos
 declare -a h
 declare -a k
 declare -a l
 j=0 #peakpos array index

 for i in ${peakarray[@]};do
 # for index in 0 1 2;do
 # echo ${i:$index:1}
 # done
 h[$j]=${i:0:1} #cut the h from i, 0 start 1 char wide
 k[$j]=${i:1:1}
 l[$j]=${i:2:1}
 twotheta=‘calc2theta ${h[$j]} ${k[$j]} ${l[$j]}‘
 #check if we did got a good value if not we just ignore this hkl’s
 if [[ -n $twotheta ]];then
 echo $twotheta ${h[$j]}${k[$j]}${l[$j]}
 peakpos[$j]=$twotheta
 else
 peakpos[$j]="-"
 fi
 let j++
 done

 #now we just need to generate our fityk file, then run this file!

 ###########################################
 #we will start with output of fityk file now
 #FIFO mkfifo /tmp/foobar.fit
 #FIFO fityk <>/tmp/foobar.fit

 bgvalues=( ‘bgvalues.m $datafile.orig ${bgvalrange[0]} ${bgvalrange[1]}‘ )
 if [ $? != 0 ];then
 echo -e "error\t Determining the bgvalue data\n"
 exit 1
 fi
 delta="${bgvalues[0]}*$scatter_scale" #the bg scatter
 bglevel=${bgvalues[1]} #thebg level
 echo "scatter=$delta"
 echo "bg is at $bglevel"

 #We make a function to write the string to the file and use tofit .... this way we can globally fix the -e stuff and so on ...

 # init fit file
 echo -e "">$fitykfile
 #first load the file
 tofit "@+ < ’${datafile}.orig’"
 #next remove everything that we do not need

 #delete to datarange maybe we want this in some other place sometime
 #tofit "A = ( ${datarange[0]} < x < ${datarange[1]} ) " old variant kept once here
 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} ) "
 tofit "delete(not a)"


 #here we make data manipultation we like
 #as
 #tofit "Y=y+2000"
 if [[ -e ${data_manipulation_script} ]];then
 source ${data_manipulation_script}
 fi


 ####################begin bg remove
 if [[ ! -e ${datafile}.bgremoved ]];then
 #begin fit all points
 ##now a loop over the bgpoints pm bgrange
 ##first disable all active
 #tofit "A = not(x)"

 ##next only mark the points around our bgpoints active
 #for i in ${bgpoints[@]};do
 # upperlower=( ‘minusplus $i $bgrange‘ )
 # tofit "A = a or (${upperlower[0]} < x < ${upperlower[1]})"
 #done
 #now guess the function and fit
 #tofit "%bg = guess $bgfunc"
 #tofit "fit"

 #end fit all points

 #
 ### ###
 #

 #begin envelope_bg_removal
 if [[ $bg_rm_method == "envelope" ]];then
 tofit "info @0 (x, y) > ’${datafile}’"
 if [[ $bg_envelope_fit == "y" ]];then
 #now guess the function and fit
 tofit "%bg = guess $bgfunc"
 tofit "fit"
 #ok we should be around the real BG thus narrow the range
 tofit "A = (%bg(x)-3.5*$delta<y and y<%bg(x)+3.5*$delta)"
 tofit "fit"
 #now add the peaks and refit
 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
 if [[ ${peakpos[$i]} != "-" ]]; then
 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
 tofit "A = a or (${upperlower[0]} < x and x < ${upperlower[1]})"
 tofit "pause 2"
 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
 fi
 done
 tofit "A=(x)"
 tofit "fit"

 #we could make another run if we are still to high, keep an eye on this every bigger dataset!
 #tofit "A = (%bg(x)-2*$delta<y and y<%bg(x)+2*$delta)"
 #tofit "fit"

 #as this used to be clean most of the time we just mark all below the BGfunc and export
 tofit "A = (y<%bg(x)+$delta*$bg_envelope_tuneparam)"
 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
 if [[ ${peakpos[$i]} != "-" ]]; then
 tofit "A = a and not ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peaktune*%${h[$i]}${k[$i]}${l[$i]}.FWHM < x and x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peaktune*%${h[$i]}${k[$i]}${l[$i]}.FWHM)"
 fi
 done
 else
 bg_envelope_range_string="A = (x)"
 for rangeidx in ‘seq -s " " 0 $(( ${#bg_envelope_2delrange[@]}-1 ))‘;do
 peakrange_min=${bg_envelope_2delrange[$rangeidx]%,*}
 peakrange_max=${bg_envelope_2delrange[$rangeidx]#*,}
 bg_envelope_range_string=$bg_envelope_range_string" and not ( $peakrange_min < x < $peakrange_max )"
 done
 tofit $bg_envelope_range_string
 fi #fit bg range y/n

 tofit "delete (not A)"
 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
 tofit "info @0 (x, y) > ’${datafile}.nopeaks’"


 #run fityk with this
 tofit "quit"
 fityk $fitykfile
 bgremove.m ${datafile}
 if [ $? != 0 ];then
 echo -e "error\t finding and removing the BG\n"
 exit 1
 fi
 fi #end envelope_bg_removal

 #
 ### ###
 #

 if [[ $bg_rm_method == "pp" ]];then
 #alternative just remove the fitted bg
 #working neat: make this in piecewise polynomial manner

 #FIXME open here make sure it works with one range
 #
 finaladd="@0="
 for rangeidx in ‘seq -s" " 0 $(( ${#bg_pp_range[@]}-1 ))‘;do
 bg_pp_min=${bg_pp_range[$rangeidx]%,*}
 bg_pp_max=${bg_pp_range[$rangeidx]#*,}
 tofit "A = ( ${bg_pp_min} < x and x < ${bg_pp_max} ) in @0"
 tofit "@+ = @0"
 tofit "delete (not a) in @$((${rangeidx}+1))"
 #now add the peaks
 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
 if [[ ${peakpos[$i]} != "-" ]]; then
 inrange=‘calc -p "$bg_pp_min<${peakpos[$i]} && ${peakpos[$i]}<$bg_pp_max"‘
 if [[ $inrange == 1 ]];then
 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
 tofit "%${h[$i]}${k[$i]}${l[$i]}g$((${rangeidx}+1)) = guess $peakfunc_bg [ ${upperlower[0]} : ${upperlower[1]} ] in @$((${rangeidx}+1))"
 fi
 fi
 done

 #bad hack to get tr22 ag2 to work as there it seems is some bad peak
 #we could do that if we do not reompute the peakspos all the time.
 #so just make a file for that
 #tofit "%temp$((${rangeidx}+1)) = guess Pearson7 [ 43.3 : 45.3 ] in @$((${rangeidx}+1))"

 tofit "%bg$((${rangeidx}+1)) = guess $bgfunc in @$((${rangeidx}+1))"
 tofit "fit in @$((${rangeidx}+1))"
 tofit "plot"
 tofit "pause 5"
 tofit "sleep 5"
 tofit "Y=y-%bg$((${rangeidx}+1))(x) in @$((${rangeidx}+1))"
 finaladd=$finaladd"@$((${rangeidx}+1))+"
 #this makes a + in the end so we need to remove this later
 done
 #take everything before the last + as the final add command
 #=> @0 = @1+@2+...@i
 tofit ${finaladd%*+}
 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} ) in @0"
 #could use calc_avg_x script for the next
 tofit "with epsilon=1e-12 @0 = avg_same_x @0"
 tofit "info @0 (x, y) > ’${datafile}.bgremoved’"
 #run fityk with this
 tofit "quit"
 fityk $fitykfile
 #exit
 fi #bg_rm_method=="pp"

 #
 ### ###
 #

 if [[ $bg_rm_method == "constant" ]];then
 tofit "Y=y-1"
 tofit "info @0 (x, y) > ’${datafile}.bgremoved’"
 #run fityk with this
 tofit "quit"
 fityk $fitykfile

 fi #bg_rm_method=="constant"
 fi #is there already a .bgremoved
 ####################################end of bg

 # reinit fit file
 echo -e "">$fitykfile
 #first load the file
 tofit "@+ < ’${datafile}.bgremoved’"
 tofit "Y=y/$bglevel+$bgfinal"
 #tofit "Y=y+1"


 #FIXME WANT A PARAM HERE
 #tofit "plot [:] [:10000] "
 #tofit "sleep 2"

 #we could fix the params WORKING
 #for i in ‘seq -s " " $no_bg_par‘;do
 # tofit "\$_$i = {\$_${i}}"
 #done


 #strip the bg and normalize
 #tofit "Y=(y-%bg(x))/$bglevel+1.1"
 #tofit "delete %bg"
 if [[ bgfinalfit == "y" ]];then
 #tofit "%bg= Linear(intercept=~${bgfinal}, slope=~0)"
 tofit "%bg= Constant(~${bgfinallevel})"
 else
 #tofit "%bg= Linear(intercept={$bgfinal}, slope={0})"
 tofit "%bg= Constant({$bgfinallevel})"
 fi
 tofit "F+=%bg"

 #first disable all active
 #made problems so try without!
 #tofit "A = not ( ${datarange[0]} < x and x < ${datarange[1]} )"
 tofit "A = not ( x )"

 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
 if [[ ${peakpos[$i]} != "-" ]]; then
 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
 tofit "A = a or (${upperlower[0]} < x and x < ${upperlower[1]})"
 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
 tofit "A = a and not (${upperlower[0]} < x and x < ${upperlower[1]})"
 #can do this in fityk:
 #A= (%111.Center-0.3 < x and x < %111.Center+0.3)
 #so
 tofit "A = a or ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peakrange < x and x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peakrange)"
 fi
 done
 #kit_pd 2tranche datarange
 tofit "A = a or (14.11 < x and x < 15.36) or (58.12 < x and x < 58.81) or (25.1 < x and x < 25.78)"

 tofit "fit" #first fit of localised data check and be aware that too little bg can make troubles!
 tofit "info peaks > ’${peaksfile}.2del’"
 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
 tofit "fit" #refit with the whole datarange. peak asymm can move our peakpos’s

 #fityk $fitykfile

 #FIXME PLOT PARAM
 #tofit "plot"
 #tofit "pause 5"

 #output the actual bg data into two files in the start, end and inbetween
 #0.9 fityk does not like the @0 so we put this in a variable for later use
 in_dataset=""
 #alternative: in_dataset="in @0 "
 tofit "info min(x) ${in_dataset}> ’$datafile.bgx’"
 tofit "info %bg(min(x)) ${in_dataset}> ’$datafile.bgy’"
 tofit "info (max(x)-min(x))/2 ${in_dataset}>> ’$datafile.bgx’"
 tofit "info %bg((max(x)-min(x))/2) ${in_dataset}>> ’$datafile.bgy’"
 tofit "info max(x) ${in_dataset}>> ’$datafile.bgx’"
 tofit "info %bg(max(x)) ${in_dataset}>> ’$datafile.bgy’"

 tofit "info peaks > ’${peaksfile}’"
 #now the data points
 #tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
 tofit "info @0 (x, y) > ’${datafile}’"
 tofit "quit"

 fityk $fitykfile


 #echo "writing all datafiles in 5 sec to quit press ctrl+c"
 #read -t 5

 #first clean the fityk output file from comments
 remove_comments.sh $datafile

 #now we take the .peaks file and make the peak-index.dat
 if [ -e $datafile.peak-index.dat ];then
 rm $datafile.peak-index.dat
 fi
 for i in ${peakarray[@]};do
 line=‘grep %$i ${peaksfile}.2del | cut -d" " -f 5,6‘
 if [[ -n $line ]]; then
 echo $line $i >> $datafile.peak-index.dat
 fi
 done
 rm ${peaksfile}.2del

 #calculate the average lattice parameter from fitted data
 calc_avg_lattice.sh -c $configfile $datafile.peak-index.dat
 a_lattice=‘tail -n1 $datafile.peak-index.dat.lattice |cut -d " " -f2‘
 echo $a_lattice

 #now we output the bg-data
 #echo -e "${datarange[0]}\t$bgvalue">$datafile.bg-spline.dat
 #echo -e "‘calc -p "round(${datarange[0]}+${datarange[0]}/2,3)"‘\t$bgvalue">>$datafile.bg-spline.dat
 #echo -e "${datarange[1]}\t$bgvalue">>$datafile.bg-spline.dat
 paste ${datafile}.bgx ${datafile}.bgy>$datafile.bg-spline.dat

 #now output the ini file
 echo -e "la=$a_lattice">$datafile.dat.ini
 echo -e "bb=‘calc -p "round($a_lattice/sqrt(2),2)"‘">>$datafile.dat.ini
 echo -e "C0=$ch00">>$datafile.dat.ini
 echo -e "wavelength=$lambda">>$datafile.dat.ini

 #now output the ini file
 echo -e "ENABLE_CONVOLUTION=n\nNO_SIZE_EFFECT=n\nSF_ELLIPSOIDAL=n\nUSE_SPLINE=y\nINDC=n\nUSE_STACKING=n\nUSE_WEIGHTS=y">$datafile.dat.q.ini
 echo -e "minx=${datarange[0]}">>$datafile.dat.q.ini
 echo -e "maxx=${datarange[1]}">>$datafile.dat.q.ini
 echo -e "IF_TH_FT_limit=1e-7\nN1=1024\nN2=1024\nPROF_CUT=8.0\nFIT_LIMIT=1e-9\nFIT_MAXITER=10000\npeak_pos_int_fit=n">>$datafile.dat.q.ini


 #cleanup:
 for ext in fit bgx bgy; do
 rm ${datafile}.$ext
 done

 #for all other stuff we need to rerun the fit, now the bg should be Linear and fixed then

 #FIFO rm /tmp/foobar.fit
