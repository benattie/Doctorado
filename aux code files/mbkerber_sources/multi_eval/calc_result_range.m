#! /usr/bin/octave -q
#take the profile supplied as commandline arg 1
#and dividing the all the intensity by the value
#at the begining of the profile
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
if ((nargin)!= 1)
printf("\n\ttake a sorted_series_results_file");
printf("\n\tand calculate the ini file with ranges for the averaging");
printf("\n\tUsage: %s", program_name);
printf("\n\t\tsorted_series_results_file");
printf("\n\toutput of a .stat file with the statistical info on the phys results. \n");
exit;
endif
#------------------------------------
# Daten laden
#------------------------------------
data=[];
#we take the sorted version of the series result file
data_file=nth(argv,1);
printf("\t Getting data range for file: %s \n",data_file);
data = loadData(data_file);
# first get the y-data
xdata=data(:,1);
ydata=(data(:,3));
xdata=(1:length(ydata));
#plot the data
# plot(xdata,ydata,"-");pause;
#init the value when the residua are invalid
range=0.10; #0.2; #20%
#initialize the indices to -1 as not set
startindex=-1;
endindex=-1;
endres=-1;
for i=1:(length(ydata))
if (startindex == -1 ) #-1 => no value yet
if ydata(i)>-1 #if the first real residuum is found
startindex=i;
endres=ydata(i)+range*ydata(i);
endif
endif
if ( endres != -1 )
if (ydata(i) <= endres) #as long as we are smaller than the residuum we need to increase the endindex
endindex=i;
endif
endif
endfor
#write data to file
# ####################################
#outfname=strrep(data_file,".xy",".centered_norm.xy");
outfname = strcat(data_file,".stat");
#
[outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
#write the data!
fprintf(outfile,"low_lim=%i\nup_lim=%i\nno_results=%i\nno_empty=%i\nno_physical=%i\npercent_phys=%i\n"\
,startindex,endindex,(length(ydata)),(startindex-1),(endindex-startindex+1),(100*(endindex-startindex+1)/length(
ydata)));

fclose(outfile);

#cleanup
clear *;
#printf("...done\n\n");

