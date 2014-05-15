1  #! /usr/bin/octave -q
2  #take a xy file and adapt data so that
3  #xrange is aequidistant, filling in incomplete data
4  #
5  #pretty dumb prelim thing does not check ANYTHING
6  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
7  
8  source("~/.mbk/octave.defaults");
9 
10 #MBK_edit needed patch to run if string conversions error!
11 implicit_num_to_str_ok=1;
12 implicit_str_to_num_ok=1;
13
14 #this is fixed, not via command line so if you want it another way
15 #just edit here
16
17 #
18 #############################################################
19 #
20
21
22 #------------------------------------
23 # parse command line
24 #------------------------------------
25
26 if ((nargin)!= 2)
27 printf("\n\tInterpolates the profile of a double_column_profile_file");
28 printf("\n\tcreating an aequidistant x range of provided spacing");
29
30 printf("\n\tUsage: %s", program_name);
31 printf("\n\t\tdouble_column_profile_file");
32 printf("\n\t\tx-axis_spacing");
33 printf("\n\toutput of a datafile with appended .aequi.dat \n");
34 exit;
35 endif
36
37 #------------------------------------
38 # Daten laden
39 #------------------------------------
40 data=[];
41 data_file=nth(argv,1);
42 printf("\t %s is processing: %s \t",program_name(),data_file);
43 data = loadData(data_file);
44
45 # k und counts Vektor uebernehmen
46 xvalue=data(:,1);
47 yvalue=data(:,2);
48 deltax=str2num(nth(argv,2));
49 i_max=(xvalue(length(xvalue))-xvalue(1))/deltax;
50 newxvalue=[];
51 newyvalue=[];
52
53 #interpolate
54 n=1;
55 newxvalue=[newxvalue;xvalue(1)];
56 newyvalue=[newyvalue;yvalue(1)];
57 for i=2:i_max
58 if ( (xvalue(n+1) - xvalue(n)) < deltax )
59 error("error:\t The interpolation distance is larger than the data spacing (line %i). \n This will not work with this algorithm!",n)
60 endif
61 if ( (xvalue(n+1) - newxvalue(i-1)) < deltax )
62 n=n+1;
63 endif
64 newxvalue=[newxvalue;newxvalue(i-1)+deltax];
65 newyvalue=[newyvalue;(newyvalue(i-1)+deltax*(yvalue(n+1)-newyvalue(i-1))/(xvalue(n+1)-newxvalue(i-1)))];
66 #printf("%g\t%g\t\t%g\t%g\n",newxvalue(i),newyvalue(i));
67 endfor
68
69 #write data to file
70 # outfname=strrep(data_file,".xy",".aqui.xy");
71 outfname = strcat(data_file,".aequi.dat");
72 # puts("Writing Data to file: " outfname "\n");
73
74 [outfile, msg] = fopen(outfname,"wt");
75 if outfile == -1
76 error("error open outfile File:\t %s \n",msg)
77 endif
78 #write the data!
79 for i=1:i_max
80 fprintf(outfile,"%#.9g\t%#.10g\n",newxvalue(i), newyvalue(i));
81 endfor
82 fclose(outfile);
83 #cleanup
84 clear *;
85
86 printf("...done\n\n");
