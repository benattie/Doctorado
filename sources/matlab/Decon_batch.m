function [HG_pf, HL_pf] = Decon_batch(pf_H, pf_E)
% [size_pf, strain_pf] = Decon_batch(pf_H, pf_E)
%   Detailed explanation goes here

    [~, colH] = size(pf_H);
    [~, colE] = size(pf_E);
    if (colH ~= colE)
        m = min(colH, colE);
        wmsg = sprintf('Warning: PF sizes differ');
        display(wmsg);
    else
        m = colH;
    end
    HG_pf = pf_H;
    HL_pf = pf_E;
    for i=1:m
        H = get(HG_pf(i), 'intensities');
        eta = get(HL_pf(i), 'intensities');
        [Hg, Hl] = deconvolve(H, eta);
        HG_pf(i) = set(HG_pf(i), 'intensities', real(Hg));
        HL_pf(i) = set(HL_pf(i), 'intensities', real(Hl));
    end
end

