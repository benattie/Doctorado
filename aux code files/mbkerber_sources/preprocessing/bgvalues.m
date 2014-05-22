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

if ((nargin)!= 3)
    printf("\n\tDetermine the height and scattering of the bg of a double_column_profile_file");
    printf("\n\tUsage: %s", program_name);
    printf("\n\t\tdouble_column_profile_file");
    printf("\n\t start line \n");
    printf("\n\t end line \n");
    exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
startl=str2num(nth(argv,2));
endl=str2num(nth(argv,3));
# printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

# k und counts Vektor uebernehmen
x=data(startl:endl,1);
y=data(startl:endl,2);

#error because of dim of x,y???
[up,down] = envelope(x,y,’pchip’);
bgdiff=up-down;
# plot(x,y,x,up,x,down,x,bgdiff);
# plot(x,y)
# pause

# bgscatter=max(y)-min(y);
bgscatter=sum(abs(bgdiff))/length(bgdiff);
bg=sum(y)/length(y);
printf("%g %g",bgscatter,bg);

#cleanup
clear *;
