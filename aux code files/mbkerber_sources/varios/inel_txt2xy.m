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
12
13 data_file=nth(argv,1);
14 printf("\t %s is processing: %s \t",program_name(),data_file);
15
16 infname=data_file;
17 outfname=strrep(data_file,".txt",".xy");
18
19
20 [infile, msg] = fopen(infname,’rt’);
21 if infile == -1
22 error("LoadData - Data File:\t %s \n",msg)
23 endif
24 [outfile, msg] = fopen(outfname,’wt’);
25 if outfile == -1
26 error("LoadData - Data File:\t %s \n",msg)
27 endif
28
29 line=fgetl(infile)
30 while (feof(infile) == 0)
31 line=fgetl(infile);
32 if (line != -1)
33 [val, count] = sscanf(line,"%g");
34 if (count == 2)
35 fprintf(outfile," %#.9g %#.10g\n",val(1), val(2));
36 endif
37 if (count == 3)
38 fprintf(outfile," %#.9g %#.10g\n",val(2), val(3));
39 endif
40 endif
41 endwhile;
42
43 fclose(outfile);
44 fclose(infile);
45
46 clear *;
47 printf("...done\n\n");
