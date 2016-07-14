function [size_pf, strain_pf] = Langford_pf(H_pf, eta_pf, lambda, theta)
% [size_pf, strain_pf] = langfold(H_pf, eta_pf, lambda, theta)
    %% Get data
    H = get(H_pf, 'intensities'); 
    eta = get(eta_pf, 'intensities');
    
    %% Separar ancho gaussiano y lorentziano
    [Hg, Hl] = deconvolve(H, eta);
    % Debye Scherrer formula
    size = debye_scherrer(lambda, Hl, theta);
    size_pf = set(eta_pf, 'intensities', size);
    % Deformacion acumulada
    strain = strain_f(Hg, theta);
    strain_pf = set(H_pf, 'intensities', strain);
end