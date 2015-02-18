#! /usr/bin/octave -q
#take the profile supplied as commandline arg 1
#and dividing the all the intensity by the value
#at the begining of the profile
#
#pretty dumb prelim thing does not check ANYTHING
puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
source("~/.mbk/octave.defaults");
#MBK_edit needed patch to run if string conversions error!
implicit_num_to_str_ok=1;
implicit_str_to_num_ok=1;
#LOADPATH="/home/kerber/bin//:";
#
#############################################################
#
#------------------------------------
# parse command line
#------------------------------------
if ((nargin)!= 3)
    printf("\n\ttake a double_column_profile_file");
    printf("\n\tand make a symmetric profile in the given range ov minx and maxx");
    printf("\n\tUsage: %s", program_name);
    printf("\n\t\tdouble_column_profile_file");
    printf("\n\t\tminx");
    printf("\n\t\tmaxx");
    printf("\n\toutput of a xy double column file of name <datafile> appended .symm \n");
    exit;
endif
#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
minx=str2num(nth(argv,2));
maxx=str2num(nth(argv,3));
printf("\t Processing: %s \n",data_file);
data = loadData(data_file);
bgvalue=0.0;
# xvalues und counts Vektor uebernehmen
xdata=data(:,1);
ydata=(data(:,2)-bgvalue);
#now cut our range out
kvalue=[];
yvalue=[];
for i=1:length(xdata)
    if ( (xdata(i)<maxx) && (xdata(i)>minx) )
        kvalue=[kvalue;xdata(i)];
        yvalue=[yvalue;ydata(i)];
    endif
endfor
#plot(xdaita,ydata,"o",kvalue,yvalue,"-");pause;
#first we determine the maximum of the vector
[maxv,maxi]=max(yvalue);
profileside=0; #profileside init "-1" is left, "+1" is right, 0 is undetermined
#we also need to know the range of the short peakarea only the indices for the range of the short peak are to be
shortpeakmini=0;
shortpeakmaxi=0;
#now we check where the profile is cut off this is done by looking the shorter distance to the end of the vector
if kvalue(maxi) - kvalue(1) > kvalue(length(kvalue))-kvalue(maxi)
    profileside=-1;
    shortpeakmini=maxi-(length(kvalue)-maxi);
    shortpeakmaxi=length(kvalue);
else
    profileside=1;
    shortpeakmini=1;
    shortpeakmaxi=maxi+(maxi-1);
endif
shortpeakx=kvalue(shortpeakmini:shortpeakmaxi);
shortpeaky=yvalue(shortpeakmini:shortpeakmaxi);
#plot(kvalue,yvalue,"-",shortpeakx,shortpeaky,"o");
#pause;
#compute center of mass
deltaki = ( kvalue(1) - kvalue(length(kvalue)) )/length(kvalue);
com=sum(shortpeakx .* shortpeaky * deltaki)/sum(shortpeaky*deltaki);
clear deltaki;
#determine max of the short peakonly
#and the position of the com
comindex=0;
maxindex=0;
ymax = 0;
kmax = 0;
#now we determine the indices and values for com, max in the big profile as we want to symmetrize from there!
for i=shortpeakmini:shortpeakmaxi
    if yvalue(i) > ymax
        ymax = yvalue(i);
        xmax = kvalue(i);
        maxindex=i;
    endif
    if kvalue(i)<=com
        comindex=i+1;
    endif
endfor
# peakcenteri=comindex;
peakcenteri=maxindex;
peakcenter=kvalue(peakcenteri);
peakcentery=yvalue(peakcenteri);
#the simples thing now is to take the whole profile move it to zero and then just use the fact that left sided means negative values...
#thus profileside*kvalue is always positive. thus we can do a simple adding of data points and
#then move the wohle thing back where its peakcenter was!
kvalue=(kvalue-peakcenter);
#plot(kvalue,yvalue,"o-");
#pause;
#now just put the points together when profileside*kvalue is positive that is!
symmx=[0];
symmy=[peakcentery];
#peakcenteri+profileside*i
for i=1:(max(abs(peakcenteri-1),abs(peakcenteri-length(kvalue))))
    j=peakcenteri+profileside*i;
    symmx=[-1*abs(kvalue(j)),symmx,abs(kvalue(j))];
    symmy=[yvalue(j),symmy,yvalue(j)];
endfor
#now move the peak back
symmx=symmx+peakcenter;
#normalize the profile on the fly
# symmy=symmy/max(symmy);
#com-max(kvalue)
#plot(symmx,symmy,"o",xdata,ydata,"-"); pause;
#write data to file
# ####################################
#
outfname=strrep(data_file,".xy",".centered_norm.xy");
outfname = strcat(data_file,".symm");
#
puts("Writing Data to file: " outfname "\n");
#
[outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
#write the data!
for i=1:length(symmx)
    #
    printf("%#.9g\t%#.10g\n",symmx(i),symmy(i));
    fprintf(outfile,"%#.9g\t%#.10g\n",symmx(i),symmy(i));
endfor
fclose(outfile);
#cleanup
clear *;
#printf("...done\n\n");
