#! /usr/bin/octave -q
#take the profile supplied as commandline arg 1
#
#pretty dumb prelim thing does not check ANYTHING
#puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

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
printf("\n\tDeconvolve the two peaks xy-file1 from xy-file2");

printf("\n\tUsage: %s", program_name);
printf("\n\t\tdouble_column_profile_file1");
printf("\n\t\tdouble_column_profile_file2");
exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file1=nth(argv,1);
data_file2=nth(argv,2);
# printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file1);
x1=data(:,1)+2;
y1=abs(data(:,2))+0.0001;
data = loadData(data_file2);
x2=data(:,1)+2;
y2=abs(data(:,2))+0.0001;
clear data;
x_all=union(x1,x2);

y1interp=interp1(x1,y1,x_all,’pchip’);
y2interp=interp1(x2,y2,x_all,’pchip’);
#[b, r] = deconv (y, a) solves for b and r such that y = conv (a, b) + r.
[in,r]=deconv(y2interp,y1interp);

size(x_all)
size(in)
size(r)

#plot(x_all,in,x_all,r,x_all,y1interp,x_all,y2interp);
#pause;
#plot(x_all,in,x_all,r);
#pause;
plot(x_all,r);
pause;


#write out results

outfname = strcat(data_file1,".deconv.",data_file2);
# outfname=strrep(data_file,".xy",".filt.xy");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,’wt’);
if outfile == -1
error("error Saving Data - Data File:\t %s \n",msg)
endif
for i=1:length(x_all)
fprintf(outfile,"%E\t%E\n",x_all(i), r(i));
endfor
fclose(outfile);


#cleanup
clear *;
