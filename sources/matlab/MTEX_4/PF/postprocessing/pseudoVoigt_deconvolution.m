function [Hg_pf, Hl_pf] = pseudoVoigt_deconvolution(pf_H, pf_E)
   % [Hg_pf, Hl_pf] = pseudoVoigt_deconvolution(pf_H, pf_E)
    if (pf_H.numPF ~= pf_E.numPF)
        m = min(colH, colE);
        wmsg = sprintf('Warning: PF sizes differ');
        display(wmsg);
    else
        m = pf_H.numPF;
    end
    Hg_pf = pf_H;
    Hl_pf = pf_H;
    for i=1:m
        %% Genero las GPF de tamaño y deformacion
        %% Get data
        H = pf_H.allI{i}; 
        eta = pf_E.allI{i}; 
        
        %% Separar ancho gaussiano y lorentziano
        Hl = H .* (0.72928 .* eta + 0.19289 .* eta .^ 2 + 0.07783 .* eta .^ 3);
        Hg = H .* sqrt(1 - 0.74417 .* eta - 0.24781 .* eta .^ 2 - 0.00810 .* eta .^ 3);
        Hg_pf.allI{i} = Hg;
        Hl_pf.allI{i} = Hl;
    end
end