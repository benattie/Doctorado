#! /usr/bin/octave -q
#take the MWP- peak-index.dat file supplied as commandline arg 1
#load the profile supplied via commandline arg 2 and its bg-spline.dat
#then find the maximas around the places of the peak-index.dat and
#derive the new peak-index.dat from the spline bg
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
# search vector i_value in the range [search_min,search_max]
#for a maximum and return its index position
function max_counts_idx = find_max(x_value,i_value,search_min,search_max)

    for i=1:length(i_value)
        if (x_value(i)>search_max)
            break;
        endif
        if(x_value(i)>search_min)
            if (i_value(i) > max_counts)
                max_counts = i_value(i);
                max_counts_idx = i;
            endif
        else
            max_counts_idx = i;
            max_counts = i_value(i);
        endif
    endfor
endfunction
#
#############################################################
#
#------------------------------------
# parse command line
#------------------------------------
if ((nargin)!= 2)
    printf("\n\tread please");

    printf("\n\tUsage: %s", program_name);
    printf("\n\t\tpeak-index.dat_file");
    printf("\n\t\tdouble_column_profile_file");
    printf("\n\toutput of double_column_profile_file.peak-index.dat \n");
    exit;
endif

#------------------------------------
# BG Daten laden
#------------------------------------
#parse the commandline args set the filenames
peakdata_file=nth(argv,1);

# master_profile=strrep(peakdata_file,".peak-index.dat",".dat");
master_profile=strrep(peakdata_file,".peak-index.dat","");

new_profile=nth(argv,2);
new_profilebg=strcat(new_profile,".bg-spline.dat");

#now check if we have same input and output files this happens when looping
if (strcmp(master_profile, new_profile) )
    printf("\nNothing to do!\n");
    exit;
endif

#first the peak points
data=[];
data = loadData(peakdata_file);
peakpointsx=data(:,1);
peakpointsy=data(:,2);
peakpointshkl=data(:,3);

#now the profile
data=[];
data = loadData(new_profile);
newprofile_x=data(:,1);
newprofile_y=data(:,2);

#now the bg-spline.dat of the profile
data=[];
data = loadData(new_profilebg);
newprofilebg_x=data(:,1);
newprofilebg_y=data(:,2);

clear data;

#Now the range we search for the peak entered in degrees
profile_search = 0.3;

#now search the profile to get the indices for the maxima in the range
#compute the int-bg values save them together with x-coord

#the outfile
outfname=strcat(new_profile,".peak-index.dat");
[outfile, msg] = fopen(outfname,"wt");
if outfile == -1
    error("error open outfile File:\t %s \n",msg)
endif

for i=1:length(peakpointsx)
    peak_pos=find_max(newprofile_x, newprofile_y, peakpointsx(i)-profile_search, peakpointsx(i)+profile_search);
    # peak_int=newprofile_y(peak_pos)-spline(peakpointsx, peakpointsy, newprofile_x(peak_pos));
    peak_int=newprofile_y(peak_pos);
    fprintf(outfile,"%#.9g\t%#.10g\t%i\n",newprofile_x(peak_pos), peak_int, peakpointshkl(i) );
endfor
fclose(outfile);

#cleanup
clear *;
