1 function returnval = wilkens_f_eta(eta)
2 if eta < 1
3 int_arcsin_v_per_v = 0;
4 for n=0:65
5 int_arcsin_v_per_v = int_arcsin_v_per_v + \
6 factorial(2*n)/( 2^n * factorial(n) * 2*n+1)^2 * eta^(2*n+1);
7 endfor
8 returnval = - log(eta) +7/4-log(2) + 512/(90*pi*eta) \
9 + (2/pi)*( 1-1/(4*eta^2) )*int_arcsin_v_per_v \
10 - (1/pi)*( 769/(180*eta) + (41/90)*eta+ (2/90)*eta^3 )*sqrt(1-eta^2)\
11 - (1/pi)*( 11/(12*eta^2) + 7/2 + (eta^2)/3 )*asin(eta) + (eta^2)/6;
12 else
13 returnval = 512/(90*pi*eta) - ( 11/24 + (1/4)*log(2*eta) )/(eta^2);
14 endif
15 endfunction
16
17 function returnval= alsizespheric(L,m,sigma)
18 returnval = ( (m^3/3) * exp(4.5*sigma^2) ) \
19 * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) - 1.5*sqrt(2)*sigma )\
20 - ( m^2 * abs(L) * exp(2*sigma^2) /2 ) \
21 * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) - sqrt(2)*sigma )\
22 - ( (abs(L)^3) /6 ) \
23 * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) );
24
25 endfunction
26
27 function returnval= alwilkens(L,Cbar,rho,B,g2,Re)
28 returnval = exp( -rho*B*L^2*g2*Cbar*wilkens_f_eta(abs(L)/Re) );
29 endfunction
30
31 function returnval = wilkens(Cbar,rho,B,g2,Re)
32 L=0.1*[1:100];
33 returnval = fft(alwilkens(L,Cbar,rho,B,g2,Re));
34 endfunction
