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
52
# res m sigma d l0 rho re m* epsilon stpr q
53
#important that the residuals are last as they determine our weights!
54
55
#dataset=strrep(data_file,".csv.tmp","");
56
57
numparam=length (results(1,:));
58
numlines=length (results(:,1));
59
60
#compute the averages
61
#the weights = minres/residuum => w(minres) := 1
62
w=results(1,3)./results(:,3);
63
64 # #now check if d or L0 are too large
65 # #and set corresponding weights to :=0
66 # w(find(results(:,6)>=1000))=0
67
68
#the sum over the weights for normalizing
69
sumw=sum(w);
70
71
#now normalize the weights
72
w=w./sum(w);
73
74
#the solution will look like: sampleno average absdev reldev .... for all parameters
75
solutions=[results(1,2)]; #line vector, first value of the solution is _any_ measurement value index. so from the first
row the second column
76
averages=[]; #the line vector of the average values to be assembled with the solutions and for the determination of the
physical min.
77
78
#average = sum_i wi*xi
79
#deviation = sqrt( sum_i wi*(xii-average)^2 )
80
#we start at column 3 since 1 and 2 are evalrun and sampleno
81
#if there was no error column should stay the sample no!
82
83
for i=3:numparam
84
85
xi=results(:,i);
86
87
do #do until loop for reduction of large errors!
88
avg=sum(xi.*w);
89
absdev=sqrt(sum( w.*(xi-avg).^2));
90
if (avg == 0)
91
avg=1.0e-32;
92
endif
93
reldev=100*absdev/avg;
94
if ( reldev >100 )
95
#if our reldev error is to high kick some results and recompute.
96
#instead of deleting we assign the average to the high values as to prevent errors with the weights
97
#the same way we still keep the tendency of the ausreisser in the evaluated data
98
oldxi=xi;
99
xi = [];
100
for j=1:length(oldxi)
101
if (abs(oldxi(j) - avg) > absdev)
102
xi=[xi; avg];
103
else
104
xi=[xi;oldxi(j)];
105
endif
106
endfor
107
endif
108
until (reldev <= 100) #end do loop
109
110
#for our plotting
111
#rho,rhoerr aka column 17,18 => i=5 must be *1000 to get 10^15
112
#and for m* and m*err (23,24) => i=7 we must multiply with 7
113
switch (i)
114
case (8)
115
avg=1000*avg;
116
absdev=1000*absdev;
117
case (10)
118
avg=7*avg;
119
absdev=7*absdev;
120
otherwise
121
endswitch
122
#unchanged solutions
123
solutions=[solutions,avg,absdev,reldev];
124
averages=[averages,avg];
125
endfor
126
#determine the representative solution. for this we calc (sum_i (param_i-avg)^2)and look for the smallest..
127
#fixme
128
#easiest make a vector of averages to match the solutions. the substract the avg from all the sols, square this, sum and
determine the min.
129
# V )
130
diff_avg=[];
131
for i=1:numlines
132
curr_diff_sumsq = sumsq(results(i,3:numparam) - averages);
133
diff_avg=[diff_avg;curr_diff_sumsq];
134
endfor
135
[minvalue, min_index] = min (diff_avg);
136
rep_sol=results(min_index,1);
137
min_sol=results(1,1);
138
#output the rep sol to the outfile.
139
#if we already did this once we need to replace that line..
140
command=sprintf("egrep -v \"rep_sol|min_sol\" %s.stat > %s.temp ",data_file,data_file);
141
system(command);
142
command=sprintf("echo \"rep_sol=%i\nmin_sol=%i\" >> %s.temp;mv %s.temp %s.stat",rep_sol,min_sol,data_file,data_file,
data_file);
143
system(command);
144
145
solstring=sprintf("%i",solutions(1));
146
for i=2:length(solutions)
147
solstring=strcat(solstring,sprintf("\t%#.5e",solutions(i)));
148
endfor
149
puts(strcat(solstring,"\n"));
#write data to file
#
outfname=strrep(data_file,".xy",".aqui.xy");
#
outfname = strcat(data_file,".aequi.dat");
#
puts("Writing Data to file: " outfname "\n");
#
[outfile, msg] = fopen(outfname,"wt");
#
if outfile == -1
#
error("error open outfile File:\t %s \n",msg)
#
endif
#
#write the data!
#
for i=1:i_max
#
fprintf(outfile,"%#.9g\t%#.10g\n",newxvalue(i), newyvalue(i));
#
endfor
#
fclose(outfile);
#cleanup
clear *;
#printf("...done\n\n");
