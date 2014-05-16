1  #! /usr/bin/octave -q
2  #take the MWP- bg-spline.dat file supplied as commandline arg 1
3  #and compare the points with the profile to get a relative template of the bg
4  #this then gets applied to the profile supllied via commandline arg 2
5  #
6  #pretty dumb prelim thing does not check ANYTHING
7  puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8  
9  source("~/.mbk/octave.defaults");
10 
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14
15 #this is fixed, not via command line so if you want it another way
16 #just edit here
17
18 #
19 #############################################################
20 #
21
22 #now the following scheme: we will parse both profiles and since the bg-spline.dat is ordered we will search until the first pointwhich is larger
23 #then the first bg xcoordinate, remember both index values then set the new search point the second bg point....
24 #each time checking that there is a next bg point; if not, break the search.
25
26 function the_indices = get_indices(coordinates,vector)
27 the_indices = [];
28 #start search for first coordinate
29 coord_index=1;
30 #now search
31 for i=1:length(vector)
32 if ( vector(i) >= coordinates(coord_index) )
33 the_indices=[the_indices ; i];
34 coord_index = coord_index+1;
35 if coord_index > length(coordinates)
36 break;
37 endif
38 endif
39 if i == length(vector)
40 the_indices=[the_indices ; i];
41 endif
42 endfor
43 if length(the_indices) != length(coordinates)
44 error("ERROR did not find as many indices as data points are expected!")
45 endif
46 endfunction
47
48 #
49 #############################################################
50 #
51
52
53 #------------------------------------
54 # parse command line
55 #------------------------------------
56
57 if ((nargin)!= 2)
58 printf("\n\tgenerate a fityk file from a bg-spline.dat_file");
59
60 printf("\n\tUsage: %s", program_name);
61 printf("\n\t\tbg-spline.dat_file");
62 printf("\n\t\tdouble_column_profile_file");
63 printf("\n\toutput of double_column_profile_file.bg-spline.dat \n");
64 exit;
65 endif
66
67 #------------------------------------
68 # BG Daten laden
69 #------------------------------------
70 #parse the commandline args set the filenames
71 bgdata_file=nth(argv,1);
72
73 # master_profile=strrep(bgdata_file,".bg-spline.dat",".dat");
74 master_profile=strrep(bgdata_file,".bg-spline.dat","");
75
76 new_profile=nth(argv,2);
77
78 #now check if we have same input and output files this happens when looping
79 if (strcmp(master_profile, new_profile) )
80 printf("\nNothing to do!\n");
81 exit;
82 endif
83
84 #first the bg points
85 data=[];
86 data = loadData(bgdata_file);
87 bgpointsx=data(:,1);
88 bgpointsy=data(:,2);
89
90 #now the corresponding profile
91 data=[];
92 data = loadData(master_profile);
93 masterprofile_x=data(:,1);
94 masterprofile_y=data(:,2);
95
96 #now the profile for which we want the bg-spline.dat
97 data=[];
98 data = loadData(new_profile);
99 newprofile_x=data(:,1);
100 newprofile_y=data(:,2);
101
102 clear data;
103
104 #now determine the indices where the base points of the bg-spline are
105 master_indices = get_indices(bgpointsx,masterprofile_x);
106 new_indices = get_indices(bgpointsx,newprofile_x);
107
108 #next determine the vector of multiples of the bg value
109 #for this take the average of plusminus no_of_avg_points
110 no_of_avg_points=2;
111
112 bg_relative_y=[];
113 for i=1:length(bgpointsx)
114 avg_y=-masterprofile_y(master_indices(i));
115 for j=0:no_of_avg_points
116 minor_index= master_indices(i)-j;
117 major_index= master_indices(i)+j;
118
119 if (minor_index<1) minor_index=major_index; endif
120 if (major_index>length(masterprofile_y)) major_index=minor_index; endif
121
122 avg_y=avg_y+masterprofile_y(minor_index)+masterprofile_y(major_index);
123 endfor
124 avg_y=avg_y/(2*no_of_avg_points+1);
125 bg_relative_y=[bg_relative_y; bgpointsy(i)/avg_y];
126 endfor
127
128 new_bgpointsx=[];
129 new_bgpointsy=[];
130
131 for i=1:length(bgpointsx)
132 avg_y=-newprofile_y(new_indices(i));
133 for j=0:no_of_avg_points
134 minor_index= new_indices(i)-j;
135 major_index= new_indices(i)+j;
136
137 if (minor_index<1) minor_index=major_index; endif
138 if (major_index>length(newprofile_y)) major_index=minor_index; endif
139
140 avg_y=avg_y+newprofile_y(minor_index)+newprofile_y(major_index);
141 endfor
142 avg_y=avg_y/(2*no_of_avg_points+1);
143 new_bgpointsx=[new_bgpointsx; newprofile_x(new_indices(i))];
144 new_bgpointsy=[new_bgpointsy; avg_y*bg_relative_y(i)];
145 endfor
146
147 #newspline=spline(new_bgpointsx, new_bgpointsy, newprofile_x);
148 #gset("logscale y");
149 #gset("mouse");
150 #plot(newprofile_x, newspline, newprofile_x, newprofile_y);
151 #pause;
152 #write data
164
153
154 outfname=strcat(new_profile,".bg-spline.dat");
155 # puts("Writing Data to file: " outfname "\n");
156
157 [outfile, msg] = fopen(outfname,"wt");
158 if outfile == -1
159 error("no writing Data to Data File:\t %s \n",msg)
160 endif
161 #write the data!
162 for i=1:length(bgpointsx)
163 fprintf(outfile,"%#.9g\t%#.10g\n",new_bgpointsx(i), new_bgpointsy(i));
164 endfor
165 fclose(outfile);
166
167 #cleanup
168 clear *;
