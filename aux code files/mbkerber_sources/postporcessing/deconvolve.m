1  #! /usr/bin/octave -q
2  #take the profile supplied as commandline arg 1
3  #
4  #pretty dumb prelim thing does not check ANYTHING
5  #puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
6  
7  source("~/.mbk/octave.defaults");
8  
9  #MBK_edit needed patch to run if string conversions error!
10 implicit_num_to_str_ok=1;
11 implicit_str_to_num_ok=1;
12
13 #
14 #############################################################
15 #
16
17 #------------------------------------
18 # parse command line
19 #------------------------------------
20
21 if ((nargin)!= 2)
22 printf("\n\tDeconvolve the two peaks xy-file1 from xy-file2");
23
24 printf("\n\tUsage: %s", program_name);
25 printf("\n\t\tdouble_column_profile_file1");
26 printf("\n\t\tdouble_column_profile_file2");
27 exit;
28 endif
29
30 #------------------------------------
31 # Daten laden
32 #------------------------------------
33 data=[];
34 data_file1=nth(argv,1);
35 data_file2=nth(argv,2);
36 # printf("\t %s is processing: %s \t",program_name(),data_file);
37 data = loadData(data_file1);
38 x1=data(:,1)+2;
39 y1=abs(data(:,2))+0.0001;
40 data = loadData(data_file2);
41 x2=data(:,1)+2;
42 y2=abs(data(:,2))+0.0001;
43 clear data;
44 x_all=union(x1,x2);
45
46 y1interp=interp1(x1,y1,x_all,’pchip’);
47 y2interp=interp1(x2,y2,x_all,’pchip’);
48 #[b, r] = deconv (y, a) solves for b and r such that y = conv (a, b) + r.
49 [in,r]=deconv(y2interp,y1interp);
50
51 size(x_all)
52 size(in)
53 size(r)
54
55 #plot(x_all,in,x_all,r,x_all,y1interp,x_all,y2interp);
56 #pause;
57 #plot(x_all,in,x_all,r);
58 #pause;
59 plot(x_all,r);
60 pause;
61
62
63 #write out results
64
65 outfname = strcat(data_file1,".deconv.",data_file2);
66 # outfname=strrep(data_file,".xy",".filt.xy");
67 # puts("Writing Data to file: " outfname "\n");
68
69 [outfile, msg] = fopen(outfname,’wt’);
70 if outfile == -1
71 error("error Saving Data - Data File:\t %s \n",msg)
72 endif
73 for i=1:length(x_all)
74 fprintf(outfile,"%E\t%E\n",x_all(i), r(i));
75 endfor
76 fclose(outfile);
77
78
79 #cleanup
80 clear *;
