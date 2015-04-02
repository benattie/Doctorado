

function [size_pf, strain_pf] = Langford_batch(pf_H, pf_E, lambda, theta)
   % [size_pf, strain_pf] = Langford_batch(pf_H, pf_E, lambda, theta)
    [~, colH] = size(pf_H);
    [~, colE] = size(pf_E);
    if (colH ~= colE)
        m = min(colH, colE);
        wmsg = sprintf('Warning: PF sizes differ');
        display(wmsg);
    else
        m = colH;
    end
    size_pf = pf_H;
    strain_pf = pf_H;
    for i=1:m
        %% Genero las GPF de tamaño y deformacion
        [size_pf(i), strain_pf(i)] = Langford_pf(pf_H(i), pf_E(i), lambda, theta(i));
    end
end