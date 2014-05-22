#!/usr/bin/octave -q
#f
#filter the profile supplied as commandline arg
#pretty dumb prelim thing does not check ANYTHING

puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string converions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file1=nth(argv,1);
printf("\t %s is loading first data file: %s \t",program_name(),data_file1);
data = loadData(data_file1);

# x,y Vektor uebernehmen
x1=data(:,1);
y1=data(:,2);

data_file2=nth(argv,2);
printf("\t %s is loading second data file: %s \t",program_name(),data_file2);
data = loadData(data_file2);

# x,y Vektor uebernehmen
x2=data(:,1);
y2=data(:,2);

# The Filters
[x_diff,y_diff]=profile_add(x1,y1,x2,-y2);
# [x_diff,y_diff]=profile_add(x1,y1,x2,y2);
#gset mouse;
#plot(x1,y1,x2,y2,x_diff,(y_diff+1));
#pause;
#
#write filtered to data

outfname = strcat(data_file1,"-",data_file2,".diff.xy");
printf("Writing Data to file: %s \n",outfname);

[outfile, msg] = fopen(outfname,’wt’);
if outfile == -1
error("LoadData - Data File:\t %s \n",msg)
endif
for i=1:length(x_diff)
fprintf(outfile,"%E\t%E\n",x_diff(i), y_diff(i));
endfor
fclose(outfile);

#write filtered NORMALIZED to data

# outfname=strrep(data_file,".txt",".filt.norm.xy");
# outfname = strcat(data_file,".filtered_norm");
# puts("Writing Data to file: " outfname "\n");
#
# [outfile, msg] = fopen(outfname,’wt’);
# if outfile == -1
# error("LoadData - Data File:\t %s \n",msg)
# endif
# for i=1:length(filteredcounts)
# fprintf(outfile," %#.9g %#.10g\n",k(i), abs(filteredcounts(i)/max(filteredcounts)));
# endfor
# fclose(outfile);


#cleanup


clear *;
printf("...done\n\n");
