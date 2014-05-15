1 #! /usr/bin/octave -q
2 #take the profile supplied as commandline arg 1
3 #and dividing the all the intensity by the value
4 #at the begining of the profile
5 #
6 #pretty dumb prelim thing does not check ANYTHING
7 puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14 #LOADPATH=["~/bin//:", LOADPATH];
15 addpath(genpath("~/bin/"));
16 #
17 #############################################################
18 #
19
20 #------------------------------------
21 # parse command line
22 #------------------------------------
23
24 if ((nargin)!= 1)
25 printf("\n\ttake a single peak, double_column_profile_file ");
26 printf("\n\tand apply the momentum method");
27 printf("\n\tUsage: %s", program_name);
28 printf("\n\t\tdouble_column_profile_file");
29 printf("\n\tyou can switch in the script if you use k or 2theta files");
30 printf("\n\toutput of momentumfiles and fitresults \n");
31 exit;
32 endif
33
34 #------------------------------------
35 # Daten laden
36 #------------------------------------
37 data=[];
38 data_file=nth(argv,1);
39 printf("\t %s is processing: %s \n",program_name(),data_file);
40 data = loadData(data_file);
41
42 # lambda=0.070849154;
43 lambda=0.154;
44 bg=0.0;
45
46 # k und counts Vektor uebernehmen
47 xvalue=data(:,1);
48 yvalue=abs(data(:,2)-bg);
49
50 #change to k = 2 * sin (theta) /lambda
51 kvalue=2*sin(xvalue*pi/360)/lambda;
52 #if data already in k use this:
53 # kvalue=xvalue;
54
55 #compute center of mass of all that is 0.05*ymax
56 k_temp=kvalue( find( yvalue > (0.05*max(yvalue)) ) );
57 y_temp=yvalue( find( yvalue > (0.05*max(yvalue)) ) );
58
59 deltaki = ( k_temp(1) - k_temp(length(k_temp)) )/length(k_temp);
60 com=sum(k_temp .* y_temp * deltaki)/sum(y_temp*deltaki)
61 #1.5 seems to be a good multiplier for KIT2 data,
62 #lowering a bit though
63 peakrange=1.5*abs( min([max(k_temp)-com, min(k_temp)-com]) )
64
65 #the q value at which the peak ends (above the scatter gets too much)
66 # qmax=0.146; #-1 for no cutting! set below!
67 qmax=-1;
68 #can try use automatic to peakrange below
69 # qmax=peakrange;
70 #set to nonpos to disable feature
71 #set to peakrange to attempt determination of outer range
72
73 # plot (k_temp,y_temp);
74 # pause;
75
76 clear k_temp;
77 clear y_temp;
78 clear deltaki;
79 #determine max of peak
80 #and the position of the com
81 [offset, comindex]=min(abs(kvalue-com));
82 [ymax, maxindex]=max(yvalue);
83 kmax = kvalue(maxindex);
84 peakcenter=kvalue(comindex);
85 # peakcenter=kvalue(maxindex);
86
87 #determine the outer bounds of the profile
88 deltak = 0;
89 if peakcenter - kvalue(1) > kvalue(length(kvalue))-peakcenter
90 deltak = kvalue(length(kvalue)) - peakcenter;
91 else
92 deltak = peakcenter - kvalue(1);
93 endif
94 deltak;
95 #make a profile centered around com
96 shortx=[xvalue(comindex)];
97 shortk=[kvalue(comindex)];
98 shorty=[yvalue(comindex)];
99 i=1;
100 while ( ((comindex-i)>0) && ((comindex+i)<length(kvalue)) )
101 shortx=[xvalue(comindex-i);shortx;xvalue(comindex+i)];
102 shortk=[kvalue(comindex-i);shortk;kvalue(comindex+i)];
103 shorty=[yvalue(comindex-i);shorty;yvalue(comindex+i)];
104 i=i+1;
105 endwhile
106
107 shortx=shortx-xvalue(comindex);
108 shortk=shortk-kvalue(comindex);
109 #normalize the profile on the fly
110 shorty=shorty/max(shorty);
111 #com-max(kvalue)
112 [max,maxi]=max(shorty( find( shorty<= 0.5) ));
113 fwhm=2*abs(shortk(maxi))
114
115 #plot(shortk, shorty); pause;
116
117
118 if (qmax > 0)
119 #to limit the use of a certain xvalue to prevent the bg scatter to add up....
120 #must be set to data by inspection!
121 #using that x><y gives vectors of 0,1 => product is boolean and!
122 #this works as range BUT! it does sometimes give different numbers of pos and neg values => troubles
123 #valid_range=find( (shortk >= -qmax) .* (shortk <= qmax) );
124 #thus we just check the negative side and take the same no of points for the pos vals
125
126 upperq_index=min(find(shortk > qmax));
127 if (length(upperq_index) == 0)
128 upperq_index=length(shortk)
129 endif
130 comindex=find(shortk == 0);
131 valid_range=[ (2*comindex-upperq_index):comindex (comindex+1):upperq_index];
132
133
134 shortx1=shortx(valid_range);
135 shortk1=shortk(valid_range);
136 shorty1=shorty(valid_range);
137 clear valid_range upperq_index;
138
139 # plot(shortk, shorty,shortk1,shorty1);
140 # pause;
141 #we only needed the *1 for plotting to see if it is ok, now lets just continue dropping the "1"
142 # length(find(shortk1>0))
143 # length(find(shortk1<0))
144
145 shortk=shortk1;
146 shorty=shorty1;
147 shortx=shortx1;
148 clear shortk1 shorty1 shortx1;
149 endif
150
151 #length(shortx)
152 #length(shorty)
153
154 #gset("mouse");
155 #gset("logscale y");
156 #gset("arrow 1 from com,0.1 to com, nohead");
157 #gset("show arrow");
158 #semilogy(shortk,shorty,"@",[0;0],[0;1],"-");pause;
159
160 # now compute an array of the M_n(q_i)= M_n^i
161 #some initial stuff
162 #the number of momenta to compute
163 nummoments=4;
164 #the no of our datapoints
165 numpoints=length(shortk);
166
167 #our vectors go from -l to l therefore i=(m-1)/2
168 #M_n^i=\Sum_{k=-l}^l \Delta q_k*q_k^n*I_k
169 #so our quantities are:
170 m_n=[]; #empty array
171 #the q values are just our symmetric k values so the vector of q==shortk
172 #we also need the vector of the deltaq we do this via a loop:
173 #the first value is easy, but we want a symmetric deltaq value vector so:
174 deltaqi=[(shortk(2)-shortk(1))];
175 for i=2:(numpoints-1)
176 deltaqi=[deltaqi;(shortk(i+1)-shortk(i-1))/2];
177 endfor
178 #last value the other way as the first
179 deltaqi=[deltaqi;(shortk(numpoints)-shortk(numpoints-1))];
180 #now a trick we need the product of deltaq*I*q^n for the computation of the moments
181 #so we set:
182 qni=shorty.*deltaqi; #this equals q_i^0*I(q_i)*deltaq_i
183
184 #now for the real integration#
185 #our array starts with the first moment
186 for n=1:nummoments
187 #first we multiply with q=shortk so we get overall q^n*I*deltaq for each n
188 qni=shortk.*qni;
189 #now for each n compute the vector of its values for each q_i via a sum
190 #the first value for the moment is zero because we start at the center => q_0=0 per def
191 lastm_nofi=0;
192 currentm_n=[0];
193 #we then just add the points around the center already known to successively create the vector of the moments
194 #yet do not forget that the moment needs to be normalized in the end
195 for i=1:( (numpoints-1 )/2 )
196 currentm_nofi=qni(-i+(numpoints+1)/2) + lastm_nofi + qni(i+(numpoints+1)/2);
197 lastm_nofi=currentm_nofi;
198 currentm_n=[currentm_n;currentm_nofi];
199 endfor
200 m_n=[m_n,currentm_n];
201 endfor
202 #finally the moments need to be normalized by the \int_-\infty^\infty dq I(q)
203 #well we cannot do this as we only have portion of the profile thus we normlize by the area we have, the rest is small (we hope)
204 #first try but not robust against non equal spaced vectors:
205 #area=sum(shorty)*(abs(shortk(1))+shortk(length(shortk)))/numpoints;
206 #so better
207 area=sum(shorty.*deltaqi);
208 m_n=m_n/area;
209 #
210 #next we need the xscale computed the moment got as independent variable the q as from \int_-q^q
211 #we do not have this properly so we take the average of the two points corresponding to the values used above:
212 #so we can use the same formula in principle
213 the_q=[0]; #the inner point is zero anyway ;)
214 for i=1:( (numpoints-1 )/2 )
215 currentq=(abs(shortk(-i+(numpoints+1)/2)) + abs(shortk(i+(numpoints+1)/2)))/2;
216 the_q=[the_q,currentq];
217 endfor
218
219 #now plot the results
220 for n=1:nummoments
221 #gset ("mouse");
222 titlestring=sprintf("title \"the %ith Moment\"",n);
223 #gset (titlestring);
224 #gset("terminal postscript color");
225 #gset("output \"fourier_coeff_bg.ps\"");
226 # plot(the_q,m_n(:,n),"@");pause;closeplot;
227 endfor
228 #gset ("mouse");
229 #gset ("title \"the 4th Moment per q squared\"");
230 #gset("terminal postscript color");
231 #gset("output \"fourier_coeff_bg.ps\"");
232
233 the_q=transpose(the_q);
234 # plot(the_q,((m_n(:,4))./the_q) ./the_q ,"@");pause;closeplot;
235 # plot(the_q,( m_n(:,4) ./ (the_q.*the_q) ),"-");pause;closeplot;
236
237
238 #debug entry for comparing...
239 #data_file=strcat(data_file,"_no_norm");
240
241 ################# dump the data first! ###############
242 #"zero" file => x,k,y centered around com
243 outfname = strcat(data_file,".xky");
244 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
245
246 fprintf(outfile,"#x\tk\ty\n");
247 #write the data!
248 for i=1:length(shortx)
249 fprintf(outfile,"%#.9g\t%#.9g\t%#.10g\n",shortx(i),shortk(i),shorty(i));
250 endfor
251 fclose(outfile);
252
253 result= m_n(:,2);
254 outfname = strcat(data_file,".m2");
255 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
256
257 #write the data!
258 for i=1:length(the_q)
259 fprintf(outfile,"%#.9g\t%#.10g\n",the_q(i),result(i));
260 endfor
261 fclose(outfile);
262
263 result= m_n(:,3);
264 outfname = strcat(data_file,".m3");
265 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
266
267 #write the data!
268 for i=1:length(the_q)
269 fprintf(outfile,"%#.9g\t%#.10g\n",the_q(i),result(i));
270 endfor
271 fclose(outfile);
272
273 result= m_n(:,4)./(the_q.*the_q);
274 outfname = strcat(data_file,".m4_per_q2");
275 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
276
277 #write the data!
278 for i=1:length(the_q)
279 fprintf(outfile,"%#.9g\t%#.10g\n",the_q(i),result(i));
280 endfor
281 fclose(outfile);
282
283 #FIXME
284 #exit;
285
286
287 #####################################################
288 ###
289 #### FITTTINGGGGG
290 ###
291 #####################################################
292
293 momentum_fit;
294 #puts("end fit");
295
296
297 #write data to file
298 # ###############SECOND MOMENT#####################
299 fitresult=m2theor(the_q,[m2_ef;m2_kappa;m2_rhostar;m2_q_0]);
300 result= m_n(:,2);
301 residua=(result-fitresult);
302 #gset("mouse");
303 #gset("logscale y");
304 #plot(the_q,result,the_q,fitresult,the_q,residua);pause;closeplot;
305 # outfname=strrep(data_file,".p00",".xy");
306 outfname = strcat(data_file,".m2_fit");
307 # puts("Writing Data to file: " outfname "\n");
308 #
309 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
310
311 #write the data!
312 for i=1:length(the_q)
313 fprintf(outfile,"%#.9g\t%#.10g\t%#.10g\t%#.10g\n",the_q(i),result(i),fitresult(i),residua(i));
314 endfor
315 fclose(outfile);
316
317 # ###############THIRD MOMENT#####################
318 fitresult=m3theor(the_q,[m3_P2;m3_q_1]);
319 result= m_n(:,3);
320 residua=result-fitresult;
321
322 outfname = strcat(data_file,".m3_fit");
323 # puts("Writing Data to file: " outfname "\n");
324 #
325 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
326 #write the data!
327 for i=1:length(the_q)
328 fprintf(outfile,"%#.9g\t%#.10g\t%#.10g\t%#.10g\n",the_q(i),result(i),fitresult(i),residua(i));
329 endfor
330 fclose(outfile);
331 # ###############FOURTH MOMENT#####################
332 fitresult=m4pq2theor(the_q,[m4pq2_ef;m4pq2_rhostar;m4pq2_flucrho;m4pq2_q_2]);
333 result= ( m_n(:,4) ./ (the_q.*the_q) );
334 residua=result-fitresult;
335
336 outfname = strcat(data_file,".m4_per_q2_fit");
337 # puts("Writing Data to file: " outfname "\n");
338 #
339 [outfile, msg] = fopen(outfname,’wt’);if outfile == -1 error("error open outfile File:\t %s \n",msg) endif
340 #write the data!
341 for i=1:length(the_q)
342 fprintf(outfile,"%#.9g\t%#.10g\t%#.10g\t%#.10g\n",the_q(i),result(i),fitresult(i),residua(i));
343 endfor
344 fclose(outfile);
345
346 #cleanup
347 clear *;
348 #printf("...done\n\n");
