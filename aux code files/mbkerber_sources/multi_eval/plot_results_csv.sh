#!/bin/bash
#avg(x)=mean
#mean=1; fit [0:3] [*:*] avg(x) "datafile[0]" using :$datacolumn via mean
#set arrow 1 from graph 0, first mean to graph 1, first mean nohead
#FIXME
#the latex export does not properly rotate the figs and the escapes of the names with \ do not work accurately and we
should have all labels as variables. bw/.. should be reused maybe two commandline params...
10
11 #btw i would prefer to output the plot commands into separate files because i think about writing a script that will plot
two of them later?! or think about it how to best do this.
12 #plot multiple: need to check if these are readable files though
13 #the plot description for multiple data files is identical. maybe make an array
14 #alternative diff the datafiles and label it after the diff!
15 #FIXME make a loop over the remaining argument and make it datafiles only if they exist as files!
16
17 re="" #replot command empty for first plot then set to "re" and empty afterwards
18
19 #run $0 csv output
20
21 ########################################
22 ##initital data #
23 ########################################
24
25 #datafile=$1
26 configfile="/home/localkerber/svn/kerber/diss/data/kit/kit_pd.csv.plot.ini"
27
28 output=png
29
30 samplename=""
31 shortname=""
32 xaxislabel="Engineering strain"
33
34 declare -a datasetnames #array of datasetnames
35
36 ##########################################################
37 #define the number of contrast fit parameters a
38 #1 for cub (=q)
39 #2 for hex
40 #5 for orthoromb
41 #we will grep for that after the getopt maybe...
42 #variables=( ‘grep "#measno" test.csv‘ )
43 #no_contrast=$(( (${variables[@]}-31)/3 ))
44 no_contrast=1
45 ##########################################################
46
47 #xrange="1:11"
48 xrange=":"
49 #yranges
50 resrange=":"
51 drange=":"
52 Lrange=":"
53 mrange=":"
54 sigmarange=":"
55 rhorange=":"
56 Mrange=":"
57 epsrange=":"
58 stprrange=":"
59 Rrange=":"
60 bgrange=":"
61 asymmrange=":"
62 latticerange=":"
63 contrastrange[1]=":"
64 contrastrange[2]=":"
65 contrastrange[3]=":"
66 contrastrange[4]=":"
67 contrastrange[5]=":"
68 strainrange=":"
69 xmaprange=":"
70
71 #select what to do (y/n)
72 do_errorbar=n
73 do_epsilon=n
74 do_stpr=n
75 do_bg_peak=n
76 do_bg=n
do_asymm=n
do_lattice=n
do_strain=n
do_xmap=n
do_fits=n
do_trendline=n
do_title=n
do_average=n #the average of the first data points of the first data file
trendline="sbezier" #unique | frequency | csplines | acsplines | bezier | sbezier
do_trend_title="no"
# "" for trend title in legend
# "no" for no trend title
#keep the gnuplot commandfile
keepgnuplot=y
#linewidth
lw=1
#line type "lt 1" for full lines or "" for gnuplot selection
lt=""
#font
font=Roman
fontsize=20
#...
color=y
####################################################
#parse the command line
####################################################
# Note that we use ‘"$@"’ to let each command-line parameter expand to a
# separate word. The quotes around ‘$@’ are essential!
# We need TEMP as the ‘eval set --’ would nuke the return value of getopt.
TEMP=‘getopt -o flepsbrxtn:o:N:c:h --long fits,trendline,errorbar,epsilon,stpr,bg,bg_peak,asymm,lattice,strain,xmap,title,
name:,output:,outname:,config:,help \
-- "$@"‘
#options
# f=>fits,l=>trendline,e=>errorbar,p=>epsilon,s=>stpr,b=>bg,r=>strain,x=xmap,t=title
# n=>name,o=>output (format),N=>output (name)
# c=>config
#help
#echo "getopt says: $TEMP"
#check if we get answers
if [[ $? != 0 ]] ; then echo "Getopt error must exit..." >&2 ; exit 1 ; fi
#i dont know why we do that try to find out but it is essential!
#i think it sets the input string to the getopt modified thing
eval set -- "$TEMP"
tmpfile=/tmp/plot_‘date +%s%N‘.tmp
while true ; do
case "$1" in
-f|--fits)
echo "echo -e \"will fit regression\"" >>$tmpfile
echo "do_fits=y">>$tmpfile
shift ;;
-l|--trendline)
echo "echo -e \"will plot trendline\"" >>$tmpfile
echo "do_trendline=y">>$tmpfile
shift ;;
-e|--errorbar)
echo "echo -e \"will plot error bars\"" >>$tmpfile
echo "do_errorbar=y">>$tmpfile
shift ;;
-p|--epsilon)
echo "echo -e \"will plot epsilon\"" >>$tmpfile
echo "do_epsilon=y">>$tmpfile
shift ;;
-s|--stpr)
echo "echo -e \"will plot stacking fault data\"" >>$tmpfile
echo "do_stpr=y">>$tmpfile
shift ;;
-b|--bg_peak)
echo "echo -e \"will plot BG-PEAK data\"" >>$tmpfile
echo "do_bg_peak=y">>$tmpfile
shift ;;
--bg)
echo "echo -e \"will plot BG data\"" >>$tmpfile
echo "do_bg=y">>$tmpfile
shift ;;
--asymm)
echo "echo -e \"will plot asymmetry data\"" >>$tmpfile
echo "do_asymm=y">>$tmpfile
shift ;;
--lattice)
echo "echo -e \"will plot lattice data\"" >>$tmpfile
echo "do_lattice=y">>$tmpfile
shift ;;
-r|--strain)
echo "echo -e \"will plot stress strain data\"" >>$tmpfile
echo "do_strain=y">>$tmpfile
shift ;;
-x|--xmap)
echo "echo -e \"will plot x-axis mapping data\"" >>$tmpfile
echo "do_xmap=y">>$tmpfile
shift ;;
178
-t|--title)
179
echo "echo -e \"will plot plot-titles\"" >>$tmpfile
180
echo "do_title=y">>$tmpfile
181
shift ;;
182
-n|--name)
183
echo "echo -e \"using sample name ’$2’\"" >>$tmpfile
184
echo "samplename=$2">>$tmpfile
185
shift 2 ;;
186
-o|--output)
187
echo "echo -e \"using $2 output format\"" >>$tmpfile
188
echo "output=$2">>$tmpfile
189
shift 2 ;;
190
-N|--outname)
191
echo "echo -e \"using output name $2\"" >>$tmpfile
192
echo "filename=$2">>$tmpfile
193
shift 2 ;;
194
-c|--config)
195
echo -e "using config file ’$2’" ;
196
configfile=$2
197 #should be caught by getopt
198 #
if [[ -n $configfile ]];then
199
if [[ -e $configfile ]];then
200
source $configfile
201
echo -e "$configfile loaded"
202
else
203
echo -e "error config file ’$configfile’ not found\nexiting..."
204
exit 1
205
fi
206 #
fi
207
shift 2 ;;
208
-h|--help)
209
echo -e "\nusage: ‘basename $0‘ <options> datafile(s)"
210
echo -e "\noptions:"
211
echo -e "-f | --fits \t do a linear regression of the (first) data"
212
echo -e "-f | --fits \t plot a trendline"
213
echo -e "-e | --errorbar \t plot errorbars"
214
echo -e "-p | --epsilon \t plot the epsilon results"
215
echo -e "-s | --stpr \t plot stacking fault results"
216
echo -e "-b | --bg_peak \t plot background-peak ratio eval data"
217
echo -e "
--bg \t plot background eval data"
218
echo -e "
--asymm \t plot asymmetry eval data"
219
echo -e "
--lattice \t plot lattice param eval data"
220
echo -e "-r | --strain \tplot .strain data"
221
echo -e "-x | --xmap \tplot the xmap"
222
echo -e "-t | --title \t(plot titles for each curve)"
223
echo -e "-n | --name <Name of the plot>"
224
echo -e "-o | --output <output format: psbw|pscolor|latexbw|latex|pdf|pdfbw|png>"
225
echo -e "-N | --outname <basename of output files>"
226
echo -e "-c | --config <config file>"
227
echo -e "-h | --help"
228
echo -e "This script can plot multiple datafiles from a series eval. Dataset should be identical layout but anything
might work with errors"
229
echo -e "Basically you can have the .csv to be plotted and a config file supplied via -c. if it exists datafile.plot.
ini is loaded for settings"
230
echo -e "to get a ini file get the variables in the script and set them as you like."
231
echo -e "settings get applied as: config file, overloaded by local .plot.ini then commandline"
232
echo -e "to have names in multiple data set be sure to have a shortname=dataset name in the csv.plot.ini’s or a full
datasetnames=(...) array"
233
shift;;
234
--) shift ; break ;;
235
*) echo "Internal error (no agruments?)! $1" ; exit 1 ;;
236
esac
237 done
238 #The Remaining arguments:
239 #old
240 #
datafile=( $* )
241
242 declare -a datafile
243
244 for arg do
245 # echo remains: $arg
246
if [[ -f $arg ]];then
247
datafile=( "${datafile[@]}" "$arg" )
248
else
249
echo -e "\t\E[31;47mnot using non-file: \033[0m$arg"
250
fi
251 done
252 if [[ -z ${datafile[@]} ]];then
253
echo -e "\n\tNothing to do!\n\n"
254
exit 1
255 fi
256 #echo ${datafile[@]}
257
258
259 ####################################################
260
261
262 ###################START OF PROG##########################
263
264 #we will grep for that after the getopt maybe...
265 variables=( ‘grep "#measno" ${datafile[0]}‘ )
266 no_contrast=$(( (${#variables[@]}-31)/3 ))
267
268 #we like the order: use config,plot.ini,commandline
269 #only if we have multiple data set we prefer ini over .plot.ini
270 #thus load plot.ini, config was sourced already we need to re-source it...
271
272 #to include this we load per default a datafile.plot.ini
273 if [[ -e ${datafile[0]}.plot.ini ]];then
echo -e "load local settings"
source ${datafile[0]}.plot.ini
fi
#now for the data set names we have two options... if the corresponding plot.ini exists we could use that one
#FIXME try to improve that
if [[ ${#datafile[@]} -gt 1 ]];then
if [[ -n $configfile ]];then
source $configfile
#FIXME should not be here i think now...
fi
if [[ ${#datasetnames[@]} != ${#datafile[@]} ]];then
for i in ${datafile[@]};do
if [[ -f $i.plot.ini ]];then
temp=‘grep "shortname=" $i.plot.ini‘
temp=${temp#shortname=*}
temp=${temp//\"/\’} #prevent the use of " in gnuplot commands as this will close the string. this way it just works =)
datasetnames=( "${datasetnames[@]}" "$temp")
else
datasetnames=( "${datasetnames[@]}" "‘basename $i .csv‘" )
fi
done
fi
else
datasetnames[0]=""
fi
#echo ${datasetnames[@]}
if [[ -e $tmpfile ]];then
echo -e "load override comandline"
source $tmpfile
rm $tmpfile
fi
#now if the filename for the output was set in some ini use that if not we take a default
if [[ -z $filename ]];then
filename=‘basename ${datafile[0]} .csv‘
fi
tempfile=$filename.tmp.gnu
#ditto for sample name
#default sample name is the name of the csv
if [[ -z $samplename ]];then
samplename=$filename
fi
#now start the rest
case $output in
psbw)
terminal="postscript eps enhanced monochrome lw 2 dl 4 font \"$font,$fontsize\""; extension=eps
makepdf=n
color=n
residuals="Residuals"
rho="{/Symbol r}"
rholabel="$rho [10^{15}m^{-2}]"
L0="L_0"
M="M"
epsilon="{/Symbol e}"
stpr="P_t_w_i_n"
sigma="{/Symbol s}"
sigmalabel="$sigma [1]"
asymmlabel="Difference in HWHM [{/Symbol \260}]"
;;
pscolor)
terminal="postscript eps enhanced color lw 2 font \"$font,$fontsize\""; extension=eps
makepdf=n
residuals="Residuals"
rho="{/Symbol r}"
rholabel="$rho [10^{15}m^{-2}]"
L0="L_0"
M="M"
epsilon="{/Symbol e}"
stpr="P_t_w_i_n"
sigma="{/Symbol s}"
sigmalabel="$sigma [1]"
asymmlabel="Difference in HWHM [{/Symbol \260}]"
;;
latexbw)
terminal="latex"; extension=tex
makepdf=n
color=n
residuals="Residuals"
rho="\$\\rho\$"
rholabel="\\$rho \$[10^{15}\\mathrm m^{-2}]\$"
L0="\$L_0\$"
M="\$M\$"
epsilon="\$\\epsilon\$"
stpr="P_{stacking}"
sigma="\$\\sigma\$"
sigmalabel="\\$sigma \$[1]\$"
asymmlabel="Difference in HWHM [\degree]"
;;
latex)
terminal="latex"; extension=tex
makepdf=n
residuals="Residuals"
rho="\$\\rho\$"
rholabel="\\$rho \$[10^{15}\\mathrm m^{-2}]\$"
L0="\$L_0\$"
M="\$M\$"
epsilon="\$\\epsilon\$"
stpr="P_{stacking}"
sigma="\$\\sigma\$"
sigmalabel="\\$sigma \$[1]\$"
asymmlabel="Difference in HWHM [\degree]"
;;
pdf)
terminal="postscript eps enhanced color lw 2 font \"$font,$fontsize\""; extension=eps
makepdf=y
residuals="Residuals"
rho="{/Symbol r}"
rholabel="$rho [10^{15}m^{-2}]"
L0="L_0"
M="M"
epsilon="{/Symbol e}"
stpr="P_s_t_a_c_k_i_n_g"
sigma="{/Symbol s}"
sigmalabel="$sigma [1]"
asymmlabel="Difference in HWHM [{/Symbol \260}]"
;;
pdfbw)
terminal="postscript eps enhanced monochrome lw 2 dl 4 font \"$font,$fontsize\""; extension=eps
makepdf=y
color=n
residuals="Residuals"
rho="{/Symbol r}"
rholabel="$rho [10^{15}m^{-2}]"
L0="L_0"
M="M"
epsilon="{/Symbol e}"
stpr="P_s_t_a_c_k_i_n_g"
sigma="{/Symbol s}"
sigmalabel="$sigma [1]"
asymmlabel="Difference in HWHM [{/Symbol \260}]"
;;
*)
# png)
terminal="png"; extension=png
makepdf=n
residuals="Residuals"
rho="rho"
rholabel="$rho [10^(15)m^(-2)]"
L0="L0"
M="M"
epsilon="epsilon"
stpr="P_stacking"
sigma="sigma"
sigmalabel="$sigma [1]"
asymmlabel="Difference in HWHM [degree]"
;;
esac
if [ $do_errorbar == y ];then
errorbar="with errorbars"
else
errorbar=""
fi
echo -e "set size ratio 0.7">$tempfile
echo -e "f(x)=a*x+b">>$tempfile
echo -e "a=0">>$tempfile
echo -e "b=0">>$tempfile
#as per latest gnuplot we need to define a palette before we can do some colorstuff
#this defines the palette:
echo -e "set cbrange [0:100]">>$tempfile
echo -e "set style data linespoints">>$tempfile
echo -e "set size 1.0,1.0">>$tempfile
echo -e "set terminal $terminal">>$tempfile
echo -e "set key left">>$tempfile
#for i in 1 2 3 4 5 6 7 8 9 10;do
#echo -e "set style line $i lw 1">>$tempfile;
#done
#1=+ 2=x 3=*, then nice:
#empty|full
#4|5 square
#6|7 circle
#8|9 triangle up
#10|11 triangle down
#12|13 diamond
if [ $color == n ];then
echo -e "set style line 1 lw $lw pt 4 lt 1">>$tempfile;
echo -e "set style line 2 lw $lw pt 6 lt 2">>$tempfile;
echo -e "set style line 3 lw $lw pt 5 lt 4">>$tempfile;
echo -e "set style line 4 lw $lw pt 7 lt 1">>$tempfile;
echo -e "set style line 5 lw $lw pt 8 lt 2">>$tempfile;
echo -e "set style line 6 lw $lw pt 133 lt 4">>$tempfile;
echo -e "set style line 100 lw $lw pt 9 lt 10">>$tempfile; #the fit line
echo -e "set style line 200 lw $lw pt 4 lt 3">>$tempfile;
echo -e "set style line 300 lw $lw pt 6 lt 5">>$tempfile;
echo -e "set style line 400 lw $lw pt 5 lt 6">>$tempfile;
echo -e "set style line 500 lw $lw pt 7 lt 7">>$tempfile;
echo -e "set style line 600 lw $lw pt 10 lt 9">>$tempfile;
echo -e "set style line 700 lw $lw pt 133 lt 8">>$tempfile;
else
#black #000000
#grey #3d3d3d
#green #008000
#ligth green #5ebb5e
#blue dark #003099
#blue ligth #4040ff
#red #b00000
#mild red #d03030
#violet #800080
#light #d55fd5
#orange #ff6600
#ligth or #ffb400
echo -e "set style line 1 lw $lw $lt pt 4 lc rgb \"#b00000\" ">>$tempfile;
echo -e "set style line 2 lw $lw $lt pt 8 lc rgb \"#008000\" ">>$tempfile;
echo -e "set style line 3 lw $lw $lt pt 5 lc rgb \"#ff3f3f\" ">>$tempfile;
echo -e "set style line 4 lw $lw $lt pt 9 lc rgb \"#5ebb5e\" ">>$tempfile;
echo -e "set style line 5 lw $lw $lt pt 6 lc rgb \"#003099\" ">>$tempfile;
echo -e "set style line 6 lw $lw $lt pt 12 lc rgb \"#800080\" ">>$tempfile;
echo -e "set style line 7 lw $lw $lt pt 7 lc rgb \"#4040ff\" ">>$tempfile;
echo -e "set style line 8 lw $lw $lt pt 13 lc rgb \"#df5fd5\" ">>$tempfile;
echo -e "set style line 9 lw $lw $lt pt 10 lc rgb \"#ff6600\" ">>$tempfile;
echo -e "set style line 10 lw $lw $lt pt 11 lc rgb \"#ffb400\" ">>$tempfile;
echo -e "set style line 100 lw $lw $lt pt 0 lc rgb \"#707070\" ">>$tempfile; #the fit line
echo -e "set style line 200 lw $lw $lt pt 0 lc rgb \"#105810\" ">>$tempfile;
echo -e "set style line 300 lw $lw $lt pt 0 lc rgb \"#2020ee\" ">>$tempfile;
echo -e "set style line 400 lw $lw $lt pt 0 lc rgb \"#f05050\" ">>$tempfile;
echo -e "set style line 500 lw $lw $lt pt 0 lc rgb \"#4e7ae9\" ">>$tempfile;
echo -e "set style line 600 lw $lw $lt pt 0 lc rgb \"#f19b49\" ">>$tempfile;
echo -e "set style line 700 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 800 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 900 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 1000 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 1100 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 1300 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
echo -e "set style line 1500 lw $lw $lt pt 0 lc rgb \"#000000\" ">>$tempfile;
fi
#from gnuplot 4.2 manual:
#
set style line <index> {{linetype | lt}
#
{{linecolor | lc}
#
{{linewidth | lw}
#
{{pointtype | pt}
#
{{pointsize | ps}
#
{palette}
# plot sin(x) lt rgb "#FF00FF"
# explicit
#pt
#4 square
#5 filled square
#6 circle
#7 filled sircle
<line_type> | <colorspec>}
<colorspec>}
<line_width>}
<point_type>}
<point_size>}
RGB triple in hexadecimal
echo -e "set xlabel \"$xaxislabel\"">>$tempfile
##########################################################
#residuals
datacolumn1=2
#
datacolumn2=0
yrange=$resrange
if [ $do_title == y ];then
echo -e "set title \"Averaged Residuals $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$residuals [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_res.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$residuals ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$residuals ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$residuals trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $residuals ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
#echo -e "set xrange [*:*]">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_res.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
##########################################################
#m
datacolumn1=5
#sigma
datacolumn2=8
#m
yrange=$mrange
#sigma
y2range=$sigmarange
if [ $do_title == y ];then
echo -e "set title \"Log-normal Size-distro parameters $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set y2range [$y2range]">>$tempfile
echo -e "set ytics nomirror">>$tempfile
echo -e "set y2tics">>$tempfile
echo -e "set ylabel \"m [nm]\"">>$tempfile
echo -e "set y2label \"$sigmalabel\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_m_sigma.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) title \"m ${datasetnames[$fileno]}\" $errorbar axis x1y1
ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2:$((datacolumn2+1)) title \"$sigma ${datasetnames[$fileno]}\" $errorbar axis
x1y2 ls $((2*$fileno+2))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"m ${datasetnames[$fileno]}\" axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 title \"$sigma ${datasetnames[$fileno]}\" axis x1y2 ls $((2*$fileno+2))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"m trend ${datasetnames[$fileno]}\" axis x1y1 \
smooth $trendline ls $((2*$fileno+1))00,\
\"${datafile[$fileno]}\" using 1:$datacolumn2 ${do_trend_title}title \"$sigma trend ${datasetnames[$fileno]}\" axis
x1y2 \
smooth $trendline ls $((2*$fileno+2))00">>$tempfile
fi
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression m ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn2 via mean">>$tempfile
echo -e "set arrow 2 from graph 0, second mean to graph 1, second mean nohead lt 7 lc rgb \"#a0a0a0\"">>$tempfile
fi
done
re=""
#reset the plotfile and output all
echo -e "set output \"${filename[0]}_m_sigma.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
echo -e "set y2range [*:*]">>$tempfile
echo -e "unset y2tics">>$tempfile
echo -e "unset y2label">>$tempfile
echo -e "set ytics mirror">>$tempfile
if [ $do_average == y ];then
echo -e "unset arrow 2">>$tempfile
fi
##########################################################
#d
datacolumn1=11
#L0
datacolumn2=14
yrange=$drange
if [ $do_title == y ];then
echo -e "set title \"CSD-size $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"CSD-size [nm]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_csd.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"d ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 title \"$L0 ${datasetnames[$fileno]}\" ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2:$((datacolumn2+1)) notitle $errorbar ls $((2*$fileno+2))\
" >>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"d ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 title \"$L0 ${datasetnames[$fileno]}\" ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle ls $((2*$fileno+2))\
" >>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"d trend ${datasetnames[$fileno]}\" \
smooth $trendline ls $((2*$fileno+1))00,\
\"${datafile[$fileno]}\" using 1:$datacolumn2 ${do_trend_title}title \"$L0 trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+2))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression d ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn2 via mean">>$tempfile
echo -e "set arrow 2 from graph 0, first mean to graph 1, first mean nohead lt 7 lc rgb \"#a0a0a0\"">>$tempfile
fi
re=""
#reset the plotfile and output all
echo -e "set output \"${filename[0]}_csd.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
if [ $do_average == y ];then
echo -e "unset arrow 2">>$tempfile
fi
##########################################################
#rho
datacolumn1=17
#M
datacolumn2=23
#rho
yrange=$rhorange
#M
y2range=$Mrange
if [ $do_title == y ];then
echo -e "set title \"Dislocation density and arrangement $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set y2range [$y2range]">>$tempfile
echo -e "set ytics nomirror">>$tempfile
echo -e "set y2tics">>$tempfile
echo -e "set ylabel \"$rholabel\"">>$tempfile
echo -e "set y2label \"M [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_M_rho.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) title \"$rho ${datasetnames[$fileno]}\" $errorbar axis
x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2:$((datacolumn2+1)) title \"M ${datasetnames[$fileno]}\" $errorbar axis x1y2
ls $((2*$fileno+2))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$rho ${datasetnames[$fileno]}\" axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 title \"M ${datasetnames[$fileno]}\" axis x1y2 ls $((2*$fileno+2))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$rho trend ${datasetnames[$fileno]}\" axis x1y1\
smooth $trendline ls $((2*$fileno+1))00,\
\"${datafile[$fileno]}\" using 1:$datacolumn2 ${do_trend_title}title \"M trend ${datasetnames[$fileno]}\" axis x1y2\
smooth $trendline ls $((2*$fileno+2))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $rho ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn2 via mean">>$tempfile
echo -e "set arrow 2 from graph 0, second mean to graph 1, second mean nohead lt 7 lc rgb \"#a0a0a0\"">>$tempfile
fi
re=""
#reset the plotfile and output all
echo -e "set output \"${filename[0]}_M_rho.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
echo -e "set y2range [*:*]">>$tempfile
echo -e "unset y2tics">>$tempfile
echo -e "unset y2label">>$tempfile
echo -e "set ytics mirror">>$tempfile
if [ $do_average == y ];then
echo -e "unset arrow 2">>$tempfile
fi
########single M rho plots#############
########### rho ################
#rho
yrange=$rhorange
#M
y2range=$Mrange
if [ $do_title == y ];then
echo -e "set title \"Dislocation density $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$rholabel\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_rho.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) title \"$rho ${datasetnames[$fileno]}\" $errorbar axis
x1y1 ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$rho ${datasetnames[$fileno]}\" axis x1y1 ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$rho trend ${datasetnames[$fileno]}\" axis x1y1\
smooth $trendline ls $((2*$fileno+1))00
">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $rho ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
re=""
#reset the plotfile and output all
echo -e "set output \"${filename[0]}_rho.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
#############
M
#rho
yrange=$rhorange
#M
y2range=$Mrange
################
if [ $do_title == y ];then
echo -e "set title \"Dislocation arrangement $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$y2range]">>$tempfile
echo -e "set ylabel \"M [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn2 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_M.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2:$((datacolumn2+1)) title \"M ${datasetnames[$fileno]}\" $errorbar axis x1y1
ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn2 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn2 title \"M ${datasetnames[$fileno]}\" axis x1y1 ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn2 ${do_trend_title}title \"M trend ${datasetnames[$fileno]}\" axis x1y1\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression M ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn2 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 7 lc rgb \"#a0a0a0\"">>$tempfile
fi
re=""
#reset the plotfile and output all
echo -e "set output \"${filename[0]}_M.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
##########################################################
if [ $do_epsilon == y ]; then
#eps
datacolumn1=26
#
datacolumn2=0
yrange=$epsrange
if [ $do_title == y ];then
echo -e "set title \"Grain ellipticity $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$epsilon [%]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_eps.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$epsilon ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$epsilon ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$epsilon trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $epsilon ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_eps.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
##########################################################
if [ $do_stpr == y ]; then
#st_pr
datacolumn1=29
#
datacolumn2=0
yrange=$stprrange
if [ $do_title == y ];then
echo -e "set title \"Planar fault probability $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$stpr [%]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_sf.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$stpr ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$stpr ${datasetnames[$fileno]}\" ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$stpr trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $stpr ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_sf.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
##########################################################
#contrast ai
##########################################################
i=1
contraststartcolumn=32
while [[ i -le $no_contrast ]];do
if [ $no_contrast == "1" ];then
aname="q";
else
aname="a$i"
fi
#q
datacolumn1=$(( contraststartcolumn+3*(i-1) ))
#
datacolumn2=0
yrange=${contrastrange[$i]}
if [ $do_title == y ];then
echo -e "set title \"Average contrast fit-parameter $aname $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$aname [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’${datafile[0]}’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_$aname.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$aname ${datasetnames[$fileno]}\" ls $((2*$fileno+1)), \
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1)) \
" >>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$aname ${datasetnames[$fileno]}\" ls $((2*$fileno+1)), \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle ls $((2*$fileno+1)) \
" >>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$aname trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done #files
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression $aname ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_$aname.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
((i++))
done #contrast
##########################################################
if [ $do_bg_peak == y ]; then
#bg
#datacolumn1=$((contraststartcolumn+$no_contrast*3))
datacolumn1=2
yrange=$Rrange
Rdata=${datafile[0]}
if [ $do_title == y ];then
echo -e "set title \"Background to Peak ratio $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set y2range [$y2range]">>$tempfile
echo -e "set ylabel \"R [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$Rdata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_R.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
Rdata=${datafile[$fileno]}.bg_peak
if [ $do_errorbar == y ];then
echo -e "${re}plot \"$Rdata\" using 1:$datacolumn1 title \"R ${datasetnames[$fileno]}\" ls $((2*$fileno+1))">>$tempfile
else
echo -e "${re}plot \"$Rdata\" using 1:$datacolumn1 title \"R ${datasetnames[$fileno]}\" ls $((2*$fileno+1))">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${Rdata}\" using 1:$datacolumn1 ${do_trend_title}title \"R trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression R ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}.bg_peak\" using :$datacolumn1 via mean">>$tempfile
#FIXME that is not robust switch to variable here
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_R.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
#####bg and rho
#first data as above so we only need the second here
#rho
datacolumn1=17
yrange=$rhorange
#R
# datacolumn2=$((contraststartcolumn+$no_contrast*3))
datacolumn2=2
y2range=$Rrange
Rdata=${datafile[0]}.bg_peak
if [ $do_title == y ];then
echo -e "set title \"BG to Peak ratio and disloc. dens. $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set y2range [$y2range]">>$tempfile
echo -e "set ytics nomirror">>$tempfile
echo -e "set y2tics">>$tempfile
echo -e "set ylabel \"$rholabel\"">>$tempfile
echo -e "set y2label \"R [1]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$Rdata’ using 1:$datacolumn2 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_R_rho.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
Rdata=${datafile[$fileno]}.bg_peak
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1:$((datacolumn+1)) title \"$rho ${datasetnames[$fileno]}\" $errorbar axis
x1y1 ls $((2*$fileno+1)),\
\"$Rdata\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"$Rdata\" using 1:$datacolumn2:$((datacolumn2+1)) title \"R ${datasetnames[$fileno]}\" $errorbar axis x1y2 ls $((2*
$fileno+2))\
">>$tempfile
else
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 notitle axis x1y1 ls $((2*$fileno+1)),\
\"${datafile[$fileno]}\" using 1:$datacolumn1 title \"$rho ${datasetnames[$fileno]}\" axis x1y1 ls $((2*$fileno+1)),\
\"$Rdata\" using 1:$datacolumn2 notitle axis x1y2 ls $((2*$fileno+2)),\
\"$Rdata\" using 1:$datacolumn2 title \"R ${datasetnames[$fileno]}\" axis x1y2 ls $((2*$fileno+2))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${datafile[$fileno]}\" using 1:$datacolumn1 ${do_trend_title}title \"$rho trend ${datasetnames[$fileno]}\" axis x1y1\
smooth $trendline ls $((2*$fileno+1))00,\
\"${Rdata}\" using 1:$datacolumn2 ${do_trend_title}title \"R trend ${datasetnames[$fileno]}\" axis x1y2\
smooth $trendline ls $((2*$fileno+2))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression R ${datasetnames[0]}\" axis x1y2 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${Rdata}\" using :$datacolumn2 via mean">>$tempfile
echo -e "set arrow 2 from graph 0, second mean to graph 1, second mean nohead lt 7 lc rgb \"#a0a0a0\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_R_rho.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
echo -e "set y2range [*:*]">>$tempfile
echo -e "unset y2tics">>$tempfile
echo -e "unset y2label">>$tempfile
echo -e "set ytics mirror">>$tempfile
if [ $do_average == y ];then
echo -e "unset arrow 2">>$tempfile
fi
fi #end do_bg_peak
#####bg
##########################################################
if [ $do_bg == y ]; then
#bg
bgdata=${datafile[0]}.bg
datacolumn1=2
yrange=$bgrange
if [ $do_title == y ];then
echo -e "set title \"background $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"Background []\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$bgdata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_bg.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
bgdata=${datafile[$fileno]}.bg
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"$bgdata\" using 1:$datacolumn1 title \"BG ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$bgdata\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"$bgdata\" using 1:$datacolumn1 title \"BG ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$bgdata\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${bgdata}\" using 1:$datacolumn1 ${do_trend_title}title \"BG trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression BG ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}.bg\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_bg.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
#end do bg
#####asymmm
##########################################################
if [ $do_asymm == y ]; then
#asymm
asymmdata=${datafile[0]}.asymm
datacolumn1=2
yrange=$asymmrange
if [ $do_title == y ];then
echo -e "set title \"Peak asymmetry $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"$asymmlabel\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$asymmdata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_asymm.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
asymmdata=${datafile[$fileno]}.asymm
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"$asymmdata\" using 1:$datacolumn1 title \"Asymm. ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$asymmdata\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"$asymmdata\" using 1:$datacolumn1 title \"Asymm. ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$asymmdata\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${asymmdata}\" using 1:$datacolumn1 ${do_trend_title}title \"Asymm. trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression asymm. ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}.asymm\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_asymm.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
#end do asymm
#####lattice
##########################################################
if [ $do_lattice == y ]; then
#lattice
latticedata=${datafile[0]}.lattice
datacolumn1=2
yrange=$latticerange
if [ $do_title == y ];then
echo -e "set title \"Lattice parameter a $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"lattice parameter a [nm]\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$latticedata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_lattice.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
latticedata=${datafile[$fileno]}.lattice
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"$latticedata\" using 1:$datacolumn1 title \"a ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$latticedata\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"$latticedata\" using 1:$datacolumn1 title \"a ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$latticedata\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${latticedata}\" using 1:$datacolumn1 ${do_trend_title}title \"a trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression lattice ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}.lattice\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_lattice.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
#end do lattice
##########################################################
if [ $do_strain == y ]; then
#strain
straindata=${datafile[0]}.strain
datacolumn1=2
yrange=$strainrange
if [ $do_title == y ];then
echo -e "set title \"Strain $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"Strain []\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$straindata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_strain.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
straindata=${datafile[$fileno]}.strain
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"$straindata\" using 1:$datacolumn1 title \"strain ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$straindata\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"$straindata\" using 1:$datacolumn1 title \"strain ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$straindata\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${straindata}\" using 1:$datacolumn1 ${do_trend_title}title \"strain trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression strain ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}.strain\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_strain.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
#end strain
##########################################################
if [ $do_xmap == y ]; then
#xmapping
xmapdata=${datafile[0]}.xmap.xy
datacolumn1=2
yrange=$xmaprange
if [ $do_title == y ];then
echo -e "set title \"X-Axis mapping $samplename\"">>$tempfile
fi
echo -e "set xrange [$xrange]">>$tempfile
echo -e "set yrange [$yrange]">>$tempfile
echo -e "set ylabel \"Strain\"">>$tempfile
if [ $do_fits == y ];then
echo -e "fit f(x) ’$xmapdata’ using 1:$datacolumn1 via a, b">>$tempfile
fi
echo -e "set output \"${filename[0]}_xmap.${extension}\"">>$tempfile
re=""
for fileno in ‘seq 0 $((${#datafile[@]}-1))‘ ;do
xmapdata=${datafile[$fileno]}.xmap.xy
if [ $do_errorbar == y ];then
echo -e "${re}plot \
\"$xmapdata\" using 1:$datacolumn1 title \"xmapping ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$xmapdata\" using 1:$datacolumn1:$((datacolumn1+1)) notitle $errorbar ls $((2*$fileno+1))\
">>$tempfile
else
echo -e "${re}plot \
\"$xmapdata\" using 1:$datacolumn1 title \"xmapping ${datasetnames[$fileno]}\" ls $((2*$fileno+1))\
, \"$xmapdata\" using 1:$datacolumn1 notitle ls $((2*$fileno+1))\
">>$tempfile
fi
re="re"
if [ $do_trendline == y ];then
echo -e "${re}plot \
\"${xmapdata}\" using 1:$datacolumn1 ${do_trend_title}title \"xmapping trend ${datasetnames[$fileno]}\"\
smooth $trendline ls $((2*$fileno+1))00">>$tempfile
fi
done
if [ $do_fits == y ];then
echo -e "replot f(x) title \"Regression xmap ${datasetnames[0]}\" axis x1y1 ls $((2*$fileno+1))00">>$tempfile
fi
if [ $do_average == y ];then
echo -e "avg(x)=mean">>$tempfile
echo -e "mean=1; fit [0:3] [*:*] avg(x) \"${datafile[0]}\" using :$datacolumn1 via mean">>$tempfile
echo -e "set arrow 1 from graph 0, first mean to graph 1, first mean nohead lt 2 lc rgb \"#909090\"">>$tempfile
fi
#reset the plotfile and output all
re=""
echo -e "set output \"${filename[0]}_xmap.${extension}\"">>$tempfile
echo -e "replot">>$tempfile
echo -e "set yrange [*:*]">>$tempfile
fi
##########################################################
gnuplot $tempfile &>/dev/null
if [[ $keepgnuplot != ’y’ ]];then
rm $tempfile
fi
if [ $makepdf == y ];then
for i in *.eps;do
#
ps2pdf $i;
epstopdf $i;
rm $i;
done;
fi