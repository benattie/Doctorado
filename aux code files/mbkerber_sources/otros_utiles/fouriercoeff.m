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
14
15 #
16 #############################################################
17 #
18
19 #------------------------------------
20 # parse command line
21 #------------------------------------
22
23 if ((nargin)!= 1)
24 printf("\n\ttake a single peak, double_column_profile_file");
25 printf("\n\tand compute the fourier Coefficients");
26
27 printf("\n\tUsage: %s", program_name);
28 printf("\n\t\tdouble_column_profile_file");
29 printf("\n\toutput of a datafile with fourier coeff named .fourier \n");
30 exit;
31 endif
32
33 #------------------------------------
34 # Daten laden
35 #------------------------------------
36 data=[];
37 data_file=nth(argv,1);
38 printf("\t %s is processing: %s \t",program_name(),data_file);
39 data = loadData(data_file);
40
41 #Cu lambda=0.154;
42 #KIT
43 lambda=0.070849154;
44
45 # k und counts Vektor uebernehmen
46 xvalue=data(:,1);
47 yvalue=data(:,2);
48 # testpeak
49 # xvalue=4.2+(4.4-4.2)/2000 * [1:2000];
50 # yvalue=exp( -(4.3-xvalue).^2 / ( 0.0001 ) );
51 # plot(xvalue,yvalue);pause;
52
53 #change to k = 2 * sin (theta) /lambda
54 kvalue=2*sin( (xvalue) *pi/360)/lambda;
55 # kvalue=xvalue;
56
57 #compute center of mass
58 deltaki = ( kvalue(1) - kvalue(length(kvalue)) )/length(kvalue);
59 com=sum(kvalue .* yvalue * deltaki)/sum(yvalue*deltaki);
60 clear deltaki;
61 #determine max of peak
62 maxindex=0;
63 ymax = 0;
64 kmax = 0;
65 for i=1:length(xvalue)
66 if kvalue(i) < com
67 ymax = yvalue(i);
68 kmax = kvalue(i);
69 maxindex=i;
70 endif
71 endfor
72 #determine the outer bounds of the profile
73 deltak = 0;
74 if kmax - kvalue(1) > kvalue(length(kvalue))-kmax
75 deltak = kvalue(length(kvalue)) - kmax;
76 else
77 deltak = kmax - kvalue(1);
78 endif
79 #make a symmetric profile by averaging
80 #normalize the profile on the fly
81 shortk=[];
82 shorty=[];
83 for i=1:length(kvalue)
84 if ( kvalue(i) > (kmax-deltak) ) && ( kvalue(i) < (kmax+deltak) )
85 shortk=[shortk;kvalue(i)];
86 #this is for a symmetric profile
87 # shorty=[shorty;(yvalue(i) + yvalue (2*maxindex-i+1))/(2*ymax) ];
88 #this is the real thing
89 shorty=[shorty;yvalue(i)/ymax];
90 endif
91 endfor
92
93 numfourier=length(shortk)*2;
94 # numfourier=500;
95 an=[];
96 bn=[];
97 an_tmp=[];
98 bn_tmp=[];
99 shorty_tmp=shorty+0.0;
100 #the stepwidth from fouriercoeff to coeff crude guess
101 deltaki = 2*deltak/length(shortk);
102 for n=1:numfourier
103 currentbn=sum(deltaki * shorty .* sin(pi*n*(kmax-shortk)/deltak));
104 bn=[bn;currentbn/(2*deltak)];
105 currentan=sum(deltaki * shorty .* cos(pi*n*(kmax-shortk)/deltak));
106 an=[an;currentan/(2*deltak)];
107
108 currentbn_tmp=sum(deltaki * shorty_tmp .* shortk .* shortk .* sin(pi*n*(kmax-shortk)/deltak));
109 bn_tmp=[bn_tmp;currentbn_tmp/(2*deltak)];
110 currentan_tmp=sum(deltaki * shorty_tmp .* shortk .* shortk .* cos(pi*n*(kmax-shortk)/deltak));
111 an_tmp=[an_tmp;currentan_tmp/(2*deltak)];
112 endfor
113
114 ##gset("mouse");
115 #plot(shortk,shorty,"@",shortk,cos(pi*(kmax-shortk)/deltak),shortk,sin(pi*(kmax-shortk)/deltak));pause;
116 #gset("xrange [0:250]");
117 #gset("mouse");
118 #gset("title \"Cosine - Fouriercoefficients\"");
119 ##gset("terminal postscript color");
120 ##gset("output \"fourier_coeff.ps\"");
121 #plot([1:numfourier],abs(an),[1:numfourier],abs(bn));pause;
122 #plot([1:numfourier],an,[1:numfourier],bn,[1:numfourier],an_tmp);pause;
123
124 #now coumpute the profile again
125 ycomputed=[];
126 for i=1:length(shortk)
127 addan=an .* cos(pi*([1:numfourier].’)*(kmax-shortk(i))/deltak);
128 addbn=bn .* sin(pi*([1:numfourier].’)*(kmax-shortk(i))/deltak);
129 currenty= (sum(addan)+sum(addbn));
130 ycomputed=[ycomputed;currenty];
131 endfor
132
133 ##gset("yrange [0.0002:auto]");
134 ##gset("logscale y");
135 #plot(shortk,shorty/max(shorty),"@",shortk,ycomputed/max(ycomputed) );
136 ##plot(shortk,shorty/max(shorty),"@",shortk,ycomputed/max(ycomputed), shortk,0.5+10*(shorty/max(shorty)-ycomputed/max(ycomputed)));
137 #plot(shortk,shorty,"@",shortk,ycomputed,"o");
138 #pause;
139 #plot(shortk,shorty/max(shorty)-ycomputed/max(ycomputed) );
140 #pause;
141 #write data to file
142 outfname = strcat(data_file,".fourier");
143 # outfname = strcat(data_file,".fourier_norm");
144
145 # puts("Writing Data to file: " outfname "\n");
146 #
147 [outfile, msg] = fopen(outfname,’wt’);
148 if outfile == -1
149 error("error open outfile File:\t %s \n",msg)
150 endif
151 #write the data!
152 # an=an/max(an);
153 # bn=bn/max(bn);
154
155 for i=1:250
156 fprintf(outfile,"%#.9g\t%#.10g\t%#.10g\n",i, an(i),bn(i));
157 endfor
158 fclose(outfile);
159 #cleanup
160 clear *;
161 printf("...done\n\n");
