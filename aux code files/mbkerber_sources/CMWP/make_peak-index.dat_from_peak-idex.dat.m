1  #! /usr/bin/octave -q
2  #take the MWP- peak-index.dat file supplied as commandline arg 1
3  #load the profile supplied via commandline arg 2 and its bg-spline.dat
4  #then find the maximas around the places of the peak-index.dat and
5  #derive the new peak-index.dat from the spline bg
6  #
7  #pretty dumb prelim thing does not check ANYTHING
8  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
9  
10 source("~/.mbk/octave.defaults");
11
12 #MBK_edit needed patch to run if string conversions error!
13 implicit_num_to_str_ok=1;
14 implicit_str_to_num_ok=1;
15
16 #this is fixed, not via command line so if you want it another way
17 #just edit here
18
19 #
20 #############################################################
21 #
22 # search vector i_value in the range [search_min,search_max]
23 #for a maximum and return its index position
24 function max_counts_idx = find_max(x_value,i_value,search_min,search_max)
25
26 for i=1:length(i_value)
27 if (x_value(i)>search_max)
28 break;
29 endif
30 if(x_value(i)>search_min)
31 if (i_value(i) > max_counts)
32 max_counts = i_value(i);
33 max_counts_idx = i;
34 endif
35 else
36 max_counts_idx = i;
37 max_counts = i_value(i);
38 endif
39 endfor
40 endfunction
41 #
42 #############################################################
43 #
44
45
46 #------------------------------------
47 # parse command line
48 #------------------------------------
49
50 if ((nargin)!= 2)
51 printf("\n\tread please");
52
53 printf("\n\tUsage: %s", program_name);
54 printf("\n\t\tpeak-index.dat_file");
55 printf("\n\t\tdouble_column_profile_file");
56 printf("\n\toutput of double_column_profile_file.peak-index.dat \n");
57 exit;
58 endif
59
60 #------------------------------------
61 # BG Daten laden
62 #------------------------------------
63 #parse the commandline args set the filenames
64 peakdata_file=nth(argv,1);
65
66 # master_profile=strrep(peakdata_file,".peak-index.dat",".dat");
67 master_profile=strrep(peakdata_file,".peak-index.dat","");
68
69 new_profile=nth(argv,2);
70 new_profilebg=strcat(new_profile,".bg-spline.dat");
71
72 #now check if we have same input and output files this happens when looping
73 if (strcmp(master_profile, new_profile) )
74 printf("\nNothing to do!\n");
75 exit;
76 endif
77
78 #first the peak points
79 data=[];
80 data = loadData(peakdata_file);
81 peakpointsx=data(:,1);
82 peakpointsy=data(:,2);
83 peakpointshkl=data(:,3);
84
85 #now the profile
86 data=[];
87 data = loadData(new_profile);
88 newprofile_x=data(:,1);
89 newprofile_y=data(:,2);
90
91 #now the bg-spline.dat of the profile
92 data=[];
93 data = loadData(new_profilebg);
94 newprofilebg_x=data(:,1);
95 newprofilebg_y=data(:,2);
96
97 clear data;
98
99 #Now the range we search for the peak entered in degrees
100 profile_search = 0.3;
101
102 #now search the profile to get the indices for the maxima in the range
103 #compute the int-bg values save them together with x-coord
104
105 #the outfile
106 outfname=strcat(new_profile,".peak-index.dat");
107 [outfile, msg] = fopen(outfname,"wt");
108 if outfile == -1
109 error("error open outfile File:\t %s \n",msg)
110 endif
111
112 for i=1:length(peakpointsx)
113 peak_pos=find_max(newprofile_x, newprofile_y, peakpointsx(i)-profile_search, peakpointsx(i)+profile_search);
114 # peak_int=newprofile_y(peak_pos)-spline(peakpointsx, peakpointsy, newprofile_x(peak_pos));
115 peak_int=newprofile_y(peak_pos);
116 fprintf(outfile,"%#.9g\t%#.10g\t%i\n",newprofile_x(peak_pos), peak_int, peakpointshkl(i) );
117 endfor
118 fclose(outfile);
119
120 #cleanup
121 clear *;
