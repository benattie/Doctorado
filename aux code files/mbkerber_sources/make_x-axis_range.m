1  #! /usr/bin/octave -q
2  #take the profile supplied as commandline arg 1
3  #search in the range commandline2,3 for the max
4  #assign to the max the value commandline 4 and
5  #then add the values for the x-axis by using commandline 5
6  #for the x-axis (eg 2theta or theta) valus per channel
7  #
8  #pretty dumb prelim thing does not check ANYTHING
9  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
10
11 source("~/.mbk/octave.defaults");
12
13 #MBK_edit needed patch to run if string conversions error!
14 implicit_num_to_str_ok=1;
15 implicit_str_to_num_ok=1;
16
17 #this is fixed, not via command line so if you want it another way
18 #just edit here
19 #
20 #############################################################
21 #
22
23 function max_counts_idx = find_max(i_value,search_min,search_max)
24 # search vector i_value in the range [search_min,search_max]
25 #for a maximum and return its index position
26
27 max_counts = i_value(search_min);
28 max_counts_idx = search_min;
29 for i=(search_min+1):search_max
30 if (i_value(i) > max_counts)
31 max_counts = i_value(i);
32 max_counts_idx = i;
33 endif
34 endfor
35 endfunction
36
37 #
38 #############################################################
39 #
40
41 #------------------------------------
42 # parse command line
43 #------------------------------------
44
45 # for i=1:nargin
46 # printf("\n %s",nth(argv,i));
47 # endfor
48 # printf("%g\n",nargin);
49 if ((nargin)!= 5)
50 printf("\n\t Searches the profile single_column_profile_file");
51 printf("\n\t for a peak in given range, assigning it the also provided value");
52 printf("\n\t and setting x-axis scale to the channels");
53
54 printf("\n\tUsage: %s", program_name);
55 printf("\n\t\tsingle_column_profile_file");
56 printf("\n\t\tmin_search_channel_no");
57 printf("\n\t\tmax_search_channel_no");
58 printf("\n\t\tx_axis_position_of_peak");
59 printf("\n\t\tx_axis_value_per_channel");
60 printf("\n\toutput of datafile with appended .xy \n");
61 exit;
62 endif
63
64 #------------------------------------
65 # Daten laden
66 #------------------------------------
67 data=[];
68 data_file=nth(argv,1);
69 printf("\t %s is processing: %s \t",program_name(),data_file);
70 data = loadData(data_file);
71
72 # k und counts Vektor uebernehmen
73 counts=data(:,1);
74
75 #plot(data);
76 #pause;
77
78 #search for the max in given interval
79 minch=str2num(nth(argv,2));
80 maxch=str2num(nth(argv,3));
81 if maxch>length(counts)
82 maxch=length(counts-2);
83 endif
84 peak_pos=find_max(counts,minch,maxch);
85 #now the each channel of the file gets assigned
86 #the xvalue of the max - (peak_pos-n)*x_value_per_channel)
87 x_value=1:length(counts);
88 for i=1:length(counts)
89 x_value(i) = str2num(nth(argv,4)) - (peak_pos-i)*str2num(nth(argv,5));
90 endfor
91
92 #write data to file
93 # outfname=strrep(data_file,".p00",".xy");
94 outfname = strcat(data_file,".xy");
95 # puts("Writing Data to file: " outfname "\n");
96
97 [outfile, msg] = fopen(outfname,"wt");
98 if outfile == -1
99 error("error open outfile File:\t %s \n",msg)
100 endif
101 #write the data!
102 for i=1:length(counts)
103 fprintf(outfile,"%#.9g\t%#.10g\n",x_value(i), counts(i));
104 endfor
105 fclose(outfile);
106 #cleanup
107 clear *;
108
109 printf("...done\n\n");
