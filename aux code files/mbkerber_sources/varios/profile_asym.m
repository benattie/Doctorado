1 #!/usr/bin/octave -q
2 #pretty dumb prelim thing does not check ANYTHING
3
4 puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
5
6 source("~/.mbk/octave.defaults");
7
8 #MBK_edit needed patch to run if string converions error!
9 implicit_num_to_str_ok=1;
10 implicit_str_to_num_ok=1;
11
12 #------------------------------------
13 # Daten laden
14 #------------------------------------
15 data=[];
16 data_file=nth(argv,1);
17 printf("\t %s is processing: %s \t",program_name(),data_file);
18 data = loadData(data_file);
19
20 # k und counts Vektor uebernehmen
21 x_in=data(:,1);
22 y_in=(data(:,2));
23 x=x_in( find(x_in>28.8676 & x_in<30.6156) );
24 y=y_in( find(x_in>28.8676 & x_in<30.6156) );
25 clear y_in, x_in;
26 y=y/max(y);
27
28 #the range is here every above 50%
29 xrange= x( find( y> (((max(y)-min(y))*0.9)+min(y)) ) );
30 yrange= y( find( y> (((max(y)-min(y))*0.9)+min(y)) ) );
31 #plot(x,yi,xrange,yrange);
32 #pause;
33
34 #compute center of mass
35 deltax = ( xrange(1) - xrange(length(xrange)) )/length(xrange);
36 com=sum(xrange .* yrange * deltax)/sum(yrange*deltax);
37 clear deltax;
38
39
40 xtemp=x-com; #new profile with mirror axis == 0
41 x_mirror_full=sort(-xtemp);
42 y_mirror_full=flipud (y);
43
44 # [x_diff,y_diff]=profile_add(xtemp,y,x_mirror_full,-y_mirror_full);
45
46 # plot(xtemp,y,x_mirror_full,y_mirror_full,x_diff,y_diff);
47 # pause
48
49 # for i=1:length(xrange)
50 # xtemp=x-xrange(i); #new profile with mirror axis == 0
51 # x_mirror_full=sort(-xtemp);
52 # y_mirror_full=flipud (y);
53
54 [x_diff_sub1,y_diff_sub1]=profile_add(xtemp,y,x_mirror_full,-y_mirror_full);
55
56 # plot(xtemp,y,x_mirror_full,y_mirror_full,x_diff_sub1,(y_diff_sub1));
57 # pause
58
59 #now mirror the latter at its max
60 [sub1_y_max,sub1_y_max_idx]=max(y_diff_sub1);
61 sub1_x_max=x_diff_sub1(sub1_y_max_idx);
62
63 x_sub1_temp=x_diff_sub1-sub1_x_max;
64
65 if ( sub1_x_max > 0 )
66 x_sub1=sort([x_sub1_temp( find( x_sub1_temp>0 ) ); x_sub1_temp( find( x_sub1_temp==0 ) ); -x_sub1_temp( find(x_sub1_temp>0 ) )]);
67 y_sub1=[flipud(y_diff_sub1( find( x_sub1_temp>0 ) )); y_diff_sub1( find( x_sub1_temp==0 ) );y_diff_sub1( find(x_sub1_temp>0 ) )];
68 else
69 x_sub1=sort([-x_sub1_temp( find( x_sub1_temp<0 ) ); x_sub1_temp( find( x_sub1_temp==0 ) ); x_sub1_temp( find(x_sub1_temp<0 ) )]);
70 y_sub1=[(y_diff_sub1( find( x_sub1_temp<0 ) )); y_diff_sub1( find( x_sub1_temp==0 ) );flipud(y_diff_sub1( find(x_sub1_temp<0 ) ))];
71
72 endif
73 x_sub1=x_sub1+sub1_x_max; #to have the sub where it should be in the bigger one x_temp
74 # plot(xtemp,y,x_sub1,y_sub1,x_diff_sub1,y_diff_sub1)
75 # pause;
76
77 # x_sub1=x_sub1+xrange(i); #move it back where the original profile is
78 x_sub1=x_sub1+com;
79
80 [x_sub2,y_sub2]=profile_add(x,y,x_sub1,-y_sub1); #calc the second one
81
82 deltax = abs( x(1) - x(length(x)) )/length(x);
83 areax=sum(abs(y)*deltax)
84 deltax = abs( x_sub1(1) - x_sub1(length(x_sub1)) )/length(x_sub1);
85 area_sub1=sum(abs(y_sub1)*deltax)/areax
86 deltax = abs( x_sub1(1) - x_sub1(length(x_sub1)) )/length(x_sub1);
87 area_sub2=sum(abs(y_sub2)*deltax)/areax
88 area_sub1+area_sub2
89
90 [y_sub1_max, y_sub1_maxidx]=max(y_sub1);
91 sub1_ymax_x=x_sub1(y_sub1_maxidx)
92 [y_sub2_max, y_sub2_maxidx]=max(y_sub2);
93 sub2_ymax_x=x_sub2(y_sub2_maxidx)
94
95 delta=(sub2_ymax_x-sub1_ymax_x)
96
97
98 # semilogy(x,y,x_sub1,y_sub1,x_sub2,y_sub2);
99 # sleep(0.2);
100 # pause;
101 # endfor
102
103 #output
104
105 outfname = strcat(data_file,".asymeval");
106 [outfile, msg] = fopen(outfname,’wt’);
107 if outfile == -1
108 error("LoadData - Data File:\t %s \n",
109 msg)
110 endif
111 fprintf(outfile,"sub1_f= %E\nsub2_f= %E\ndelta= %E",area_sub1, area_sub2, delta);
112 fclose(outfile);
113
114
115 outfname = strcat(data_file,".asymeval.sub1.xy");
116 [outfile, msg] = fopen(outfname,’wt’);
117 if outfile == -1
118 error("LoadData - Data File:\t %s \n",
119 msg)
120 endif
121 for i=1:length(y_sub1)
122 fprintf(outfile,"%E\t%E\n",x_sub1(i), y_sub1(i));
123 endfor
124 fclose(outfile);
125
126 outfname = strcat(data_file,".asymeval.sub2.xy");
127 [outfile, msg] = fopen(outfname,’wt’);
128 if outfile == -1
129 error("LoadData - Data File:\t %s \n",
130 msg)
131 endif
132 for i=1:length(y_sub2)
133 fprintf(outfile,"%E\t%E\n",x_sub2(i), y_sub2(i));
134 endfor
135 fclose(outfile);
