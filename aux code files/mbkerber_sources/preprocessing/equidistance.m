#! /usr/bin/octave -q
#take a xy file and adapt data so that
#xrange is aequidistant, filling in incomplete data
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

if ((nargin)!= 2)
    printf("\n\tInterpolates the profile of a double_column_profile_file");
    printf("\n\tcreating an aequidistant x range of provided spacing");
    printf("\n\tUsage: %s", program_name);
    printf("\n\t\tdouble_column_profile_file");
    printf("\n\t\tx-axis_spacing");
    printf("\n\toutput of a datafile with appended .aequi.dat \n");
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
deltax=str2num(nth(argv,2));
i_max=(xvalue(length(xvalue))-xvalue(1))/deltax;
newxvalue=[];
newyvalue=[];

#interpolate
n=1;
newxvalue=[newxvalue;xvalue(1)];
newyvalue=[newyvalue;yvalue(1)];
for i=2:i_max
    if ( (xvalue(n+1) - xvalue(n)) < deltax )
        error("error:\t The interpolation distance is larger than the data spacing (line %i). \n This will not work with this algorithm!",n)
    endif
    if ( (xvalue(n+1) - newxvalue(i-1)) < deltax )
        n=n+1;
    endif
    newxvalue=[newxvalue;newxvalue(i-1)+deltax];
    newyvalue=[newyvalue;(newyvalue(i-1)+deltax*(yvalue(n+1)-newyvalue(i-1))/(xvalue(n+1)-newxvalue(i-1)))];
    #printf("%g\t%g\t\t%g\t%g\n",newxvalue(i),newyvalue(i));
endfor

#write data to file
# outfname=strrep(data_file,".xy",".aqui.xy");
outfname = strcat(data_file,".aequi.dat");
# puts("Writing Data to file: " outfname "\n");

[outfile, msg] = fopen(outfname,"wt");
if outfile == -1
    error("error open outfile File:\t %s \n",msg)
endif
#write the data!
for i=1:i_max
    fprintf(outfile,"%#.9g\t%#.10g\n",newxvalue(i), newyvalue(i));
endfor
fclose(outfile);
#cleanup
clear *;

printf("...done\n\n");
