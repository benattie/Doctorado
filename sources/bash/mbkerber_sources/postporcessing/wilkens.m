function returnval = wilkens_f_eta(eta)
    if eta < 1
        int_arcsin_v_per_v = 0;
        for n=0:65
            int_arcsin_v_per_v = int_arcsin_v_per_v + \
            factorial(2*n)/( 2^n * factorial(n) * 2*n+1)^2 * eta^(2*n+1);
        endfor
        returnval = - log(eta) +7/4-log(2) + 512/(90*pi*eta) \
        + (2/pi)*( 1-1/(4*eta^2) )*int_arcsin_v_per_v \
        - (1/pi)*( 769/(180*eta) + (41/90)*eta+ (2/90)*eta^3 )*sqrt(1-eta^2)\
        - (1/pi)*( 11/(12*eta^2) + 7/2 + (eta^2)/3 )*asin(eta) + (eta^2)/6;
    else
        returnval = 512/(90*pi*eta) - ( 11/24 + (1/4)*log(2*eta) )/(eta^2);
    endif
endfunction

function returnval= alsizespheric(L,m,sigma)
    returnval = ( (m^3/3) * exp(4.5*sigma^2) ) \
    * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) - 1.5*sqrt(2)*sigma )\
    - ( m^2 * abs(L) * exp(2*sigma^2) /2 ) \
    * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) - sqrt(2)*sigma )\
    - ( (abs(L)^3) /6 ) \
    * erfc( (log(abs(L)/m))/(sqrt(2)*sigma) );
endfunction

function returnval= alwilkens(L,Cbar,rho,B,g2,Re)
    returnval = exp( -rho*B*L^2*g2*Cbar*wilkens_f_eta(abs(L)/Re) );
endfunction

function returnval = wilkens(Cbar,rho,B,g2,Re)
    L=0.1*[1:100];
    returnval = fft(alwilkens(L,Cbar,rho,B,g2,Re));
endfunction
