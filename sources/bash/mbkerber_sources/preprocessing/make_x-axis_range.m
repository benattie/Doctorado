#! /usr/bin/octave -q
#take the profile supplied as commandline arg 1
#search in the range commandline2,3 for the max
#assign to the max the value commandline 4 and
#then add the values for the x-axis by using commandline 5
#for the x-axis (eg 2theta or theta) valus per channel
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

function max_counts_idx = find_max(i_value,search_min,search_max)
    # search vector i_value in the range [search_min,search_max]
    #for a maximum and return its index position
    max_counts = i_value(search_min);
    max_counts_idx = search_min;
    for i=(search_min+1):search_max
        if (i_value(i) > max_counts)
            max_counts = i_value(i);
            max_counts_idx = i;
        endif
    endfor
endfunction
#
#############################################################
#
#------------------------------------
# parse command line
#------------------------------------
# for i=1:nargin
# printf("\n %s",nth(argv,i));
# endfor
# printf("%g\n",nargin);
if ((nargin)!= 5)
    printf("\n\t Searches the profile single_column_profile_file");
    printf("\n\t for a peak in given range, assigning it the also provided value");
    printf("\n\t and setting x-axis scale to the channels");
    printf("\n\tUsage: %s", program_name);
    printf("\n\t\tsingle_column_profile_file");
    printf("\n\t\tmin_search_channel_no");
    printf("\n\t\tmax_search_channel_no");
    printf("\n\t\tx_axis_position_of_peak");
    printf("\n\t\tx_axis_value_per_channel");
    printf("\n\toutput of datafile with appended .xy \n");
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
counts=data(:,1);
#plot(data);
#pause;

#search for the max in given interval
minch=str2num(nth(argv,2));
maxch=str2num(nth(argv,3));
if maxch>length(counts)
    maxch=length(counts-2);
endif
peak_pos=find_max(counts,minch,maxch);
#now the each channel of the file gets assigned
#the xvalue of the max - (peak_pos-n)*x_value_per_channel)
x_value=1:length(counts);
for i=1:length(counts)
    x_value(i) = str2num(nth(argv,4)) - (peak_pos-i)*str2num(nth(argv,5));
endfor

#write data to file
# outfname=strrep(data_file,".p00",".xy");
outfname = strcat(data_file,".xy");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,"wt");
if outfile == -1
    error("error open outfile File:\t %s \n",msg)
endif
#write the data!
for i=1:length(counts)
    fprintf(outfile,"%#.9g\t%#.10g\n",x_value(i), counts(i));
endfor
fclose(outfile);
#cleanup
clear *;
 printf("...done\n\n");
