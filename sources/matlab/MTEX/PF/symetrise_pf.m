function [left_pf, right_pf] = symetrise_pf(input_pf)
    left_pf = input_pf;
    right_pf = input_pf;
    for i = 1:input_pf.numPF
       pf = input_pf({i});
       % una mitad
       condition = (pf.allR{1}.rho >= -90*degree & pf.allR{1}.rho < 90*degree);
       aux_pf = pf(condition);
       buf_pf = aux_pf;
       buf_pf.allR{1}.x = buf_pf.allR{1}.x*-1;
       aux_pf.allR{1}.x = cat(1, aux_pf.allR{1}.x, buf_pf.allR{1}.x);
       aux_pf.allR{1}.y = cat(1, aux_pf.allR{1}.y, buf_pf.allR{1}.y);
       aux_pf.allR{1}.z = cat(1, aux_pf.allR{1}.z, buf_pf.allR{1}.z);
       aux_pf.allI{1} = cat(1, aux_pf.allI{1}, buf_pf.allI{1});
       right_pf({i}) = aux_pf;

       % otra mitad
       aux_pf = pf(~condition);
       buf_pf = aux_pf;
       buf_pf.allR{1}.x = buf_pf.allR{1}.x*-1;
       aux_pf.allR{1}.x = cat(1, aux_pf.allR{1}.x, buf_pf.allR{1}.x);
       aux_pf.allR{1}.y = cat(1, aux_pf.allR{1}.y, buf_pf.allR{1}.y);
       aux_pf.allR{1}.z = cat(1, aux_pf.allR{1}.z, buf_pf.allR{1}.z);
       aux_pf.allI{1} = cat(1, aux_pf.allI{1}, buf_pf.allI{1});
       left_pf({i}) = aux_pf;
    end
end
