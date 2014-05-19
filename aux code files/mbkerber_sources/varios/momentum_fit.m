1 #! /usr/bin/octave -q
2 #take the fityk .peaks file supplied as commandline arg 1
3 #and convert the data to a peak index file without the hkl
4 # maybe think of something else
5 #
6 #pretty dumb prelim thing does not check ANYTHING
7 #puts("\n\t WARNING Hope you know what you are doing! \n\t This is an idiotUNproof script!\n\n");
8
9  source("~/.mbk/octave.defaults");
10
11 #MBK_edit needed patch to run if string conversions error!
12 implicit_num_to_str_ok=1;
13 implicit_str_to_num_ok=1;
14
15 #Settings
16 plot_fits=0;
17
18 ###############################################
19 #
20 # The theoretical function for the second order Moment
21 # x is the vector of q’s
22 # p are \epsilon_f, \kappa=L/2k^2, \bar c*\rho and q_0
23 # p(1) p(2) p(3) p(4)
24 #
25 ################################################
26 function y = m2theor(x,p)
27 # p(1)=abs(p(1));
28 # p(2)=abs(p(2));
29 # p(3)=abs(p(3));
30 p=abs(p);
31 q_0=p(4);
32 # q_0=1;
33 # kappa=p(2);
34 kappa=0; #for sperical crystallites!
35 y = (1/(2*pi^2))* ( 2*x/p(1) - kappa/(p(1)^2) + p(3)*(log(abs(x))-log(abs(q_0))) );
36 endfunction
37
38 ###############################################
39 #
40 # The theoretical function for the second order Moment
41 # here rho is set to zero so only size broadening is considered
42 # x is the vector of q’s
43 # p are \epsilon_f, \kappa=L/2k^2, \bar c*\rho and q_0
44 # p(1) p(2) p(3) p(4)
45 #
46 ################################################
47 function y = m2theor_size(x,p)
48 p=abs(p);
49 q_0=p(4);
50 # q_0=1;
51 shortp=[p(1);p(2);0;q_0];
52 y = m2theor(x,shortp);
53 endfunction
54
55
56 ###############################################
57 #
58 # The theoretical function for the third order Moment
59 # x is the vector of q’s
60 # p are P^2 and q_1
61 # p(1) p(2)
62 #
63 ################################################
64 function y = m3theor(x,p)
65 # q_1=abs(p(2));
66 q_1=p(2);
67 # q_1=1;
68 y = -(3/((2*pi)^3)) * ( p(1)*(log(abs(x))-log(abs(q_1))) );
69 endfunction
70
71 ###############################################
72 #
73 # The theoretical function for the fourth order Moment
74 # x is the vector of q’s
75 # p are \epsilon_f, \bar c*\rho , \bar c^2*avg(rho^2) and q_2
76 # p(1) p(2) p(3) p(4)
77 #
78 ################################################
79 function y = m4pq2theor(x,p)
80 p=abs(p);
81 # q_2=abs(p(3));
82 # p(1)=abs(p(1));
83 # p(2)=abs(p(2));
84 q_2=p(4);
85 # q_2=1;
86 # y = (1/(2*pi^2)) * ( 2.*x/(3*p(1)) +\
87 # (3*p(2)/2) * ( (1/3) + ( (1/p(1)) + p(2)*log(x/q_2)./x ) .* log(x/q_2)./x ) );
88 ########%%%%%%%%%%%another type
89 ln_qperq = (log(abs(x))-log(abs(q_2)))./x;
90 #as per ppt
91 #y= 1/(2*pi^2) * ( 2/(3*p(1)).*x + 3*p(2)/2 * ( 1/3 + ln_qperq / p(1) ) + (3/2)*p(3) .* ln_qperq .* ln_qperq ) ;
92 #as per paper
93 y= 1/(2*pi^2) * ( 2/(3*p(1)).*x + p(2)/2 + (3/2)*p(3) .* ln_qperq .* ln_qperq ) ;
94 endfunction
95
96 #FIXME NEXT NEEDS TO BE CHECKED!
97 ###############################################
98 #
99 # The theoretical function for the combined second and fourth order Moment
100 # x is the vector of q’s
101 # p from m2 are \epsilon_f, \kappa=L/2k^2, \bar c*\rho and q_0
102 # p(1) p(2) p(3) p(4)
103 # p from m4 are \epsilon_f, \bar c*\rho and q_2
104 # p(1) p(2) p(3)
105 # so the p here are \epsilon_f, \kappa=L/2k^2, \bar c*\rho q_0 and q_2
106 # p(1) p(2) p(3) p(4) p(5)
107 #
108 #
109 ################################################
110 function y = m2_and_m4pq2theor(x,p)
111 #init the return
112 y=[];
113
114 pm2=[p(1);p(2);p(3);p(4)];
115 for i=1:(length(x)/2)
116 y=[y;m2theor(x(i),pm2)];
117 endfor
118
119 pm4=[p(1);p(3);p(5)];
120 for i=(1+length(x)/2):length(x)
121 y=[y;m4pq2theor(x(i),pm4)];
122 endfor
123
124 endfunction
125
126 #this is fixed, not via command line so if you want it another way
127 #just edit here
128
129 #
130 #############################################################
131 #
132 #function result = momentum_fit.m()
133
134 #------------------------------------
135 # parse command line
136 #------------------------------------
137
138 if ((nargin)!= 1)
139 printf("\n\ttake an array of q, m_2, m_3, m4_per_q2 ");
140 printf("\n\tand fit the data to the theoretical prediction of the momentum method");
141 printf("\n\tUsage: %s", program_name);
142 printf("\n\t\tarray of q, m_n");
143 printf("\n\toutput none yet \n");
144 exit;
145 endif
146
147 #fitting params
148 maxit=100000;
149 precision=0.000001;
150 #the parameters
151 ef=50;
152 kappa=0;
153 rhostar=0.0005;
154 flucrho = 0.01;
155 P2=0.0;
156 q_0=1e-2;
157 q_1=1e-4;
158 q_2=1e-2;
159
160 #save the inits
161 ef_ini=ef;kappa_ini=kappa;rhostar_ini=rhostar;flucrho_ini=flucrho;P2_ini=P2;q0_ini=q_0;q1_ini=q_1;q2_ini=q_2;
162
163 fitrange=0.6;
164 m3fitrangescale=0.5;
165 # fitrange=0.35;
166
167 ###############################################################
168 #####
169 ##### The 2nd moment
170 #####
171 ###############################################################
172
173 #puts("################the 2nd moment###################\n");
174 #inow fit
175 pinit=[ef;kappa;rhostar;q_0];
176 # xfit=data(:,1);
177 # yfit=data(:,2);
178 xplot=the_q;
179 yplot=m_n(:,2);
180
181 min_index= length(xplot) - floor(fitrange*length(xplot));
182 max_index= length(xplot);
183 xfit=cut_vector( xplot, min_index, max_index);
184 yfit=cut_vector( yplot, min_index, max_index);
185 #show the fit data
186 # gset("title \"the 2nd moment\"");
187 ytheor=m2theor(xfit,pinit);
188 #plot init
189 # plot(xplot,yplot,"@",xfit,ytheor,"-");pause;closeplot;
190
191 #first without the rho
192 [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
193 leasqr(xfit,yfit,pinit,"m2theor_size",precision,maxit);
194 # #plot intermediate
195 # ytheor=m2theor(xfit,pfit);
196 # plot(xplot,yplot,"@",xfit,ytheor,"-");pause;closeplot;
197
198 #alternative:
199 # pfit=pinit;
200
201 #now with rho starting from above parameters
202 [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
203 leasqr(xfit,yfit,pfit,"m2theor",precision,maxit);
204
205 ef=pfit(1);
206 kappa=pfit(2);
207 rhostar=pfit(3);
208 q_0=pfit(4);
209
210 m2_ef=real(ef)
211 m2_kappa=real(kappa)
212 m2_rhostar=real(rhostar)
213 m2_q_0=real(q_0)
214
215 #show the fit data
216 ytheor=m2theor(xfit,pfit);
217 if plot_fits==1
218 plot(xplot,yplot,"o",xfit,ytheor,"-");pause; #closeplot;
219 endif
220
221 ###############################################################
222 #####
223 ##### The 3rd moment
224 #####
225 ###############################################################
226
227 #puts("################the 3rd moment###################\n");
228 #now fit
229 pinit=[P2;q_1];
230 # xfit=data(:,1);
231 # yfit=data(:,2);
232 xplot=the_q;
233 yplot=m_n(:,3);
234
235 #set the fitrange smaller here because this does not work as good
236 myfitrange=fitrange*m3fitrangescale;
237
238 min_index= length(xplot) - floor(myfitrange*length(xplot));
239 max_index= length(xplot);
240 xfit=cut_vector( xplot, min_index, max_index);
241 yfit=cut_vector( yplot, min_index, max_index);
242 #show the fit data
243 ytheor=m3theor(xfit,pinit);
244 #plot init
245 # gset("title \"The 3rd moment\"");
246 # plot(xplot,yplot,"@",xfit,ytheor,"-");pause;closeplot;
247
248 [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
249 leasqr(xfit,yfit,pinit,"m3theor",precision,maxit);
250 P2=pfit(1);
251 q_1=pfit(2);
252
253 m3_P2=real(P2)
254 m3_q_1=real(q_1)
255
256 #show the fit data
257 ytheor=m3theor(xfit,pfit);
258 if plot_fits==1
259 #gset("mouse");
260 plot(xplot,yplot,"o",xfit,ytheor,"-");pause;#closeplot;
261 endif
262 ###############################################################
263 #####
264 ##### The 4th moment
265 #####
266 ###############################################################
267
268 #puts("################the 4th moment###################\n");
269 #now fit
270 pinit=[ef;rhostar;flucrho;q_2];
271 # pinit=[ef_ini;rhostar_ini;flucrho_ini;q2_ini];
272 # xfit=data(:,1);
273 # yfit=data(:,2);
274 xplot=the_q;
275 yplot=m_n(:,4)./(the_q.*the_q);
276
277 min_index= length(xplot) - floor(fitrange*length(xplot));
278 max_index= length(xplot);
279 xfit=cut_vector( xplot, min_index, max_index);
280 yfit=cut_vector( yplot, min_index, max_index);
281 #show the fit data
282 ytheor=m4pq2theor(xfit,pinit);
283 #gset("title \"the 4th moment per q squared\"");
284 #plot init
285 # plot(xplot,yplot,"@",xfit,ytheor,"-");pause;closeplot;
286
287 [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
288 leasqr(xfit,yfit,pinit,"m4pq2theor",precision,maxit);
289 ef=pfit(1);
290 rhostar=pfit(2);
291 flucrho=pfit(3);
292 q_2=pfit(4);
293
294 m4pq2_ef=real(ef)
295 m4pq2_rhostar=real(rhostar)
296 m4pq2_flucrho=real(flucrho)
297 m4pq2_q_2=real(q_2)
298
299 #show the fit data
300 ytheor=m4pq2theor(xfit,pfit);
301 if plot_fits==1
302 #gset("mouse");
303 plot(xplot,yplot,"o",xfit,ytheor,"-");pause; #closeplot;
304 endif
305
306 #FIXME NUMBER TWO AS ABOVE
307 ###############################################################
308 #####
309 ##### combined 2nd and 4th moment
310 #####
311 ###############################################################
312
313 ##puts("################combined 2nd and 4th moment###################\n");
314 ##now fit
315 # pinit=[ef_ini;kappa_ini;rhostar_ini;q0_ini;q2_ini];
316 #
317 # xplot=the_q;
318 # y1plot=m_n(:,2);
319 # y2plot=m_n(:,4)./(the_q.*the_q);
320 #
321 # min_index= length(xplot) - floor(fitrange*length(xplot));
322 # max_index= length(xplot);
323 #
324 # xfit_small=cut_vector( xplot, min_index, max_index);
325 # xfit=[xfit_small;xfit_small];
326 # yfit=[cut_vector(y1plot, min_index, max_index); ...
327 # cut_vector(y2plot, min_index, max_index)];
328 #
329 ## plot(xfit,yfit,"@");pause;closeplot;
330 #
331 # #show the fit data
332 # ytheor=m2_and_m4pq2theor(xfit,pinit);
333 # gset("title \"the 2nd and the 4th moment per q squared\"");
334 ## plot(xplot,y1plot,"@",xplot,y2plot,"@",xfit,ytheor,"-");pause;closeplot;
335 # plot(xfit,yfit,"@",xfit,ytheor,"-");pause;closeplot;
336 #
337 #
338 # [f1, pfit, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
339 # leasqr(xfit,yfit,pinit,"m4pq2theor",precision,maxit);
340 # ef=pfit(1);
341 # kappa=pfit(2);
342 # rhostar=pfit(3);
343 # q_0=pfit(4)
344 # q_2=pfit(5)
345 #
346 # m2m4_ef=ef
347 # m2m4_kappa=kappa
348 # m2m4_rhostar=rhostar
349 # m2m4_q_0=q_0
350 # m2m4_q_2=q_2
351 #
352 # #show the fit data
353 # ytheor=m2_and_m4pq2theor(xfit,pfit);
354 # gset("title \"the 2nd and the 4th moment per q squared - fitted\"");
355 ## plot(xplot,y1plot,"@",xplot,y2plot,"@",xfit,ytheor,"-");pause;closeplot;
356 # plot(xfit,yfit,"@",xfit,ytheor,"-");pause;closeplot;
357 #
358
359 #write data
360 outfname=strcat(data_file,".momentum_fit_results");
361 # puts("Writing Data to file: " outfname "\n");
362 [outfile, msg] = fopen(outfname,"wt");
363 if outfile == -1
364 error("no writing Data to Data File:\t %s \n",msg)
365 endif
366 #variante1
367 # fprintf(outfile,"M2 Fit\nepsilon_f\trho_star\tq_0\n");
368 # fprintf(outfile,"%#.9g\t%#.9g\t%#.9g\n",m2_ef,m2_rhostar,m2_q_0);
369 #
370 # fprintf(outfile,"M3 Fit\nepsilon_f\trho_star\tq_0\n");
371 # fprintf(outfile,"%#.9g\t%#.9g\n",m3_P2,m3_q_1);
372 #
373 # fprintf(outfile,"M4pq2 Fit\nepsilon_f\trho_star\tq_0\n");
374 # fprintf(outfile,"%#.9g\t%#.9g\t%#.9g\n",m4pq2_ef,m4pq2_rhostar,m4pq2_q_2);
375 #
376 # the order : m2ef m2rho* m2q_0 m3P2 m3q_1 m4ef m4rho* m4flucrho m4q_0
377 fprintf(outfile,"%s\t%#.9g\t%#.9g\t%#.9g\t%#.9g\t%#.9g\t%#.9g\t%#.9g\t%#.9g\t%#.9g\n",outfname,m2_ef,m2_rhostar,m2_q_0, m3_P2,m3_q_1,m4pq2_ef,m4pq2_rhostar,m4pq2_flucrho,m4pq2_q_2);
378
379
380 fclose(outfile);
381 #cleanup
382 #clear *;
383
384 #result = 0;
385 #endfunction
