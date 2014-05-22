#!/usr/bin/octave -q
#f
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
# parse command line
#------------------------------------

if ((nargin)!= 2)
    printf("\n\tInterpolate an xy to achive the number of points given as argument 2");
    printf("\n\tUsage: %s", program_name);
    printf("\n\t\t.xy_file");
    printf("\n\t\tnumber of points for the interpolation");
    # printf("\n\toutput to datafile.interpp.xy\n");
    exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
nopoints=str2num(nth(argv,2));

printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

# k und counts Vektor uebernehmen
x=data(:,1);
y=data(:,2);

x_new=(max(x)-min(x))/(nopoints-1.0).*[0:(nopoints-1)]+min(x);
y_new = interp1(x,y,x_new,’pchip’);
y_new(1)=y(1);
y_new(length(y_new))=y(length(y));

# plot(x,y,x_new,y_new);
# pause;

outfname = strcat(data_file,".interpp.xy");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,’wt’);
if outfile == -1
    error("LoadData - Data File:\t %s \n",msg)
endif
for i=1:length(y_new)
    fprintf(outfile,"%E\t%E\n",x_new(i), y_new(i));
endfor
fclose(outfile);

#cleanup

clear *;
printf("...done\n\n");
