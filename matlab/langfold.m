%hasta ahora trabaja solo con una figura de polos por vez. Habria que
%agregar argumentos opcionales que me permitan manejar matrices de figuras
%de polos
%[size_pf, strain_pf] = langfold(H, eta, lambda, theta)
function [size_pf, strain_pf] = langfold(pf_H, pf_eta, lambda, theta)
    
    %get data
    pf_H_tmp = pf_H;
    pf_eta_tmp = pf_eta;
    H = get(pf_H_tmp, 'intensities'); %aca tengo vectores ahora
    eta = get(pf_eta_tmp, 'intensities');
    
    %process data
    [Hg, Hl] = deconvolve(H, eta);
    
    size = debye_scherrer(lambda, Hl, theta);
    strain = strain_f(Hg, theta);
    
    size_pf = set(pf_H_tmp, 'intensities', size);
    strain_pf = set(pf_H_tmp, 'intensities', strain);
end