1  #!/usr/bin/octave -q
2  #f
3  #filter the profile supplied as commandline arg
4  #pretty dumb prelim thing does not check ANYTHING
5
6  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
7
8  source("~/.mbk/octave.defaults");
9
10 #MBK_edit needed patch to run if string converions error!
11 implicit_num_to_str_ok=1;
12 implicit_str_to_num_ok=1;
13
14 function max_counts = max_counts(i_value)
15 idx =1;
16 max_counts = i_value(idx);
17 for i=2:length(i_value)
18 if (i_value(i) > max_counts)
19 max_counts = i_value(i);
20 endif
21 endfor
22 endfunction
23
24 #
25 #############################################################
26 #
27 function i_value_filtered = i_value_chebyfilter(i_value)
28
29 #make cheby1_filt
30 #good 1024 points
31 # [b,a]=cheby1(2,.000025, 0.02);
32 #testing for arbitrary number of points
33 #works for inel 0.03 up to 0.08 for2nd value
34 [b,a] = cheby1(2, 0.000002, 80/length(i_value));
35
36 i_value_filtered = filtfilt(b,a,i_value);
37 # i_value_filtered = filter(b,1,i_value);
38 # freqz(b,a);
39 # figure
40 endfunction
41 #
42 #############################################################
43 #
44 #------------------------------------
45 # Daten laden
46 #------------------------------------
47 data=[];
48 data_file=nth(argv,1);
49 printf("\t %s is processing: %s \t",program_name(),data_file);
50 data = loadData(data_file);
51
52 # k und counts Vektor uebernehmen
53 counts=data(:,2);
54 k=data(:,1);
55
56
57 # The Filters
58 filteredcounts=i_value_chebyfilter(counts);
59 #gset mouse;
60 #plot(k,counts,k,filteredcounts);
61 #pause;
62 #
63 #write filtered to data
64
65 outfname = strcat(data_file,".filt.xy");
66 # outfname=strrep(data_file,".xy",".filt.xy");
67 # puts("Writing Data to file: " outfname "\n");
68
69 [outfile, msg] = fopen(outfname,’wt’);
70 if outfile == -1
71 error("LoadData - Data File:\t %s \n",msg)
72 endif
73 for i=1:length(filteredcounts)
74 fprintf(outfile,"%E\t%E\n",k(i), filteredcounts(i));
75 endfor
76 fclose(outfile);
77
78 #write filtered NORMALIZED to data
79
80 # outfname=strrep(data_file,".txt",".filt.norm.xy");
81 # outfname = strcat(data_file,".filtered_norm");
82 # puts("Writing Data to file: " outfname "\n");
83 #
84 # [outfile, msg] = fopen(outfname,’wt’);
85 # if outfile == -1
86 # error("LoadData - Data File:\t %s \n",msg)
87 # endif
88 # for i=1:length(filteredcounts)
89 # fprintf(outfile," %#.9g %#.10g\n",k(i), abs(filteredcounts(i)/max(filteredcounts)));
90 # endfor
91 # fclose(outfile);
92
93
94 #cleanup
95
96
97 clear *;
98 printf("...done\n\n");
