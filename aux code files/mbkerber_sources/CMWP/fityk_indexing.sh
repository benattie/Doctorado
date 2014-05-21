#!/bin/bash
#here we prepare the index files. as we want to have multiphase in the data we can do this for all phases
#the result shall be individual files containing the hkl, peakpositions and lattice parameter
#defaults
#important stuff first:
lambda="0.1540562" #nm Cu K_{\alpha1}
a_lattice="0.352394" #nm Ni
#peaklist array the previous versions are inherent troublesome for minus, two digit numbers etc thus we make an array and the hkl seperated by "," this way we can easily take the stuff apart by changing the IFS
peakarray=( 1,1,1 2,0,0 2,2,0 3,1,1 2,2,2 4,0,0 )
#datarange=(35.2 115.6)
#less common to be changed
peakrange="0.2"
peaksearchrange="0.5"
peakfunc="SplitPearson7"
peakfunc_bg=$peakfunc #alternative for bg fit
peaktune="3.0"
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
fitykfile=$datafile.fit
peaksfile=$datafile.peaks
###############
function calc2theta() {
calc2theta.sh $lambda $a_lattice $1 $2 $3
if [[ $? == 1 ]];then
exit 1
fi
}
##############
function calclattice() {
#calclattice.sh lambda peakcenter_2theta h k l
calclattice.sh $lambda $1 $2 $3 $4
}
91
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

 #We make a function to write the string to the file and use tofit .... this way we can globally fix the -e stuff and so on ...

 # init fit file
 echo -e "">$fitykfile
 #first load the file
 tofit "@+ < ’${datafile}’"
 #next remove everything that we do not need

 #delete to datarange maybe we want this in some other place sometime
 #tofit "A = ( ${datarange[0]} < x < ${datarange[1]} ) "
 #tofit "delete(not a)"


 #here we make data manipultation we like
 #as
 #tofit "Y=y+2000"


 #FIXME WANT A PARAM HERE
 #tofit "plot [:] [:10000] "
 #tofit "sleep 2"

 #we could fix the params WORKING
 #for i in ‘seq -s " " $no_bg_par‘;do
 # tofit "\$_$i = {\$_${i}}"
 #done


 #first disable all active
 #made problems so try without!
 #tofit "A = not ( ${datarange[0]} < x < ${datarange[1]} )"
 #tofit "A = not ( x )"

 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
 if [[ ${peakpos[$i]} != "-" ]]; then
 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
 tofit "A = a or (${upperlower[0]} < x < ${upperlower[1]})"
 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
 tofit "A = a and not (${upperlower[0]} < x < ${upperlower[1]})"
 #can do this in fityk:
 #A= (%111.Center-0.3 < x < %111.Center+0.3)
 #so
 tofit "A = a or ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peakrange < x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peakrange)"
 fi
 done
 tofit "info peaks > ’${peaksfile}.2del’"
 tofit "A = ( ${datarange[0]} < x < ${datarange[1]} )"
 tofit "fit"

 #fityk $fitykfile

 #FIXME PLOT PARAM
 #tofit "plot"
 #tofit "pause 5"

 #tofit "info peaks > ’${peaksfile}’"
 tofit "quit"

 fityk $fitykfile


 #echo "writing all datafiles in 5 sec to quit press ctrl+c"
 #read -t 5

 #first clean the fityk output file from comments
 #remove_comments.sh $datafile

 #cleanup:
 #for ext in fit bgx bgy; do
 # rm ${datafile}.$ext
 #done

 #FIFO rm /tmp/foobar.fit
