1 #! /usr/bin/octave -q
2 #take the fityk .peaks file supplied as commandline arg 1
3 #and convert the data to a peak index file without the hkl
4 # maybe think of something else
5 #
6 #pretty dumb prelim thing does not check ANYTHING
7 puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14
15 #original Williamson Hall
16 #plot k vs deltak or deltabeta
17 #modified:
18 #plot C_bar*k^2 vs deltak or deltabeta
19
20 plot_fits=’n’; #y/n
21
22 ###############################################
23 #
24 # Function for cub mod WH to be fitted
25 #
26 # [Ungar Revesz Borbely, JAC 31 p554]
27 #
28 # \delta K = 0.9/D + \sqrt{\pi A b^2/2} \rho^{1/2} K*C^{1/2}
29 # + (\pi A’ b^2/2) Q^{1/2} K^2 C
30 # = 0.9/D + a_1 K sqrt(1+qH^2) + a_2 K^2 (1+qH^2)
31 #
32 # x are k and h^2
33 # p are
34 # p(1) = 0.9/D
35 # typical value 0.018, D=50nm
36 # p(2) = q
37 # p(3) = a_1
38 # typical value 0.003, A=1
39 # p(4) = a_2
40 # typical value 0.3, A’=1,Q=1 normally Q=0?
41 #
42 ################################################
43 function y = wh(x,p)
44 ksqrtc=x(:,1).*sqrt(1+p(2)*x(:,2));
45 y = p(1) + p(3)* ksqrtc + p(4)* ksqrtc.*ksqrtc ;
46 endfunction
47
48 #this is fixed, not via command line so if you want it another way
49 #just edit here
50
51 #
52 #############################################################
53 #
54
55 #------------------------------------
56 # parse command line
57 #------------------------------------
58
59 if !( (nargin)== 2 || (nargin)==3 )
60 printf("\n\tDo a fitted Williamson Hall analysis from a fityk.peaks_file");
61 printf("\n\tUsage: %s", program_name);
62 printf("\n\t\t.peaks_file");
63 printf("\n\t\tq parameter for modified");
64 printf("\n\t\toptional: parameter for beta’ with sf’s\n");
65 printf("\n\toutput of analysis results in datafile.wh file\n");
66 exit;
67 endif
68
69 #------------------------------------
70 # Daten laden
71 #------------------------------------
72 data=[];
73 data_file=nth(argv,1);
74 qcontrast=str2num(nth(argv,2));
75 if ( (nargin)==3 )
76 betaprime=str2num(nth(argv,3));
77 else
78 betaprime=0;
79 endif
80 # printf("\t %s is processing: %s \t",program_name(),data_file);
81 #the wavelength in nm
82 #Mo lambda=0.077;
83 #Cu
84 lambda=0.154;
85 #Co lambda=0.178892;
86 #Hasy lambda=0.0155;
87 #kit lambda=0.070849154;
88
89
90
91 #this is for good profiles with same peakset
92 #kit1_pd peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;4,0,0;3,3,1;4,2,0;4,2,2;3,3,3];
93 #cu_tr17 peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;4,0,0];
94 #ag_tr22 peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;4,0,0;3,3,1;4,2,0];
95 #ag_tr22_reduced peaklist=[2,0,0;2,2,0;3,1,1;2,2,2;4,0,0;4,2,0];
96 #Fe_hasy full peaklist=[1,1,0;2,0,0;2,1,1;2,2,0;3,1,0;2,2,2;3,2,1];
97 #Fe_hasy reduced peaklist=[1,1,0;2,0,0;2,1,1;2,2,0;3,1,0;3,2,1];
98 #Cu_hasy peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;3,3,1;4,2,0];
99
100 #Fe_hasy_mk peaklist=[1,1,0;2,0,0;2,1,1;2,2,0;3,2,1];
101 #Cu_hasy_mk peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;4,2,0];
102 #Cu_hasy_mk_05_08_fwhm peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;4,2,0];
103
104 #Ti Tr17 full peaklist=[102;110;103;200;112;021;203;210;121;114;122;015];
105 #ni_Tr21 peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;3,3,1;4,2,0];
106 #a220_steel peaklist=[1,1,1;2,0,0;2,2,0;3,1,1;2,2,2;3,3,1;4,2,0];
107 #scutter peaklist=[3,1,0;3,2,1;3,3,0;2,4,0;3,3,2;4,2,2;3,4,1;3,5,0;6,0,0;5,3,2;6,3,1;3,7,0;5,6,3;6,6,0;4,7,3];
108 #scutter_long
109 peaklist=[3,1,0;3,2,1;3,3,0;2,4,0;3,3,2;4,2,2;3,4,1;3,5,0;6,0,0;5,3,2;6,2,2;6,3,1;4,4,4;4,5,3;6,3,3;3,7,0;7,3,2;6,4,4;5,6,3;6,6,0;4,7,3];
110 #scutter_short peaklist=[3,1,0;3,2,1;3,3,0;2,4,0;4,2,2;3,4,1;3,5,0;6,0,0;5,3,2;6,3,1;3,7,0;5,6,3;6,6,0;4,7,3];
111 #scutter_shorter peaklist=[3,1,0;3,2,1;3,3,0;2,4,0;3,4,1;3,5,0;6,0,0;5,3,2;6,3,1;3,7,0;5,6,3;6,6,0;4,7,3];
112
113
114 #instrumental correction in theta fwhm or beta;
115 instcorr=0.12 #0 #.15,zhangSigunier #0.28
116
117 #just enter the peaks above and check the printout
118 peakpos=[];
119 peakint=[];
120 peakarea=[];
121 peakfwhm=[];
122 peakbeta=[];
123 [openedfile, msg] = fopen(data_file,"rt");
124 if openedfile == -1
125 error("LoadData - Data File:\t %s \n",msg)
126 endif
127 while (feof(openedfile) == 0)
128 line=fgetl(openedfile);
129 if (
130 line != -1 && \
131 (
132 ( strfind(line,"Pearson7") ) || \
133 ( strfind(line,"Voigt") )
134 )
135 )
136 if ( (line(1) != ’#’) && (line(16) != "6") )
137 # [thedata,counts] = sscanf(line,"%%_%i SplitPearson7 %g %g %g %g %g %g %g %g %g %g");
138 # [thedata,counts] = sscanf(line,"%%_%i Pearson7 %g %g %g %g %g %g %g %g");
139 [thedata,counts] = sscanf(line,"%%_%i PseudoVoigt %g %g %g %g %g %g %g %g");
140
141 #we got
142 # Peakno PeakType Center Height Area FWHM a0 a1 a2 a3
143 #
144 peakpos=[peakpos ; thedata(2)];
145 peakint=[peakint ; thedata(3)];
146 peakarea=[peakarea ; thedata(4)’];
147 peakfwhm=[peakfwhm ; thedata(5)’-instcorr];
148 peakbeta=[peakbeta ; (thedata(4)/thedata(3))-instcorr];
149 endif
150 endif
151 endwhile;
152 fclose(openedfile);
153 numpeaks=length(peakpos)
154
155 #compute K, deltaK, betainK and H^2
156 kvalue=[];
157 deltak=[];
158 b=[];
159 h2=[];
160 xs=[];
161 Wg=[];
162
163 for i=1:numpeaks
164 currentk=( (2/lambda) * sin(pi*peakpos(i)/360) );
165 kvalue=[kvalue; currentk];
166
167 currentdk=( (2/lambda) *(peakfwhm(i)*pi/360) *cos(pi*peakpos(i)/360) );
168 deltak=[deltak; currentdk];
169
170 currentb=( (2/lambda) *(peakbeta(i)*pi/360) *cos(pi*peakpos(i)/360) );
171 b=[b;currentb];
172 h=peaklist(i,1);
173 k=peaklist(i,2);
174 l=peaklist(i,3);
175 switch( peaklist(i,:) )
176 case {[1,1,1] [2,2,2] [3,3,3]}
177 Wg=[Wg;0.43];
178 case {[2,0,0] [4,0,0]}
179 Wg=[Wg;1.0];
180 case {[2,2,0] [4,2,0]}
181 Wg=[Wg;0.71];
182 case {[3,1,1]}
183 Wg=[Wg;0.45];
184 otherwise
185 Wg=[Wg;0.0];
186 endswitch
187 currenth2=(h^2*k^2+h^2*l^2+k^2*l^2)/(h^2+k^2+l^2)^2;
188 h2=[h2;currenth2];
189 #these give the measured independent variables for our wh function
190 xs=[xs;currentk,currenth2];
191 endfor
192
193 printf("\nOriginal Williamson Hall K vs DeltaK\n");
194
195 #now the original WH plot
196 # k vs deltak
197 originalwh_fwhm=[kvalue,deltak];
198 originalwh_beta=[kvalue,b];
199
200 #integral breadth variant
201 xplot=originalwh_beta(:,1);
202 yplot=originalwh_beta(:,2);
203
204 #FWHM as calc base
205 # xplot=originalwh_fwhm(:,1);
206 # yplot=originalwh_fwhm(:,2);
207
208
209 p=polyfit(xplot,yplot,1);
210 slope=p(1)
211
212 intercept=p(2)
213 D=0.9/p(2)
214
215 #error_chk
216 x=xplot’;y=yplot’; %from row vector to column vector.
217 Sxx=sum((x-mean(x)).^2);
218 Syy=sum((y-mean(y)).^2);
219 Sxy=sum((x-mean(x)).*(y-mean(y)));
220 SSE=Syy-slope*Sxy;
221 n=length(xplot);
222 S2yx=SSE/(n-2);
223 #correlation coeff:
224 Sb=sqrt(S2yx/Sxx);
225 A=0;
226 t=(slope-A)/Sb;
227 R2=1-2*(1-tcdf(abs(t),n-2))
228
229 regx=xplot;
230 regy=slope.*xplot+intercept;
231
232 if ( plot_fits == ’y’ )
233 ## plot(xplot,yplot,"@-",regx,regy,"-",x1plot,y1plot,"o");
234 plot(xplot,yplot,"@",regx,regy,"-");
235 pause;
236 endif
237
238 slopeorig=slope;
239 interceptorig=intercept;
240 R2orig=R2;
241 Dorig=D;
242
243
244 #make th linear regression and take the D and qho parameters from there and enter the modified pocedure.
245 #need the parameters still
246 #FIXME the results from GADDS are strongly scattering really irreproducible. i think the best is to enter a q range and then go ahead and
247 # calculate one data set for each q.... make an array and put the corresponding values into it or so and then make a script to plot the stuff...
248
249 #the parameters alpha gamma q
250 alpha=0.18;
251 #D=50nm
252 #qcontrast=2.4;
253 gamma=0.0000052;
254 #pinit=[alpha;qcontrast];
255 Ch00=0.3
256
257 printf("\nModified Williamson Hall K*Sqrt(C_bar) vs DeltaK with q=%g\n",qcontrast);
258
259 #######################################################
260
261 xplot=[];
262 yplot=b;
263 # yplot=deltak;
264 for i=1:numpeaks
265 currentxp=kvalue(i)*sqrt(Ch00*(1-qcontrast*h2(i)));
266 # currentxp=(kvalue(i)^2)*Ch00*(1-qcontrast*h2(i));
267 xplot=[xplot;currentxp];
268 endfor
269 modwh_beta=[xplot,yplot];
270
271 p=polyfit(xplot,yplot,1);
272 slope=p(1)
273
274 intercept=p(2)
275 D=0.9/p(2)
276
277 #error_chk
278 x=xplot’;y=yplot’; %from row vector to column vector.
279 Sxx=sum((x-mean(x)).^2);
280 Syy=sum((y-mean(y)).^2);
281 Sxy=sum((x-mean(x)).*(y-mean(y)));
282 SSE=Syy-slope*Sxy;
283 n=length(xplot);
284 S2yx=SSE/(n-2);
285 #correlation coeff:
286 Sb=sqrt(S2yx/Sxx);
287 A=0;
288 t=(slope-A)/Sb;
289 R2=1-2*(1-tcdf(abs(t),n-2))
290
291 regx=xplot;
292 regy=slope.*xplot+intercept;
293
294 if ( plot_fits == ’y’ )
295 # plot(xplot,yplot,"o",regx,regy,"-",x1plot,y1plot,"@-");
296
297 plot(xplot,yplot,"@",regx,regy,"-");
298 pause;
299 endif
300
301 slopemod=slope;
302 interceptmod=intercept;
303 R2mod=R2;
304 Dmod=D;
305
306 #now quadratic
307 p=polyfit(xplot,yplot,2);
308
309 quadr=p(1)
310 slopequadr=p(2)
311
312 interceptquadr=p(3)
313 Dquadr=0.9/p(3)
314
315 quadrx=sort(xplot);
316 quadry=quadr*quadrx.*quadrx+slopequadr*quadrx+interceptquadr;
317
318 if ( plot_fits == ’y’ )
319 plot(xplot,yplot,"@",quadrx,quadry,"-");
320 pause;
321 endif
322 #missing R2 for quadrat variant
323 R2quadr=-1;
324
325 ##############
326 #FIXME make a macro or similar
327
328 printf("\nModified Williamson Hall K*Sqrt(C_bar) vs DeltaK with q=%g and beta=%g\n",qcontrast,betaprime);
329
330 #######################################################
331
332 xplot_sf=xplot;
333 yplot_sf=b-betaprime*Wg;
334 # yplot=deltak;
335
336 p=polyfit(xplot_sf,yplot_sf,2);
337
338 quadr_sf=p(1)
339 slopequadr_sf=p(2)
340
341 interceptquadr_sf=p(3)
342 Dquadr_sf=0.9/p(3)
343
344 quadrx_sf=sort(xplot_sf);
345 quadry_sf=quadr_sf*quadrx_sf.*quadrx_sf+slopequadr_sf*quadrx_sf+interceptquadr_sf;
346
347 if ( plot_fits == ’y’ )
348 plot(xplot_sf,yplot_sf,"@",quadrx_sf,quadry_sf,"-");
349 pause;
350
351 # plot(xplot_sf,yplot_sf);
352 endif
353
354 #write data
355 outfname=strcat(data_file,".wh");
356 # puts("Writing Data to file: " outfname "\n");
357 [outfile, msg] = fopen(outfname,"wt");
358 if outfile == -1
359 error("no writing Data to Data File:\t %s \n",msg)
360 endif
361 fprintf(outfile,"#origWHx\torigWHy\tmodWHx\tmodWHy\tmodWHy_sf\th,k,l\tH^2\tW(g)\n");
362 fprintf(outfile,"#lambda=%g\n#Ch00=%g\n",lambda,Ch00);
363 fprintf(outfile,"#slopeorig=%g\n#rho=\n#interceptorig=%g\n#Dorig=%g\n#R2orig=%g\n",slopeorig,interceptorig,Dorig,R2orig);
364 fprintf(outfile,"#slopemod=%g\n#rho=\n#interceptmod=%g\n#Dmod=%g\n#R2mod=%g\n#q=%g\n",slopemod,interceptmod,Dmod,R2mod,qcontrast);
365 fprintf(outfile,"#slopemodquadr=%g\n#rho=\n#quadr=%g\n#interceptquadr=%g\n#Dquadr=%g\n#R2quadr=%g\n#q=%g\n",slopequadr,quadr,interceptquadr,Dquadr,R2quadr,qcontrast);
366 fprintf(outfile,"#slopemodquadr_sf=%g\n#rho_sf=\n#quadr_sf=%g\n#interceptquadr_sf=%g\n#Dquadr_sf=%g\n#R2quadr_sf=%g\n#q=%g\n#betaprime=%g\n",slopequadr_sf,quadr_sf,interceptquadr_sf,Dquadr_sf,R2quadr,qcontrast,betaprime);
367
368 for i=1:length(peakpos)
369 #this is for peaklist operation
370 fprintf(outfile,"%g\t%g\t%g\t%g\t%g\t%i,%i,%i\t%g\t%g\n",originalwh_beta(i,1),originalwh_beta(i,2),modwh_beta(i,1),modwh_beta(i,2),yplot_sf(i),peaklist(i,:),h2(i),Wg(i));
371 endfor
372 fclose(outfile);
373 #cleanup
374 clear *;
375 exit;
376
377
378 ################old below
379 # xplot=[];
380 # yplot=[];
381 # for i=1:numpeaks
382 # currentxp=kvalue2(i)*gamma*(1+qcontrast*h2(i));
383 # xplot=[xplot;currentxp];
384 ## currentyp=deltak2(i);
385 # currentyp=b2(i);
386 # yplot=[yplot;currentyp];
387 # endfor
388 # gset xlabel "c*k^2"
389 # gset ylabel "deltak^2"
390 ## plot(xplot,b2,"@",xplot,deltak2);
391 ## pause;
392 ##now fit
393 #for i=1:10
394 # gamma=0.0000008*2*i;
395 # xfit=[gamma*xs(:,1), xs(:,2)];
396 # yfit=deltak2;
397 ## yfit=b2;
398 # [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
399 # leasqr(xfit,yfit,pinit,"wh");
400 # alpha=pfit(1)
401 # qcontrast=pfit(2)
402 ## bgamma=pfit(3);
403 # gamma
404 # xplot=[];
405 # yplot=[];
406 # for i=1:numpeaks
407 # currentxp=kvalue2(i)*gamma*(1+qcontrast*h2(i));
408 # xplot=[xplot;currentxp];
409 # currentyp=yfit(i);
410 # yplot=[yplot;currentyp];
411 # endfor
412 # plot(xplot,yplot,"@",xplot,alpha+xplot);
413 # pause;
414 #endfor
415
416
417
418 % general linear regression
419 %
420 % [p,y_var,r,p_var]=LinearRegression(F,y)
421 % determine the parameters p_j (j=1,2,...,m) such that the function
422 % f(x) = sum_(i=1,...,m) p_j*f_j(x) fits as good as possible to the
423 % given values y_i = f(x_i)
424 %
425 % parameters
426 % F n*m matrix with the values of the basis functions at the support points
427 % in column j give the values of f_j at the points x_i (i=1,2,...,n)
428 % y n column vector of given values
429 % weight n column vector of given weights
430 %
431 % return values
432 % p m vector with the estimated values of the parameters
433 % y_var estimated variance of the error
434 % r weighted norm of residual
435 % p_var estimated variance of the parameters p_j
436
437 ###########################################
438 # for computing the dk^2/k^2 vs h^2 plot
439 ###########################################
440 alpha = p(1)^2;
441 scale =10^9;
442 for i=1:numpeaks
443 currentxp=h2(i);
444 xplot=[xplot;currentxp];
445 currentyp=scale*(deltak(i)^2 - alpha) / kvalue(i)^2;
446 yplot=[yplot;currentyp];
447 endfor
448 # gset xlabel "h^2"
449 # gset ylabel "deltak^2-alpha/k^2 * 10^5"
450 plot(xplot,yplot,"@");
451 #chk plot(xplot,yplot,"@",xplot,scale*p(3)*(1+qcontrast*xplot));
452 pause;
