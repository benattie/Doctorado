#! /usr/bin/octave -qf
if (nargin != 2)
    display "calculando con alpha = 5° y beta = 5°"
    alpha = 5*pi/180;
    beta = 5*pi/180;
    s = 0.5*(cos(beta)*(cos(alpha)-cos(2*alpha))+cos(alpha)+cos(2*alpha))
    a = 100*(1-s)
else
    arg_list = argv();
    alpha = str2num(arg_list{1})*pi/180;
    beta = str2num(arg_list{2})*pi/180;
    s = 0.5*(cos(beta)*(cos(alpha)-cos(2*alpha))+cos(alpha)+cos(2*alpha))
    a = 100*(1-s)
end 
