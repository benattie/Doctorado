1 #!/bin/bash
2
3 #FIXME we can use wc -w to count word entries in the index.dat file. thus we can check for nopeaks*3 words and if not => warning!
4
5 #make it multiphase, using an array with the params and make just a peaklist over this we loop!
6 #sample multiphase data:
7 #dat.ini:
8 #la=0.3
9 #bb=0.212132
10 #C0=0.3065
11 #wavelength=0.15406
12 #la_1=.288
13 #bb_1=0.203647
14 #C0_1=0.32
15 #
16 #.dat.fit.ini
17 #init_a=2.0
18 #init_b=3.0
19 #init_c=1.0
20 #init_d=80.0
21 #init_e=0.05
22 #init_epsilon=1.0
23 #init_a_1=1.0
24 #init_b_1=3.0
25 #init_c_1=1.0
26 #init_d_1=80.0
27 #init_e_1=0.05
28 #scale_a=1.0
29 #scale_b=1.0
30 #scale_c=1.0
31 #scale_d=1.0
32 #scale_e=1.0
33
34
35 #defaults
36
37 #important stuff first:
38 lambda="0.1540562" #nm Cu K_{\alpha1}
39 a_lattice="0.352394" #nm Ni
40 #peaklist to be taken as from m
41 peaks="[111;200;220;311;222;400]"
42
43 datarange=(35.2 115.6)
44 # background test needs the range where we determine the scatter and the height of the BG level
45 #this are the vector indices for the begin and end. keep it around 100 points as i had troubles with interp with less at inel data
46 bgvalrange=(10 200)
47
48 ch00="0.32"
49
50 #less common to be changed
51 peakrange="0.2"
52 peaksearchrange="0.5"
53 peakfunc="SplitPearson7"
54 peakfunc_bg=$peakfunc #alternative for bg fit
55 peaktune="3.0"
56
57 #fitted bg full all over the place
58 #bgpoints=(38.2 59.3 68.3 84.0 114.37)
59 #bgrange="1.0"
60
61 #bg_enevlope procedure:
62 #put out the bgpoints,
63 #get the height of the scattering by doing a test on thescattering before, maybe using the envelope function => max(abs(outer-inner))
64 #fit the bgfunc just from scratch; then
65 # A = (%bgfunc(x)-delta<y and y<%bgfunc(x)+delta)
66 #fit
67 # A = (y<%bgfunc(x)+delta*tuneparam)
68 # output the remaining stuff into .nopeaks (maybe fit again with peaks before)
69 # run doenvelope.m substract that from the profile, scaling missing lets do it as we did it here
70 #now we should have a perfectly cleaned profile!
71
72 bg_rm_method="envelope" #pp envelope constant
73 bgfunc="Polynomial4" #Constant Linear Cubic Polynomial4 Polynomial6
74 bg_envelope_tuneparam="1.8" #fudge factor for the export of the bg info.
75 bgfinal=1.0 #the final level of the BG we scale to that value
76 bgfinallevel=$bgfinal #we can alter the position of the actual BG as set...
77 bgfinalfit="n" # y/n || to fit the bg or not
78 scatter_scale="1.0" #scale the scatter
79 bg_envelope_2delrange=( 0,0 ) # the x pairs where the data needs to be deleted... if we have a peak from x1 to x2 and another one from x3 to x4 then
80 #=( x1,x2 x3,x4)
81 bg_envelope_fit="n" #we either fit the peaks or use fixed ranges bg_envelope_2delrange
82 bg_pp_range=( ${datarange[0]},${datarange[1]} ) #example: ( min1,max1 min2,max2 min3,max3 )
83
84 case $bgfunc in
85 Constant)
86 no_bg_par=1
87 ;;
88 Linear)
89 no_bg_par=2
90 ;;
91 Polynomial4)
92 no_bg_par=5
93 ;;
94 Polynomial5)
95 no_bg_par=6
96 ;;
97 Polynomial6)
98 no_bg_par=7
99 ;;
100 *)
101 echo -e "unkown BG Func: $bgfunc"
102 exit 1
103 ;;
104 esac
105
106 #FIXME still want to sort the final files like the peak-index.dat...
107 ####################################################
108 #parse the command line
109 ####################################################
110
111 # Note that we use ‘"$@"’ to let each command-line parameter expand to a
112 # separate word. The quotes around ‘$@’ are essential!
113 # We need TEMP as the ‘eval set --’ would nuke the return value of getopt.
114 TEMP=‘getopt -o c: --long config: \
115 -- "$@"‘
116
117 #echo "getopt says: $TEMP"
118
119 #check if we get answers
120 if [[ $? != 0 ]] ; then echo "Getopt error must exit..." >&2 ; exit 1 ; fi
121
122 #i dont know why we do that try to find out but it is essential!
123 #i think it sets the input string to the getopt modified thing
124 eval set -- "$TEMP"
125
126 while true ; do
127 case "$1" in
128 -c|--config)
129 echo "using config file \‘$2’" ;
130 configfile=$2
131 #should be caught by getopt
132 # if [[ -n $configfile ]];then
133 if [[ -e $configfile ]];then
134 source $configfile
135 else
136 echo -e "error config file \‘$configfile’ not found\nexiting..."
137 exit 1
138 fi
139 # fi
140 shift 2 ;;
141 --) shift ; break ;;
142 *) echo "Internal error (no agruments?)! $1" ; exit 1 ;;
143 esac
144 done
145 #The Remaining arguments:
146 for arg do
147 # echo remains: $arg
148 datafile=$arg
149 done
150 ####################################################
151 #we want to overload sample specific data - for example:
152 # the lattice parameter in the karlsruhe data shifts!
153 #to include this we load per default a datafile.local.ini
154 if [[ -e $datafile.local.ini ]];then
155 source $datafile.local.ini
156 fi
157 ### the datafile ###
158 echo "using data file: $datafile"
159 if [[ -e $datafile.orig ]];then
160 rm $datafile
161 else
162 mv $datafile $datafile.orig
163 if [ "$?" != "0" ];then
164 echo "error making backup file of $datfile"
165 exit 1;
166 fi
167 fi
168 fitykfile=$datafile.fit
169 peaksfile=$datafile.peaks
170 ###############
171 function calc2theta() {
172 calc2theta.sh $lambda $a_lattice $1 $2 $3
173 if [[ $? == 1 ]];then
174 exit 1
175 fi
176 }
177
178 ###############
179 function tofit() {
180 echo -e $@ >> $fitykfile
181 }
182 ###############
183 function minusplus() {
184 local result_array
185 result_array[1]=‘calc -p $1+$2‘
186 result_array[0]=‘calc -p $1-$2‘
187 echo "${result_array[@]}"
188 }
189
190 #####################################
191 #first we want to get our peaks
192 #clean the brackets
193 peaks=${peaks#*[}
194 #echo $peaks
195 peaks=${peaks%*]}
196 #echo $peaks
197 #declare your peak list array
198 declare -a peakarray
199 IFS=";" #set seperation char
200 peakarray=( $peaks )
201 IFS=" "
202
203 declare -a peakpos
204 declare -a h
205 declare -a k
206 declare -a l
207 j=0 #peakpos array index
208
209 for i in ${peakarray[@]};do
210 # for index in 0 1 2;do
211 # echo ${i:$index:1}
212 # done
213 h[$j]=${i:0:1} #cut the h from i, 0 start 1 char wide
214 k[$j]=${i:1:1}
215 l[$j]=${i:2:1}
216 twotheta=‘calc2theta ${h[$j]} ${k[$j]} ${l[$j]}‘
217 #check if we did got a good value if not we just ignore this hkl’s
218 if [[ -n $twotheta ]];then
219 echo $twotheta ${h[$j]}${k[$j]}${l[$j]}
220 peakpos[$j]=$twotheta
221 else
222 peakpos[$j]="-"
223 fi
224 let j++
225 done
226
227 #now we just need to generate our fityk file, then run this file!
228
229 ###########################################
230 #we will start with output of fityk file now
231 #FIFO mkfifo /tmp/foobar.fit
232 #FIFO fityk <>/tmp/foobar.fit
233
234 bgvalues=( ‘bgvalues.m $datafile.orig ${bgvalrange[0]} ${bgvalrange[1]}‘ )
235 if [ $? != 0 ];then
236 echo -e "error\t Determining the bgvalue data\n"
237 exit 1
238 fi
239 delta="${bgvalues[0]}*$scatter_scale" #the bg scatter
240 bglevel=${bgvalues[1]} #thebg level
241 echo "scatter=$delta"
242 echo "bg is at $bglevel"
243
244 #We make a function to write the string to the file and use tofit .... this way we can globally fix the -e stuff and so on ...
245
246 # init fit file
247 echo -e "">$fitykfile
248 #first load the file
249 tofit "@+ < ’${datafile}.orig’"
250 #next remove everything that we do not need
251
252 #delete to datarange maybe we want this in some other place sometime
253 #tofit "A = ( ${datarange[0]} < x < ${datarange[1]} ) " old variant kept once here
254 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} ) "
255 tofit "delete(not a)"
256
257
258 #here we make data manipultation we like
259 #as
260 #tofit "Y=y+2000"
261 if [[ -e ${data_manipulation_script} ]];then
262 source ${data_manipulation_script}
263 fi
264
265
266 ####################begin bg remove
267 if [[ ! -e ${datafile}.bgremoved ]];then
268 #begin fit all points
269 ##now a loop over the bgpoints pm bgrange
270 ##first disable all active
271 #tofit "A = not(x)"
272
273 ##next only mark the points around our bgpoints active
274 #for i in ${bgpoints[@]};do
275 # upperlower=( ‘minusplus $i $bgrange‘ )
276 # tofit "A = a or (${upperlower[0]} < x < ${upperlower[1]})"
277 #done
278 #now guess the function and fit
279 #tofit "%bg = guess $bgfunc"
280 #tofit "fit"
281
282 #end fit all points
283
284 #
285 ### ###
286 #
287
288 #begin envelope_bg_removal
289 if [[ $bg_rm_method == "envelope" ]];then
290 tofit "info @0 (x, y) > ’${datafile}’"
291 if [[ $bg_envelope_fit == "y" ]];then
292 #now guess the function and fit
293 tofit "%bg = guess $bgfunc"
294 tofit "fit"
295 #ok we should be around the real BG thus narrow the range
296 tofit "A = (%bg(x)-3.5*$delta<y and y<%bg(x)+3.5*$delta)"
297 tofit "fit"
298 #now add the peaks and refit
299 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
300 if [[ ${peakpos[$i]} != "-" ]]; then
301 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
302 tofit "A = a or (${upperlower[0]} < x and x < ${upperlower[1]})"
303 tofit "pause 2"
304 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
305 fi
306 done
307 tofit "A=(x)"
308 tofit "fit"
309
310 #we could make another run if we are still to high, keep an eye on this every bigger dataset!
311 #tofit "A = (%bg(x)-2*$delta<y and y<%bg(x)+2*$delta)"
312 #tofit "fit"
313
314 #as this used to be clean most of the time we just mark all below the BGfunc and export
315 tofit "A = (y<%bg(x)+$delta*$bg_envelope_tuneparam)"
316 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
317 if [[ ${peakpos[$i]} != "-" ]]; then
318 tofit "A = a and not ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peaktune*%${h[$i]}${k[$i]}${l[$i]}.FWHM < x and x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peaktune*%${h[$i]}${k[$i]}${l[$i]}.FWHM)"
319 fi
320 done
321 else
322 bg_envelope_range_string="A = (x)"
323 for rangeidx in ‘seq -s " " 0 $(( ${#bg_envelope_2delrange[@]}-1 ))‘;do
324 peakrange_min=${bg_envelope_2delrange[$rangeidx]%,*}
325 peakrange_max=${bg_envelope_2delrange[$rangeidx]#*,}
326 bg_envelope_range_string=$bg_envelope_range_string" and not ( $peakrange_min < x < $peakrange_max )"
327 done
328 tofit $bg_envelope_range_string
329 fi #fit bg range y/n
330
331 tofit "delete (not A)"
332 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
333 tofit "info @0 (x, y) > ’${datafile}.nopeaks’"
334
335
336 #run fityk with this
337 tofit "quit"
338 fityk $fitykfile
339 bgremove.m ${datafile}
340 if [ $? != 0 ];then
341 echo -e "error\t finding and removing the BG\n"
342 exit 1
343 fi
344 fi #end envelope_bg_removal
345
346 #
347 ### ###
348 #
349
350 if [[ $bg_rm_method == "pp" ]];then
351 #alternative just remove the fitted bg
352 #working neat: make this in piecewise polynomial manner
353
354 #FIXME open here make sure it works with one range
355 #
356 finaladd="@0="
357 for rangeidx in ‘seq -s" " 0 $(( ${#bg_pp_range[@]}-1 ))‘;do
358 bg_pp_min=${bg_pp_range[$rangeidx]%,*}
359 bg_pp_max=${bg_pp_range[$rangeidx]#*,}
360 tofit "A = ( ${bg_pp_min} < x and x < ${bg_pp_max} ) in @0"
361 tofit "@+ = @0"
362 tofit "delete (not a) in @$((${rangeidx}+1))"
363 #now add the peaks
364 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
365 if [[ ${peakpos[$i]} != "-" ]]; then
366 inrange=‘calc -p "$bg_pp_min<${peakpos[$i]} && ${peakpos[$i]}<$bg_pp_max"‘
367 if [[ $inrange == 1 ]];then
368 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
369 tofit "%${h[$i]}${k[$i]}${l[$i]}g$((${rangeidx}+1)) = guess $peakfunc_bg [ ${upperlower[0]} : ${upperlower[1]} ] in @$((${rangeidx}+1))"
370 fi
371 fi
372 done
373
374 #bad hack to get tr22 ag2 to work as there it seems is some bad peak
375 #we could do that if we do not reompute the peakspos all the time.
376 #so just make a file for that
377 #tofit "%temp$((${rangeidx}+1)) = guess Pearson7 [ 43.3 : 45.3 ] in @$((${rangeidx}+1))"
378
379 tofit "%bg$((${rangeidx}+1)) = guess $bgfunc in @$((${rangeidx}+1))"
380 tofit "fit in @$((${rangeidx}+1))"
381 tofit "plot"
382 tofit "pause 5"
383 tofit "sleep 5"
384 tofit "Y=y-%bg$((${rangeidx}+1))(x) in @$((${rangeidx}+1))"
385 finaladd=$finaladd"@$((${rangeidx}+1))+"
386 #this makes a + in the end so we need to remove this later
387 done
388 #take everything before the last + as the final add command
389 #=> @0 = @1+@2+...@i
390 tofit ${finaladd%*+}
391 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} ) in @0"
392 #could use calc_avg_x script for the next
393 tofit "with epsilon=1e-12 @0 = avg_same_x @0"
394 tofit "info @0 (x, y) > ’${datafile}.bgremoved’"
395 #run fityk with this
396 tofit "quit"
397 fityk $fitykfile
398 #exit
399 fi #bg_rm_method=="pp"
400
401 #
402 ### ###
403 #
404
405 if [[ $bg_rm_method == "constant" ]];then
406 tofit "Y=y-1"
407 tofit "info @0 (x, y) > ’${datafile}.bgremoved’"
408 #run fityk with this
409 tofit "quit"
410 fityk $fitykfile
411
412 fi #bg_rm_method=="constant"
413 fi #is there already a .bgremoved
414 ####################################end of bg
415
416 # reinit fit file
417 echo -e "">$fitykfile
418 #first load the file
419 tofit "@+ < ’${datafile}.bgremoved’"
420 tofit "Y=y/$bglevel+$bgfinal"
421 #tofit "Y=y+1"
422
423
424 #FIXME WANT A PARAM HERE
425 #tofit "plot [:] [:10000] "
426 #tofit "sleep 2"
427
428 #we could fix the params WORKING
429 #for i in ‘seq -s " " $no_bg_par‘;do
430 # tofit "\$_$i = {\$_${i}}"
431 #done
432
433
434 #strip the bg and normalize
435 #tofit "Y=(y-%bg(x))/$bglevel+1.1"
436 #tofit "delete %bg"
437 if [[ bgfinalfit == "y" ]];then
438 #tofit "%bg= Linear(intercept=~${bgfinal}, slope=~0)"
439 tofit "%bg= Constant(~${bgfinallevel})"
440 else
441 #tofit "%bg= Linear(intercept={$bgfinal}, slope={0})"
442 tofit "%bg= Constant({$bgfinallevel})"
443 fi
444 tofit "F+=%bg"
445
446 #first disable all active
447 #made problems so try without!
448 #tofit "A = not ( ${datarange[0]} < x and x < ${datarange[1]} )"
449 tofit "A = not ( x )"
450
451 for i in ‘seq -s " " 0 $(( ${#peakpos[@]}-1 ))‘;do
452 if [[ ${peakpos[$i]} != "-" ]]; then
453 upperlower=( ‘minusplus ${peakpos[$i]} $peaksearchrange‘ )
454 tofit "A = a or (${upperlower[0]} < x and x < ${upperlower[1]})"
455 tofit "%${h[$i]}${k[$i]}${l[$i]} = guess $peakfunc [ ${upperlower[0]} : ${upperlower[1]} ]"
456 tofit "A = a and not (${upperlower[0]} < x and x < ${upperlower[1]})"
457 #can do this in fityk:
458 #A= (%111.Center-0.3 < x and x < %111.Center+0.3)
459 #so
460 tofit "A = a or ( %${h[$i]}${k[$i]}${l[$i]}.Center - $peakrange < x and x < %${h[$i]}${k[$i]}${l[$i]}.Center + $peakrange)"
461 fi
462 done
463 #kit_pd 2tranche datarange
464 tofit "A = a or (14.11 < x and x < 15.36) or (58.12 < x and x < 58.81) or (25.1 < x and x < 25.78)"
465
466 tofit "fit" #first fit of localised data check and be aware that too little bg can make troubles!
467 tofit "info peaks > ’${peaksfile}.2del’"
468 tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
469 tofit "fit" #refit with the whole datarange. peak asymm can move our peakpos’s
470
471 #fityk $fitykfile
472
473 #FIXME PLOT PARAM
474 #tofit "plot"
475 #tofit "pause 5"
476
477 #output the actual bg data into two files in the start, end and inbetween
478 #0.9 fityk does not like the @0 so we put this in a variable for later use
479 in_dataset=""
480 #alternative: in_dataset="in @0 "
481 tofit "info min(x) ${in_dataset}> ’$datafile.bgx’"
482 tofit "info %bg(min(x)) ${in_dataset}> ’$datafile.bgy’"
483 tofit "info (max(x)-min(x))/2 ${in_dataset}>> ’$datafile.bgx’"
484 tofit "info %bg((max(x)-min(x))/2) ${in_dataset}>> ’$datafile.bgy’"
485 tofit "info max(x) ${in_dataset}>> ’$datafile.bgx’"
486 tofit "info %bg(max(x)) ${in_dataset}>> ’$datafile.bgy’"
487
488 tofit "info peaks > ’${peaksfile}’"
489 #now the data points
490 #tofit "A = ( ${datarange[0]} < x and x < ${datarange[1]} )"
491 tofit "info @0 (x, y) > ’${datafile}’"
492 tofit "quit"
493
494 fityk $fitykfile
495
496
497 #echo "writing all datafiles in 5 sec to quit press ctrl+c"
498 #read -t 5
499
500 #first clean the fityk output file from comments
501 remove_comments.sh $datafile
502
503 #now we take the .peaks file and make the peak-index.dat
504 if [ -e $datafile.peak-index.dat ];then
505 rm $datafile.peak-index.dat
506 fi
507 for i in ${peakarray[@]};do
508 line=‘grep %$i ${peaksfile}.2del | cut -d" " -f 5,6‘
509 if [[ -n $line ]]; then
510 echo $line $i >> $datafile.peak-index.dat
511 fi
512 done
513 rm ${peaksfile}.2del
514
515 #calculate the average lattice parameter from fitted data
516 calc_avg_lattice.sh -c $configfile $datafile.peak-index.dat
517 a_lattice=‘tail -n1 $datafile.peak-index.dat.lattice |cut -d " " -f2‘
518 echo $a_lattice
519
520 #now we output the bg-data
521 #echo -e "${datarange[0]}\t$bgvalue">$datafile.bg-spline.dat
522 #echo -e "‘calc -p "round(${datarange[0]}+${datarange[0]}/2,3)"‘\t$bgvalue">>$datafile.bg-spline.dat
523 #echo -e "${datarange[1]}\t$bgvalue">>$datafile.bg-spline.dat
524 paste ${datafile}.bgx ${datafile}.bgy>$datafile.bg-spline.dat
525
526 #now output the ini file
527 echo -e "la=$a_lattice">$datafile.dat.ini
528 echo -e "bb=‘calc -p "round($a_lattice/sqrt(2),2)"‘">>$datafile.dat.ini
529 echo -e "C0=$ch00">>$datafile.dat.ini
530 echo -e "wavelength=$lambda">>$datafile.dat.ini
531
532 #now output the ini file
533 echo -e "ENABLE_CONVOLUTION=n\nNO_SIZE_EFFECT=n\nSF_ELLIPSOIDAL=n\nUSE_SPLINE=y\nINDC=n\nUSE_STACKING=n\nUSE_WEIGHTS=y">$datafile.dat.q.ini
534 echo -e "minx=${datarange[0]}">>$datafile.dat.q.ini
535 echo -e "maxx=${datarange[1]}">>$datafile.dat.q.ini
536 echo -e "IF_TH_FT_limit=1e-7\nN1=1024\nN2=1024\nPROF_CUT=8.0\nFIT_LIMIT=1e-9\nFIT_MAXITER=10000\npeak_pos_int_fit=n">>$datafile.dat.q.ini
537
538
539 #cleanup:
540 for ext in fit bgx bgy; do
541 rm ${datafile}.$ext
542 done
543
544 #for all other stuff we need to rerun the fit, now the bg should be Linear and fixed then
545
546 #FIFO rm /tmp/foobar.fit
