1  #! /usr/bin/octave -q
2  #take the profile supplied as commandline arg 1
3  #and dividing the all the intensity by the value
4  #at the begining of the profile
5  #
6  #pretty dumb prelim thing does not check ANYTHING
7  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14 #LOADPATH="/home/kerber/bin//:";
15
16 #
17 #############################################################
18 #
19
20 #------------------------------------
21 # parse command line
22 #------------------------------------
23
24 if ((nargin)!= 3)
25 printf("\n\ttake a double_column_profile_file");
26 printf("\n\tand make a symmetric profile in the given range ov minx and maxx");
27 printf("\n\tUsage: %s", program_name);
28 printf("\n\t\tdouble_column_profile_file");
29 printf("\n\t\tminx");
30 printf("\n\t\tmaxx");
31 printf("\n\toutput of a xy double column file of name <datafile> appended .symm \n");
32 exit;
33 endif
34
35 #------------------------------------
36 # Daten laden
37 #------------------------------------
38 data=[];
39 data_file=nth(argv,1);
40 minx=str2num(nth(argv,2));
41 maxx=str2num(nth(argv,3));
42 printf("\t Processing: %s \n",data_file);
43 data = loadData(data_file);
44
45 bgvalue=0.0;
46 # xvalues und counts Vektor uebernehmen
47 xdata=data(:,1);
48 ydata=(data(:,2)-bgvalue);
49 #now cut our range out
50 kvalue=[];
51 yvalue=[];
52 for i=1:length(xdata)
53 if ( (xdata(i)<maxx) && (xdata(i)>minx) )
54 kvalue=[kvalue;xdata(i)];
55 yvalue=[yvalue;ydata(i)];
56 endif
57 endfor
58 #plot(xdaita,ydata,"o",kvalue,yvalue,"-");pause;
59
60 #first we determine the maximum of the vector
61 [maxv,maxi]=max(yvalue);
62 profileside=0; #profileside init "-1" is left, "+1" is right, 0 is undetermined
63 #we also need to know the range of the short peakarea only the indices for the range of the short peak are to be
64 shortpeakmini=0;
65 shortpeakmaxi=0;
66 #now we check where the profile is cut off this is done by looking the shorter distance to the end of the vector
67 if kvalue(maxi) - kvalue(1) > kvalue(length(kvalue))-kvalue(maxi)
68 profileside=-1;
69 shortpeakmini=maxi-(length(kvalue)-maxi);
70 shortpeakmaxi=length(kvalue);
71 else
72 profileside=1;
73 shortpeakmini=1;
74 shortpeakmaxi=maxi+(maxi-1);
75 endif
76 shortpeakx=kvalue(shortpeakmini:shortpeakmaxi);
77 shortpeaky=yvalue(shortpeakmini:shortpeakmaxi);
78 #plot(kvalue,yvalue,"-",shortpeakx,shortpeaky,"o");
79 #pause;
80
81 #compute center of mass
82 deltaki = ( kvalue(1) - kvalue(length(kvalue)) )/length(kvalue);
83 com=sum(shortpeakx .* shortpeaky * deltaki)/sum(shortpeaky*deltaki);
84 clear deltaki;
85
86 #determine max of the short peakonly
87 #and the position of the com
88 comindex=0;
89 maxindex=0;
90 ymax = 0;
91 kmax = 0;
92 #now we determine the indices and values for com, max in the big profile as we want to symmetrize from there!
93 for i=shortpeakmini:shortpeakmaxi
94 if yvalue(i) > ymax
95 ymax = yvalue(i);
96 xmax = kvalue(i);
97 maxindex=i;
98 endif
99 if kvalue(i)<=com
100 comindex=i+1;
101 endif
102 endfor
103 # peakcenteri=comindex;
104 peakcenteri=maxindex;
105 peakcenter=kvalue(peakcenteri);
106 peakcentery=yvalue(peakcenteri);
107
108 #the simples thing now is to take the whole profile move it to zero and then just use the fact that left sided means negative values...
109 #thus profileside*kvalue is always positive. thus we can do a simple adding of data points and
110 #then move the wohle thing back where its peakcenter was!
111 kvalue=(kvalue-peakcenter);
112 #plot(kvalue,yvalue,"o-");
113 #pause;
114 #now just put the points together when profileside*kvalue is positive that is!
115 symmx=[0];
116 symmy=[peakcentery];
117 #peakcenteri+profileside*i
118 for i=1:(max(abs(peakcenteri-1),abs(peakcenteri-length(kvalue))))
119 j=peakcenteri+profileside*i;
120 symmx=[-1*abs(kvalue(j)),symmx,abs(kvalue(j))];
121 symmy=[yvalue(j),symmy,yvalue(j)];
122 endfor
123 #now move the peak back
124 symmx=symmx+peakcenter;
125 #normalize the profile on the fly
126 # symmy=symmy/max(symmy);
127 #com-max(kvalue)
128 #plot(symmx,symmy,"o",xdata,ydata,"-"); pause;
129
130 #write data to file
131 # ####################################
132 # outfname=strrep(data_file,".xy",".centered_norm.xy");
133 outfname = strcat(data_file,".symm");
134 # puts("Writing Data to file: " outfname "\n");
135 #
136 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
137 #write the data!
138 for i=1:length(symmx)
139 # printf("%#.9g\t%#.10g\n",symmx(i),symmy(i));
140 fprintf(outfile,"%#.9g\t%#.10g\n",symmx(i),symmy(i));
141 endfor
142 fclose(outfile);
143 #cleanup
144 clear *;
145 #printf("...done\n\n");
