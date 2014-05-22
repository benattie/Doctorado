#! /usr/bin/octave -q
#take the fityk .peaks file supplied as commandline arg 1
#and convert the data to a peak index file without the hkl
# maybe think of something else
#
#pretty dumb prelim thing does not check ANYTHING
puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string conversions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;

#this is fixed, not via command line so if you want it another way
#just edit here

#
#############################################################
#

#------------------------------------
# parse command line
#------------------------------------

if ((nargin)!= 1)
printf("\n\tgenerate a peak-index.dat file from a fityk.peaks_file");

printf("\n\tUsage: %s", program_name);
printf("\n\t\t.peaks_file");
printf("\n\toutput of peak-index.dat file \n");
exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
# printf("\t %s is processing: %s \t",program_name(),data_file);
#this is for good profiles with same peakset

peaklist; #call peaklist.m to set peaklist

#just enter the peaks above and check the printout
peakpos=[];
peakint=[];
peakarea=[];
peakfwhm=[];
[openedfile, msg] = fopen(data_file,"rt");
if openedfile == -1
error("LoadData - Data File:\t %s \n",msg)
endif
while (feof(openedfile) == 0)
line=fgetl(openedfile);
thedata=[];
if (line != -1)
if (line(1) != ’#’)
if (index(line,"Pearson7") != 0)
[thedata,counts] = sscanf(line,"%%_%g Pearson7 %g %g %g %g %g %g %g %g");
endif
if (index(line,"SplitPearson7") != 0)
[thedata,counts] = sscanf(line,"%%_%g SplitPearson7 %g %g %g %g %g %g %g %g %g %g");
endif
if (index(line,"Lorentzian") != 0)
[thedata,counts] = sscanf(line,"%%_%g Lorentzian %g %g %g %g %g %g %g");
endif
if (index(line,"PseudoVoigt") != 0)
[thedata,counts] = sscanf(line,"%%_%g PseudoVoigt %g %g %g %g %g %g %g %g %g");
endif
if (length(thedata) != 0)
#we got
# Peakno PeakType Center Height Area FWHM a0 a1 a2 a3
#
peakpos=[peakpos ; thedata(2)];
peakint=[peakint ; thedata(3)];
peakarea=[peakarea ; thedata(4)’];
peakfwhm=[peakfwhm ; thedata(5)’];
endif
endif
endif
endwhile;
fclose(openedfile);

#write data

outfname=strrep(data_file,".peaks",".peak-index.dat");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,"wt");
if outfile == -1
error("no writing Data to Data File:\t %s \n",msg)
endif
for i=1:length(peakpos)
#this is for no peaklist operation
# fprintf(outfile,"%g\t%g\t\n",peakpos(i),peakint(i));
#this is for peaklist operation
fprintf(outfile,"%g\t%g\t%i\n",peakpos(i),peakint(i),peaklist(i));
endfor
 fclose(outfile);

 #cleanup
 clear *;
