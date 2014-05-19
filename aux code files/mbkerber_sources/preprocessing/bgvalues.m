1  #! /usr/bin/octave -q
2  #take the profile supplied as commandline arg 1
3  #and dividing the all the intensity by the value
4  #at the begining of the profile
5  #
6  #pretty dumb prelim thing does not check ANYTHING
7  #puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8  
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14
15 #
16 #############################################################
17 #
18
19 #------------------------------------
20 # parse command line
21 #------------------------------------
22
23 if ((nargin)!= 3)
24 printf("\n\tDetermine the height and scattering of the bg of a double_column_profile_file");
25
26 printf("\n\tUsage: %s", program_name);
27 printf("\n\t\tdouble_column_profile_file");
28 printf("\n\t start line \n");
29 printf("\n\t end line \n");
30 exit;
31 endif
32
33 #------------------------------------
34 # Daten laden
35 #------------------------------------
36 data=[];
37 data_file=nth(argv,1);
38 startl=str2num(nth(argv,2));
39 endl=str2num(nth(argv,3));
40 # printf("\t %s is processing: %s \t",program_name(),data_file);
41 data = loadData(data_file);
42
43 # k und counts Vektor uebernehmen
44 x=data(startl:endl,1);
45 y=data(startl:endl,2);
46
47 #error because of dim of x,y???
48 [up,down] = envelope(x,y,’pchip’);
49 bgdiff=up-down;
50 # plot(x,y,x,up,x,down,x,bgdiff);
51 # plot(x,y)
52 # pause
53
54 # bgscatter=max(y)-min(y);
55 bgscatter=sum(abs(bgdiff))/length(bgdiff);
56 bg=sum(y)/length(y);
57 printf("%g %g",bgscatter,bg);
58
59 #cleanup
60 clear *;
