#! /usr/bin/octave -q
#take the profile supplied as commandline arg 1
#and dividing add the hkl index (cmdlinearg 2)
#at the begining of each line
#
#pretty dumb prelim thing does not check ANYTHING
puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string conversions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;
#
#############################################################
#

#------------------------------------
# parse command line
#------------------------------------

if ((nargin)!= 2)
printf("\n\ttake a double_column_profile_file mirror it at line number cmdlinearg2");
printf("\n\tand make average of the two");
printf("\n\tUsage: %s", program_name);
printf("\n\t\tdouble_column_profile_file");
printf("\n\t\tlinenumb");
printf("\n\toutput of a datafile with appended .mirror \n");
exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

# k und counts Vektor uebernehmen
xvalue=data(:,1);
yvalue=data(:,2);
lineno=nth(argv,2);
out_y=[];
out_x=[];
for i=1:984
out_x(i) = xvalue(20+i);
out_y(i) = ( yvalue(20+i) + yvalue(1005-i) )/2;
endfor
# for i=1:492
# out_x(i) = xvalue(20+i);
# out_y(i) = yvalue(1005-i);
# out_x(i+492) = xvalue(20+i+492);
# out_y(i+492) = yvalue(512+i);
# endfor
# for i=1:492
# out_x(i) = xvalue(20+i);
# out_y(i) = yvalue(20+i);
# out_x(i+492) = xvalue(20+i+492);
# out_y(i+492) = yvalue(512-i);
# endfor

#write data to file
# outfname=strrep(data_file,".p00",".xy");
outfname = strcat(data_file,".mirror.av");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,’w’);
if outfile == -1
error("error open outfile File:\t %s \n",msg)
endif
#write the data!
for i=1:length(out_x)
fprintf(outfile,"%#.9g\t%#.10g\n",out_x(i), out_y(i));
endfor
fclose(outfile);
#cleanup
clear *;

printf("...done\n\n");
