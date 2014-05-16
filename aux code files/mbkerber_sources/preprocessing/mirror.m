1  #! /usr/bin/octave -q
2  #take the profile supplied as commandline arg 1
3  #and dividing add the hkl index (cmdlinearg 2)
4  #at the begining of each line
5  #
6  #pretty dumb prelim thing does not check ANYTHING
7  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8  
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14 #
15 #############################################################
16 #
17
18 #------------------------------------
19 # parse command line
20 #------------------------------------
21
22 if ((nargin)!= 2)
23 printf("\n\ttake a double_column_profile_file mirror it at line number cmdlinearg2");
24 printf("\n\tand make average of the two");
25 printf("\n\tUsage: %s", program_name);
26 printf("\n\t\tdouble_column_profile_file");
27 printf("\n\t\tlinenumb");
28 printf("\n\toutput of a datafile with appended .mirror \n");
29 exit;
30 endif
31
32 #------------------------------------
33 # Daten laden
34 #------------------------------------
35 data=[];
36 data_file=nth(argv,1);
37 printf("\t %s is processing: %s \t",program_name(),data_file);
38 data = loadData(data_file);
39
40 # k und counts Vektor uebernehmen
41 xvalue=data(:,1);
42 yvalue=data(:,2);
43 lineno=nth(argv,2);
44 out_y=[];
45 out_x=[];
46 for i=1:984
47 out_x(i) = xvalue(20+i);
48 out_y(i) = ( yvalue(20+i) + yvalue(1005-i) )/2;
49 endfor
50 # for i=1:492
51 # out_x(i) = xvalue(20+i);
52 # out_y(i) = yvalue(1005-i);
53 # out_x(i+492) = xvalue(20+i+492);
54 # out_y(i+492) = yvalue(512+i);
55 # endfor
56 # for i=1:492
57 # out_x(i) = xvalue(20+i);
58 # out_y(i) = yvalue(20+i);
59 # out_x(i+492) = xvalue(20+i+492);
60 # out_y(i+492) = yvalue(512-i);
61 # endfor
62
63 #write data to file
64 # outfname=strrep(data_file,".p00",".xy");
65 outfname = strcat(data_file,".mirror.av");
66 # puts("Writing Data to file: " outfname "\n");
67
68 [outfile, msg] = fopen(outfname,’w’);
69 if outfile == -1
70 error("error open outfile File:\t %s \n",msg)
71 endif
72 #write the data!
73 for i=1:length(out_x)
74 fprintf(outfile,"%#.9g\t%#.10g\n",out_x(i), out_y(i));
75 endfor
76 fclose(outfile);
77 #cleanup
78 clear *;
79
80 printf("...done\n\n");
