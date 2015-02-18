#!/usr/bin/octave -q
#f
#filter the profile supplied as commandline arg
#pretty dumb prelim thing does not check ANYTHING

puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");

source("~/.mbk/octave.defaults");

#MBK_edit needed patch to run if string converions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;

function max_counts = max_counts(i_value)
    idx =1;
    max_counts = i_value(idx);
    for i=2:length(i_value)
        if (i_value(i) > max_counts)
            max_counts = i_value(i);
        endif
    endfor
endfunction

#
#############################################################
#
function i_value_filtered = i_value_chebyfilter(i_value)
    #make cheby1_filt
    #good 1024 points
    # [b,a]=cheby1(2,.000025, 0.02);
    #testing for arbitrary number of points
    #works for inel 0.03 up to 0.08 for2nd value
    [b,a] = cheby1(2, 0.000002, 80/length(i_value));

    i_value_filtered = filtfilt(b,a,i_value);
    # i_value_filtered = filter(b,1,i_value);
    # freqz(b,a);
    # figure
endfunction
#
#############################################################
#
#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

# k und counts Vektor uebernehmen
counts=data(:,2);
k=data(:,1);

# The Filters
filteredcounts=i_value_chebyfilter(counts);
#gset mouse;
#plot(k,counts,k,filteredcounts);
#pause;
#
#write filtered to data

outfname = strcat(data_file,".filt.xy");
# outfname=strrep(data_file,".xy",".filt.xy");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,’wt’);
if outfile == -1
    error("LoadData - Data File:\t %s \n",msg)
endif
for i=1:length(filteredcounts)
    fprintf(outfile,"%E\t%E\n",k(i), filteredcounts(i));
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
