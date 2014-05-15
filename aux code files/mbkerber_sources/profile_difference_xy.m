1 #!/usr/bin/octave -q
2 #f
3 #filter the profile supplied as commandline arg
4 #pretty dumb prelim thing does not check ANYTHING
5
6  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
7
8  source("~/.mbk/octave.defaults");
9
10 #MBK_edit needed patch to run if string converions error!
11 implicit_num_to_str_ok=1;
12 implicit_str_to_num_ok=1;
13
14 #------------------------------------
15 # Daten laden
16 #------------------------------------
17 data=[];
18 data_file1=nth(argv,1);
19 printf("\t %s is loading first data file: %s \t",program_name(),data_file1);
20 data = loadData(data_file1);
21
22 # x,y Vektor uebernehmen
23 x1=data(:,1);
24 y1=data(:,2);
25
26 data_file2=nth(argv,2);
27 printf("\t %s is loading second data file: %s \t",program_name(),data_file2);
28 data = loadData(data_file2);
29
30 # x,y Vektor uebernehmen
31 x2=data(:,1);
32 y2=data(:,2);
33
34 # The Filters
35 [x_diff,y_diff]=profile_add(x1,y1,x2,-y2);
36 # [x_diff,y_diff]=profile_add(x1,y1,x2,y2);
37 #gset mouse;
38 #plot(x1,y1,x2,y2,x_diff,(y_diff+1));
39 #pause;
40 #
41 #write filtered to data
42
43 outfname = strcat(data_file1,"-",data_file2,".diff.xy");
44 printf("Writing Data to file: %s \n",outfname);
45
46 [outfile, msg] = fopen(outfname,’wt’);
47 if outfile == -1
48 error("LoadData - Data File:\t %s \n",msg)
49 endif
50 for i=1:length(x_diff)
51 fprintf(outfile,"%E\t%E\n",x_diff(i), y_diff(i));
52 endfor
53 fclose(outfile);
54
55 #write filtered NORMALIZED to data
56
57 # outfname=strrep(data_file,".txt",".filt.norm.xy");
58 # outfname = strcat(data_file,".filtered_norm");
59 # puts("Writing Data to file: " outfname "\n");
60 #
61 # [outfile, msg] = fopen(outfname,’wt’);
62 # if outfile == -1
63 # error("LoadData - Data File:\t %s \n",msg)
64 # endif
65 # for i=1:length(filteredcounts)
66 # fprintf(outfile," %#.9g %#.10g\n",k(i), abs(filteredcounts(i)/max(filteredcounts)));
67 # endfor
68 # fclose(outfile);
69
70
71 #cleanup
72
73
74 clear *;
75 printf("...done\n\n");
