1  #! /usr/bin/octave -q
2  #take the fityk .peaks file supplied as commandline arg 1
3  #and convert the data to a peak index file without the hkl
4  # maybe think of something else
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
15 #this is fixed, not via command line so if you want it another way
16 #just edit here
17
18 #
19 #############################################################
20 #
21
22 #------------------------------------
23 # parse command line
24 #------------------------------------
25
26 if ((nargin)!= 1)
27 printf("\n\tgenerate a peak-index.dat file from a fityk.peaks_file");
28
29 printf("\n\tUsage: %s", program_name);
30 printf("\n\t\t.peaks_file");
31 printf("\n\toutput of peak-index.dat file \n");
32 exit;
33 endif
34
35 #------------------------------------
36 # Daten laden
37 #------------------------------------
38 data=[];
39 data_file=nth(argv,1);
40 # printf("\t %s is processing: %s \t",program_name(),data_file);
41 #this is for good profiles with same peakset
42
43 peaklist; #call peaklist.m to set peaklist
44
45 #just enter the peaks above and check the printout
46 peakpos=[];
47 peakint=[];
48 peakarea=[];
49 peakfwhm=[];
50 [openedfile, msg] = fopen(data_file,"rt");
51 if openedfile == -1
52 error("LoadData - Data File:\t %s \n",msg)
53 endif
54 while (feof(openedfile) == 0)
55 line=fgetl(openedfile);
56 thedata=[];
57 if (line != -1)
58 if (line(1) != ’#’)
59 if (index(line,"Pearson7") != 0)
60 [thedata,counts] = sscanf(line,"%%_%g Pearson7 %g %g %g %g %g %g %g %g");
61 endif
62 if (index(line,"SplitPearson7") != 0)
63 [thedata,counts] = sscanf(line,"%%_%g SplitPearson7 %g %g %g %g %g %g %g %g %g %g");
64 endif
65 if (index(line,"Lorentzian") != 0)
66 [thedata,counts] = sscanf(line,"%%_%g Lorentzian %g %g %g %g %g %g %g");
67 endif
68 if (index(line,"PseudoVoigt") != 0)
69 [thedata,counts] = sscanf(line,"%%_%g PseudoVoigt %g %g %g %g %g %g %g %g %g");
70 endif
71 if (length(thedata) != 0)
72 #we got
73 # Peakno PeakType Center Height Area FWHM a0 a1 a2 a3
74 #
75 peakpos=[peakpos ; thedata(2)];
76 peakint=[peakint ; thedata(3)];
77 peakarea=[peakarea ; thedata(4)’];
78 peakfwhm=[peakfwhm ; thedata(5)’];
79 endif
80 endif
81 endif
82 endwhile;
83 fclose(openedfile);
84
85 #write data
86
87 outfname=strrep(data_file,".peaks",".peak-index.dat");
88 # puts("Writing Data to file: " outfname "\n");
89
90 [outfile, msg] = fopen(outfname,"wt");
91 if outfile == -1
92 error("no writing Data to Data File:\t %s \n",msg)
93 endif
94 for i=1:length(peakpos)
95 #this is for no peaklist operation
96 # fprintf(outfile,"%g\t%g\t\n",peakpos(i),peakint(i));
97 #this is for peaklist operation
98 fprintf(outfile,"%g\t%g\t%i\n",peakpos(i),peakint(i),peaklist(i));
99 endfor
100 fclose(outfile);
101
102 #cleanup
103 clear *;
