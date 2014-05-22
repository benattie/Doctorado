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

#
#############################################################
#

#------------------------------------
# parse command line
#------------------------------------

if ((nargin)!= 1)
printf("\n\ttake a single peak, double_column_profile_file");
printf("\n\tand compute the fourier Coefficients");

printf("\n\tUsage: %s", program_name);
printf("\n\t\tdouble_column_profile_file");
printf("\n\toutput of a datafile with fourier coeff named .fourier \n");
exit;
endif

#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);

#Cu lambda=0.154;
#KIT
lambda=0.070849154;

# k und counts Vektor uebernehmen
xvalue=data(:,1);
yvalue=data(:,2);
# testpeak
# xvalue=4.2+(4.4-4.2)/2000 * [1:2000];
# yvalue=exp( -(4.3-xvalue).^2 / ( 0.0001 ) );
# plot(xvalue,yvalue);pause;

#change to k = 2 * sin (theta) /lambda
kvalue=2*sin( (xvalue) *pi/360)/lambda;
# kvalue=xvalue;

#compute center of mass
deltaki = ( kvalue(1) - kvalue(length(kvalue)) )/length(kvalue);
com=sum(kvalue .* yvalue * deltaki)/sum(yvalue*deltaki);
clear deltaki;
#determine max of peak
maxindex=0;
ymax = 0;
kmax = 0;
for i=1:length(xvalue)
if kvalue(i) < com
ymax = yvalue(i);
kmax = kvalue(i);
maxindex=i;
endif
endfor
#determine the outer bounds of the profile
deltak = 0;
if kmax - kvalue(1) > kvalue(length(kvalue))-kmax
deltak = kvalue(length(kvalue)) - kmax;
else
deltak = kmax - kvalue(1);
endif
#make a symmetric profile by averaging
#normalize the profile on the fly
shortk=[];
shorty=[];
for i=1:length(kvalue)
if ( kvalue(i) > (kmax-deltak) ) && ( kvalue(i) < (kmax+deltak) )
shortk=[shortk;kvalue(i)];
#this is for a symmetric profile
# shorty=[shorty;(yvalue(i) + yvalue (2*maxindex-i+1))/(2*ymax) ];
#this is the real thing
shorty=[shorty;yvalue(i)/ymax];
endif
endfor

numfourier=length(shortk)*2;
# numfourier=500;
an=[];
bn=[];
an_tmp=[];
bn_tmp=[];
shorty_tmp=shorty+0.0;
#the stepwidth from fouriercoeff to coeff crude guess
deltaki = 2*deltak/length(shortk);
for n=1:numfourier
currentbn=sum(deltaki * shorty .* sin(pi*n*(kmax-shortk)/deltak));
bn=[bn;currentbn/(2*deltak)];
currentan=sum(deltaki * shorty .* cos(pi*n*(kmax-shortk)/deltak));
an=[an;currentan/(2*deltak)];

currentbn_tmp=sum(deltaki * shorty_tmp .* shortk .* shortk .* sin(pi*n*(kmax-shortk)/deltak));
bn_tmp=[bn_tmp;currentbn_tmp/(2*deltak)];
currentan_tmp=sum(deltaki * shorty_tmp .* shortk .* shortk .* cos(pi*n*(kmax-shortk)/deltak));
an_tmp=[an_tmp;currentan_tmp/(2*deltak)];
endfor

 ##gset("mouse");
 #plot(shortk,shorty,"@",shortk,cos(pi*(kmax-shortk)/deltak),shortk,sin(pi*(kmax-shortk)/deltak));pause;
 #gset("xrange [0:250]");
 #gset("mouse");
 #gset("title \"Cosine - Fouriercoefficients\"");
 ##gset("terminal postscript color");
 ##gset("output \"fourier_coeff.ps\"");
 #plot([1:numfourier],abs(an),[1:numfourier],abs(bn));pause;
 #plot([1:numfourier],an,[1:numfourier],bn,[1:numfourier],an_tmp);pause;

 #now coumpute the profile again
 ycomputed=[];
 for i=1:length(shortk)
 addan=an .* cos(pi*([1:numfourier].’)*(kmax-shortk(i))/deltak);
 addbn=bn .* sin(pi*([1:numfourier].’)*(kmax-shortk(i))/deltak);
 currenty= (sum(addan)+sum(addbn));
 ycomputed=[ycomputed;currenty];
 endfor

 ##gset("yrange [0.0002:auto]");
 ##gset("logscale y");
 #plot(shortk,shorty/max(shorty),"@",shortk,ycomputed/max(ycomputed) );
 ##plot(shortk,shorty/max(shorty),"@",shortk,ycomputed/max(ycomputed), shortk,0.5+10*(shorty/max(shorty)-ycomputed/max(ycomputed)));
 #plot(shortk,shorty,"@",shortk,ycomputed,"o");
 #pause;
 #plot(shortk,shorty/max(shorty)-ycomputed/max(ycomputed) );
 #pause;
 #write data to file
 outfname = strcat(data_file,".fourier");
 # outfname = strcat(data_file,".fourier_norm");

 # puts("Writing Data to file: " outfname "\n");
 #
 [outfile, msg] = fopen(outfname,’wt’);
 if outfile == -1
 error("error open outfile File:\t %s \n",msg)
 endif
 #write the data!
 # an=an/max(an);
 # bn=bn/max(bn);

 for i=1:250
 fprintf(outfile,"%#.9g\t%#.10g\t%#.10g\n",i, an(i),bn(i));
 endfor
 fclose(outfile);
 #cleanup
 clear *;
 printf("...done\n\n");
