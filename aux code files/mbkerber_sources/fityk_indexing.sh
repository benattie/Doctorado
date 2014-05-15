1 #!/bin/bash
2
3 #here we prepare the index files. as we want to have multiphase in the data we can do this for all phases
4 #the result shall be individual files containing the hkl, peakpositions and lattice parameter
5
6 #defaults
7
8 #important stuff first:
9 lambda="0.1540562" #nm Cu K_{\alpha1}
10 a_lattice="0.352394" #nm Ni
11 #peaklist array the previous versions are inherent troublesome for minus, two digit numbers etc thus we make an array and the hkl seperated by "," this way we can easily take the stuff apart by changing the IFS
12 peakarray=( 1,1,1 2,0,0 2,2,0 3,1,1 2,2,2 4,0,0 )
13
14 #datarange=(35.2 115.6)
15
16 #less common to be changed
17 peakrange="0.2"
18 peaksearchrange="0.5"
19 peakfunc="SplitPearson7"
20 peakfunc_bg=$peakfunc #alternative for bg fit
21 peaktune="3.0"
22
23
24 #FIXME still want to sort the final files like the peak-index.dat...
25 ####################################################
26 #parse the command line
27 ####################################################
28
29 # Note that we use ‘"$@"’ to let each command-line parameter expand to a
30 # separate word. The quotes around ‘$@’ are essential!
31 # We need TEMP as the ‘eval set --’ would nuke the return value of getopt.
32 TEMP=‘getopt -o c: --long config: \
33 -- "$@"‘
34
35 #echo "getopt says: $TEMP"
36
37 #check if we get answers
38 if [[ $? != 0 ]] ; then echo "Getopt error must exit..." >&2 ; exit 1 ; fi
39
40 #i dont know why we do that try to find out but it is essential!
41 #i think it sets the input string to the getopt modified thing
42 eval set -- "$TEMP"
43
44 while true ; do
45 case "$1" in
46 -c|--config)
47 echo "using config file \‘$2’" ;
48 configfile=$2
49 #should be caught by getopt
50 # if [[ -n $configfile ]];then
51 if [[ -e $configfile ]];then
52 source $configfile
53 else
54 echo -e "error config file \‘$configfile’ not found\nexiting..."
55 exit 1
56 fi
57 # fi
58 shift 2 ;;
59 --) shift ; break ;;
60 *) echo "Internal error (no agruments?)! $1" ; exit 1 ;;
61 esac
62 done
63 #The Remaining arguments:
64 for arg do
65 # echo remains: $arg
66 datafile=$arg
67 done
68 ####################################################
69 #we want to overload sample specific data - for example:
70 # the lattice parameter in the karlsruhe data shifts!
71 #to include this we load per default a datafile.local.ini
72 if [[ -e $datafile.local.ini ]];then
73 source $datafile.local.ini
74 fi
75 ### the datafile ###
76 echo "using data file: $datafile"
77 fitykfile=$datafile.fit
78 peaksfile=$datafile.peaks
79 ###############
80 function calc2theta() {
81 calc2theta.sh $lambda $a_lattice $1 $2 $3
82 if [[ $? == 1 ]];then
83 exit 1
84 fi
85 }
86 ##############
87 function calclattice() {
88 #calclattice.sh lambda peakcenter_2theta h k l
89 calclattice.sh $lambda $1 $2 $3 $4
90 }
91
92 ###############
93 function tofit() {
94 echo -e $@ >> $fitykfile
95 }
96 ###############
97 function minusplus() {
98 local result_array
99 result_array[1]=‘calc -p $1+$2‘
100 result_array[0]=‘calc -p $1-$2‘
101 echo "${result_array[@]}"
102 }
103
104 #####################################
105 #first we want to get our peaks
106 #clean the brackets
107 peaks=${peaks#*[}
108 #echo $peaks
109 peaks=${peaks%*]}
110 #echo $peaks
111 #declare your peak list array
112 declare -a peakarray
113 IFS=";" #set seperation char
114 peakarray=( $peaks )
115 IFS=" "
116
117 declare -a peakpos
118 declare -a h
119 declare -a k
120 declare -a l
121 j=0 #peakpos array index
122
123 for i in ${peakarray[@]};do
124 # for index in 0 1 2;do
125 # echo ${i:$index:1}
126 # done
127 h[$j]=${i:0:1} #cut the h from i, 0 start 1 char wide
128 k[$j]=${i:1:1}
129 l[$j]=${i:2:1}
130 twotheta=‘calc2theta ${h[$j]} ${k[$j]} ${l[$j]}‘
131 #check if we did got a good value if not we just ignore this hkl’s
132 if [[ -n $twotheta ]];then
133 echo $twotheta ${h[$j]}${k[$j]}${l[$j]}
134 peakpos[$j]=$twotheta
135 else
136 peakpos[$j]="-"
137 fi
138 let j++
139 done
140
141 #now we just need to generate our fityk file, then run this file!
142
143 ###########################################
144 #we will start with output of fityk file now
145 #FIFO mkfifo /tmp/foobar.fit
146 #FIFO fityk <>/tmp/foobar.fit
147
148 #We make a function to write the string to the file and use tofit .... this way we can globally fix the -e stuff and so on ...
149
150 # init fit file
151 echo -e "">$fitykfile
152 #first load the file
153 tofit "@+ < ’${datafile}’"
154 #next remove everything that we do not need
155
156 #delete to datarange maybe we want this in some other place sometime
157 #tofit "A = ( ${datarange[0]} < x < ${datarange[1]} ) "
158 #tofit "delete(not a)"
159
160
161 #here we make data manipultation we like
162 #as
163 #tofit "Y=y+2000"
164
165
166 #FIXME WANT A PARAM HERE
167 #tofit "plot [:] [:10000] "
168 #tofit "sleep 2"
169
170 #we could fix the params WORKING
171 #for i in ‘seq -s " " $no_bg_par‘;do
172 # tofit "\$_$i = {\$_${i}}"
173 #done
174
175
176 #first disable all active
177 #made problems so try without!
178 #tofit "A = not ( ${datarange[0]} < x < ${datarange[1]} )"
179 #tofit "A = not ( x )"
180
181 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
182 if [[ ${peakpos[$i]} != "-" ]]; then
183 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
184 tofit "A = a or (${upperlower[0]} < x < ${upperlower[1]})"
185 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
186 tofit "A = a and not (${upperlower[0]} < x < ${upperlower[1]})"
187 #can do this in fityk:
188 #A= (%111.Center-0.3 < x < %111.Center+0.3)
189 #so
190 tofit "A = a or ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peakrange < x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peakrange)"
191 fi
192 done
193 tofit "info peaks > ’${peaksfile}.2del’"
194 tofit "A = ( ${datarange[0]} < x < ${datarange[1]} )"
195 tofit "fit"
196
197 #fityk $fitykfile
198
199 #FIXME PLOT PARAM
200 #tofit "plot"
201 #tofit "pause 5"
202
203 #tofit "info peaks > ’${peaksfile}’"
204 tofit "quit"
205
206 fityk $fitykfile
207
208
209 #echo "writing all datafiles in 5 sec to quit press ctrl+c"
210 #read -t 5
211
212 #first clean the fityk output file from comments
213 #remove_comments.sh $datafile
214
215 #cleanup:
216 #for ext in fit bgx bgy; do
217 # rm ${datafile}.$ext
218 #done
219
220 #FIFO rm /tmp/foobar.fit
