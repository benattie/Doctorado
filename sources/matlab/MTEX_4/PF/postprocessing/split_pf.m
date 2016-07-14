function [left_pf, right_pf] = split_pf(input_pf)
    left_pf = input_pf;
    right_pf = input_pf;
    for i = 1:input_pf.numPF
       pf = input_pf({i});
       % una mitad
       condition = (pf.allR{1}.rho >= -90*degree & pf.allR{1}.rho < 90*degree);
%        condition = (pf.allR{1}.rho >= -180*degree & pf.allR{1}.rho < 0*degree);
       right_pf({i}) = pf(condition);
       % otra mitad
       left_pf({i}) = pf(~condition);
    end
end