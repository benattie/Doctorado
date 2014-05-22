#! /usr/bin/octave -q
#filter the profile supplied as commandline arg
#pretty dumb prelim thing does not check ANYTHING

puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string converions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;
#
#############################################################
#
#------------------------------------
# Daten laden
#------------------------------------
#file 1
data=[];
data_file1=nth(argv,1);
printf("\t %s is processing: %s \t",program_name(),data_file1);
data = loadData(data_file1);
x1=data(:,1);
y1=data(:,2);

#file2
data=[];
data_file2=nth(argv,2);
printf("\t %s is processing: %s \t",program_name(),data_file2);
data = loadData(data_file2);
x2=data(:,1);
y2=data(:,2);

#if we want we can make a union of the xscales for consistent data points.
#x = union(x1, x2);
#for now we will take the x1 as the right scale:
x=x1;
#’spline’
y1_interpolate = interp1 (x1,y1,x);
y2_interpolate = interp1 (x2,y2,x);

#gset mouse;
#plot(x,y1_interpolate,x,y2_interpolate);
#pause;
#
#write filtered to data

outfname = strcat(data_file1,"_",data_file2,".merged.xy");
# outfname=strrep(data_file,".xy",".filt.xy");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,’wt’);
if outfile == -1
    error("LoadData - Data File:\t %s \n",msg)
endif
fprintf(outfile,"#x-%s\ty1-%s\ty2-%s\n",data_file1,data_file1,data_file2);
for i=1:length(x)
    fprintf(outfile,"%E\t%E\t%E\n",x(i),y1_interpolate(i),y2_interpolate(i));
endfor
fclose(outfile);
#cleanup
clear *;
printf("...done\n\n");
