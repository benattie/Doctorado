1 #!/bin/bash
2
3 datafile=$1
4 configfile=$2
5 fitykfile=$datafile.fit
6 #the version to use asymp7, twopeaks or all
7 version=all
8 range=( 28.9 30.6 ) #the range to investigate
9
10 bgfunc=Linear #Cubic Linear with Linear most reliable
11
12 if [[ -e $configfile ]];then
13 source $configfile
14 fi
15
16 ###############
17 function tofit() {
18 echo -e $@ >> $fitykfile
19 }
20 ##############
21 #as from fityk_profile
22 bgvalrange=(10 200)
23 scatter_scale=2
24 bgvalues=( ‘bgvalues.m $datafile ${bgvalrange[0]} ${bgvalrange[1]}‘ )
25 if [ $? != 0 ];then
26 echo -e "error\t Determining the bgvalue data\n"
27 exit 1
28 fi
29 delta="${bgvalues[0]}*$scatter_scale" #the bg scatter
30 bglevel=${bgvalues[1]} #thebg level
31
32 # init fit file
33 echo -e "">$fitykfile
34 #first load the file
35 tofit "@+ < ’${datafile}’"
36 tofit "A = (${range[0]}< x and x <${range[1]})"
37 tofit "delete(not a)"
38 tofit "A=(y<min(y)+$delta)"
39 tofit "s=sqrt(abs(y))"
40
41 tofit "guess %bg = $bgfunc"
42 tofit "fit"
43 tofit "A=y"
44
45 if [[ $version == twopeaks || $version == all ]];then
46 tofit "guess %mainpeak = Pearson7"
47 tofit "fit"
48 tofit "guess %secondpeak = Pearson7"
49 tofit "fit"
50
51 tofit "p %mainpeak.Center-%secondpeak.Center darea(%mainpeak(x)) darea(%secondpeak(x))> ’${datafile}.asymm_2peaks’"
52 tofit "p darea(%bg(x))/darea(y-%bg(x)) > ’${datafile}.bg_peak_2peaks’"
53 tofit "p darea(%bg(x)) > ’${datafile}.bg_2peaks’"
54 fi
55
56 if [[ $version == all ]];then
57 tofit "delete %mainpeak, %secondpeak, %bg"
58 tofit "A=(y<min(y)+$delta)"
59 tofit "s=sqrt(abs(y))"
60
61 tofit "guess %bg = $bgfunc"
62 tofit "fit"
63 tofit "A=y"
64 fi
65
66 if [[ $version == asymp7 || $version == all ]];then
67 tofit "guess %peak = SplitPearson7"
68 tofit "fit"
69 tofit "p %peak.hwhm1-%peak.hwhm2 > ’${datafile}.asymm_split’"
70 tofit "p darea(%bg(x))/darea(y-%bg(x)) > ’${datafile}.bg_peak_split’"
71 tofit "p darea(%bg(x)) > ’${datafile}.bg_split’"
72 fi
73
74 tofit "plot"
75 tofit "sleep 1"
76 #tofit "quit"
77
78 fityk $fitykfile
