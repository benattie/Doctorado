#! /usr/bin/octave -q
#take the MWP- bg-spline.dat file supplied as commandline arg 1
#and compare the points with the profile to get a relative template of the bg
#this then gets applied to the profile supllied via commandline arg 2
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

#now the following scheme: we will parse both profiles and since the bg-spline.dat is ordered we will search until the first pointwhich is larger
#then the first bg xcoordinate, remember both index values then set the new search point the second bg point....
#each time checking that there is a next bg point; if not, break the search.

function the_indices = get_indices(coordinates,vector)
the_indices = [];
#start search for first coordinate
coord_index=1;
#now search
for i=1:length(vector)
if ( vector(i) >= coordinates(coord_index) )
the_indices=[the_indices ; i];
coord_index = coord_index+1;
if coord_index > length(coordinates)
break;
endif
endif
if i == length(vector)
the_indices=[the_indices ; i];
endif
endfor
if length(the_indices) != length(coordinates)
error("ERROR did not find as many indices as data points are expected!")
endif
endfunction

#
#############################################################
#


#------------------------------------
# parse command line
#------------------------------------

if ((nargin)!= 2)
printf("\n\tgenerate a fityk file from a bg-spline.dat_file");

printf("\n\tUsage: %s", program_name);
printf("\n\t\tbg-spline.dat_file");
printf("\n\t\tdouble_column_profile_file");
printf("\n\toutput of double_column_profile_file.bg-spline.dat \n");
exit;
endif

#------------------------------------
# BG Daten laden
#------------------------------------
#parse the commandline args set the filenames
bgdata_file=nth(argv,1);

# master_profile=strrep(bgdata_file,".bg-spline.dat",".dat");
master_profile=strrep(bgdata_file,".bg-spline.dat","");

new_profile=nth(argv,2);

#now check if we have same input and output files this happens when looping
if (strcmp(master_profile, new_profile) )
printf("\nNothing to do!\n");
exit;
endif

#first the bg points
data=[];
data = loadData(bgdata_file);
bgpointsx=data(:,1);
bgpointsy=data(:,2);

#now the corresponding profile
data=[];
data = loadData(master_profile);
masterprofile_x=data(:,1);
masterprofile_y=data(:,2);

#now the profile for which we want the bg-spline.dat
data=[];
data = loadData(new_profile);
newprofile_x=data(:,1);
newprofile_y=data(:,2);

clear data;

#now determine the indices where the base points of the bg-spline are
master_indices = get_indices(bgpointsx,masterprofile_x);
new_indices = get_indices(bgpointsx,newprofile_x);

#next determine the vector of multiples of the bg value
#for this take the average of plusminus no_of_avg_points
no_of_avg_points=2;

bg_relative_y=[];
for i=1:length(bgpointsx)
avg_y=-masterprofile_y(master_indices(i));
for j=0:no_of_avg_points
minor_index= master_indices(i)-j;
major_index= master_indices(i)+j;

if (minor_index<1) minor_index=major_index; endif
if (major_index>length(masterprofile_y)) major_index=minor_index; endif

avg_y=avg_y+masterprofile_y(minor_index)+masterprofile_y(major_index);
endfor
avg_y=avg_y/(2*no_of_avg_points+1);
bg_relative_y=[bg_relative_y; bgpointsy(i)/avg_y];
endfor

new_bgpointsx=[];
new_bgpointsy=[];

for i=1:length(bgpointsx)
avg_y=-newprofile_y(new_indices(i));
for j=0:no_of_avg_points
minor_index= new_indices(i)-j;
major_index= new_indices(i)+j;

if (minor_index<1) minor_index=major_index; endif
if (major_index>length(newprofile_y)) major_index=minor_index; endif

avg_y=avg_y+newprofile_y(minor_index)+newprofile_y(major_index);
endfor
avg_y=avg_y/(2*no_of_avg_points+1);
new_bgpointsx=[new_bgpointsx; newprofile_x(new_indices(i))];
new_bgpointsy=[new_bgpointsy; avg_y*bg_relative_y(i)];
endfor

#newspline=spline(new_bgpointsx, new_bgpointsy, newprofile_x);
#gset("logscale y");
#gset("mouse");
#plot(newprofile_x, newspline, newprofile_x, newprofile_y);
#pause;
#write data


outfname=strcat(new_profile,".bg-spline.dat");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,"wt");
if outfile == -1
error("no writing Data to Data File:\t %s \n",msg)
endif
#write the data!
for i=1:length(bgpointsx)
fprintf(outfile,"%#.9g\t%#.10g\n",new_bgpointsx(i), new_bgpointsy(i));
endfor
fclose(outfile);

#cleanup
clear *;
