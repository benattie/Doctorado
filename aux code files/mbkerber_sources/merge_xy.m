1  #! /usr/bin/octave -q
2  #filter the profile supplied as commandline arg
3  #pretty dumb prelim thing does not check ANYTHING
4  
5  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
6  
7  source("~/.mbk/octave.defaults");
8  
9  #MBK_edit needed patch to run if string converions error!
10 implicit_num_to_str_ok=1;
11 implicit_str_to_num_ok=1;
12 #
13 #############################################################
14 #
15 #------------------------------------
16 # Daten laden
17 #------------------------------------
18 #file 1
19 data=[];
20 data_file1=nth(argv,1);
21 printf("\t %s is processing: %s \t",program_name(),data_file1);
22 data = loadData(data_file1);
23 x1=data(:,1);
24 y1=data(:,2);
25
26 #file2
27 data=[];
28 data_file2=nth(argv,2);
29 printf("\t %s is processing: %s \t",program_name(),data_file2);
30 data = loadData(data_file2);
31 x2=data(:,1);
32 y2=data(:,2);
33
34 #if we want we can make a union of the xscales for consistent data points.
35 #x = union(x1, x2);
36 #for now we will take the x1 as the right scale:
37 x=x1;
38 #’spline’
39 y1_interpolate = interp1 (x1,y1,x);
40 y2_interpolate = interp1 (x2,y2,x);
41
42 #gset mouse;
43 #plot(x,y1_interpolate,x,y2_interpolate);
44 #pause;
45 #
46 #write filtered to data
47
48 outfname = strcat(data_file1,"_",data_file2,".merged.xy");
49 # outfname=strrep(data_file,".xy",".filt.xy");
50 # puts("Writing Data to file: " outfname "\n");
51
52 [outfile, msg] = fopen(outfname,’wt’);
53 if outfile == -1
54 error("LoadData - Data File:\t %s \n",msg)
55 endif
56 fprintf(outfile,"#x-%s\ty1-%s\ty2-%s\n",data_file1,data_file1,data_file2);
57 for i=1:length(x)
58 fprintf(outfile,"%E\t%E\t%E\n",x(i),y1_interpolate(i),y2_interpolate(i));
59 endfor
60 fclose(outfile);
61
62
63 #cleanup
64
65
66 clear *;
67 printf("...done\n\n");
