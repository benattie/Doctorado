#! /usr/bin/octave -q
#take a .csv from the MWP fit results and determine the averages...
#need the ranges supplied as additional args
#
#pretty dumb prelim thing does not check ANYTHING
#puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
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
if ((nargin)!= 3)
printf("\n\tProcess a .csv file with MWP-fit results");
printf("\n\tUsage: %s", program_name);
printf("\n\t\t.csv file with MWP-fit results");
printf("\n\t\tstart line");
printf("\n\t\tend line");
printf("\n\toutput of a datafile with results and errors.\n");
exit(1);
endif
#------------------------------------
# Daten laden
#------------------------------------
data=[];
data_file=nth(argv,1);
low_lim=str2num(nth(argv,2));
up_lim=str2num(nth(argv,3));
#low_lim=13;up_lim=30;
#printf("\t %s is processing: %s \t",program_name(),data_file);
data = loadData(data_file);
results = data(low_lim:up_lim,:);
#remember the data look like
# evalrun sampleno fitparameters
#if we are cub that should make 13 columns!

# res m sigma d l0 rho re m* epsilon stpr q

#important that the residuals are last as they determine our weights!


#dataset=strrep(data_file,".csv.tmp","");


numparam=length (results(1,:));

numlines=length (results(:,1));


#compute the averages

#the weights = minres/residuum => w(minres) := 1

w=results(1,3)./results(:,3);

# #now check if d or L0 are too large
# #and set corresponding weights to :=0
# w(find(results(:,6)>=1000))=0


#the sum over the weights for normalizing

sumw=sum(w);


#now normalize the weights

w=w./sum(w);


#the solution will look like: sampleno average absdev reldev .... for all parameters

solutions=[results(1,2)]; #line vector, first value of the solution is _any_ measurement value index. so from the first
row the second column

averages=[]; #the line vector of the average values to be assembled with the solutions and for the determination of the
physical min.


#average = sum_i wi*xi

#deviation = sqrt( sum_i wi*(xii-average)^2 )

#we start at column 3 since 1 and 2 are evalrun and sampleno

#if there was no error column should stay the sample no!


for i=3:numparam


xi=results(:,i);


do #do until loop for reduction of large errors!

avg=sum(xi.*w);

absdev=sqrt(sum( w.*(xi-avg).^2));

if (avg == 0)

avg=1.0e-32;

endif

reldev=100*absdev/avg;

if ( reldev >100 )

#if our reldev error is to high kick some results and recompute.

#instead of deleting we assign the average to the high values as to prevent errors with the weights

#the same way we still keep the tendency of the ausreisser in the evaluated data

oldxi=xi;

xi = [];

for j=1:length(oldxi)

if (abs(oldxi(j) - avg) > absdev)

xi=[xi; avg];

else
xi=[xi;oldxi(j)];
endif
endfor
endif
until (reldev <= 100) #end do loop
#for our plotting
#rho,rhoerr aka column 17,18 => i=5 must be *1000 to get 10^15
#and for m* and m*err (23,24) => i=7 we must multiply with 7
switch (i)
case (8)
avg=1000*avg;
absdev=1000*absdev;
case (10)
avg=7*avg;
absdev=7*absdev;
otherwise
endswitch
#unchanged solutions
solutions=[solutions,avg,absdev,reldev];
averages=[averages,avg];
endfor
#determine the representative solution. for this we calc (sum_i (param_i-avg)^2)and look for the smallest..
#fixme
#easiest make a vector of averages to match the solutions. the substract the avg from all the sols, square this, sum and
determine the min.
# V )
diff_avg=[];
for i=1:numlines
curr_diff_sumsq = sumsq(results(i,3:numparam) - averages);
diff_avg=[diff_avg;curr_diff_sumsq];
endfor
[minvalue, min_index] = min (diff_avg);
rep_sol=results(min_index,1);
min_sol=results(1,1);
#output the rep sol to the outfile.
#if we already did this once we need to replace that line..
command=sprintf("egrep -v \"rep_sol|min_sol\" %s.stat > %s.temp ",data_file,data_file);
system(command);
command=sprintf("echo \"rep_sol=%i\nmin_sol=%i\" >> %s.temp;mv %s.temp %s.stat",rep_sol,min_sol,data_file,data_file,
data_file);
system(command);
solstring=sprintf("%i",solutions(1));
for i=2:length(solutions)
solstring=strcat(solstring,sprintf("\t%#.5e",solutions(i)));
endfor
puts(strcat(solstring,"\n"));
#write data to file
#outfname=strrep(data_file,".xy",".aqui.xy");
#outfname = strcat(data_file,".aequi.dat");
#puts("Writing Data to file: " outfname "\n");
#[outfile, msg] = fopen(outfname,"wt");
#if outfile == -1
#error("error open outfile File:\t %s \n",msg)
#endif
##write the data!
#for i=1:i_max
#fprintf(outfile,"%#.9g\t%#.10g\n",newxvalue(i), newyvalue(i));
#endfor
#fclose(outfile);
#cleanup
clear *;
#printf("...done\n\n");
