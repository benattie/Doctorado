function reg_pf = regular_pf_simple(pf, res_alpha, res_beta)
    
    r = regularS2Grid('resolution',[res_alpha*degree res_beta*degree]);
    for i = 1:pf.numPF
        display(i)
        reg_I = zeros(length(r), 1);
        n_I = zeros(length(r), 1);    
        %% obtengo la informacion de la PF original
        I = pf.allI{i};
        v = pf.allR{i};
        for j=1:length(pf.allR{i})
            an = angle(v(j), r(:));
            [m, indx] = min(an);
            reg_I(indx) = reg_I(indx) + I(j);
            n_I(indx) = n_I(indx) + 1; 
        end
        %% Promedio
        reg_I = reg_I ./ n_I;
        reg_pf{i} = PoleFigure(pf.allH{i}, r, reg_I);
    end
    reg_pf = [reg_pf{:}];
end