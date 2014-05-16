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
14 #
15 #############################################################
16 #
17 #------------------------------------
18 # parse command line
19 #------------------------------------
20
21 if ((nargin)!= 2)
22 printf("\n\tInterpolate an xy to achive the number of points given as argument 2");
23 printf("\n\tUsage: %s", program_name);
24 printf("\n\t\t.xy_file");
25 printf("\n\t\tnumber of points for the interpolation");
26 # printf("\n\toutput to datafile.interpp.xy\n");
27 exit;
28 endif
29
30 #------------------------------------
31 # Daten laden
32 #------------------------------------
33 data=[];
34 data_file=nth(argv,1);
35 nopoints=str2num(nth(argv,2));
36
37 printf("\t %s is processing: %s \t",program_name(),data_file);
38 data = loadData(data_file);
39
40 # k und counts Vektor uebernehmen
41 x=data(:,1);
42 y=data(:,2);
43
44 x_new=(max(x)-min(x))/(nopoints-1.0).*[0:(nopoints-1)]+min(x);
45 y_new = interp1(x,y,x_new,’pchip’);
46 y_new(1)=y(1);
47 y_new(length(y_new))=y(length(y));
48
49 # plot(x,y,x_new,y_new);
50 # pause;
51
52 outfname = strcat(data_file,".interpp.xy");
53 # puts("Writing Data to file: " outfname "\n");
54
55 [outfile, msg] = fopen(outfname,’wt’);
56 if outfile == -1
57 error("LoadData - Data File:\t %s \n",msg)
58 endif
59 for i=1:length(y_new)
60 fprintf(outfile,"%E\t%E\n",x_new(i), y_new(i));
61 endfor
62 fclose(outfile);
63
64 #cleanup
65
66
67 clear *;
68 printf("...done\n\n");
