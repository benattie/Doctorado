%%[size_pf, strain_pf] = langfold(pf_H, pf_eta, lambda, theta, i_final)

function [size_pf, strain_pf] = langfold_batch(pf_H, pf_eta, lambda, theta, i_final)
    for i=1:i_final
        [size_pf(i), strain_pf(i)] = langfold(pf_H(i), pf_eta(i), lambda, theta(i));

        %correccion muy elemental de los datos de salida
        aux = size_pf(i);
        inf_values = get(aux, 'intensities') == Inf;
        aux = delete(aux, inf_values);
%         zero_values = get(aux, 'intensities') == 0;
%         aux = delete(aux, zero_values);
        size_pf(i) = aux;

        aux = strain_pf(i);
        inf_values = get(aux, 'intensities') == Inf;
        aux = delete(aux, inf_values);
%         zero_values = get(aux, 'intensities') == 0;
%         aux = delete(aux, zero_values);
        strain_pf(i) = aux;
    end
end