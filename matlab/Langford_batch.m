% [size_pf, strain_pf] = Langford_batch(H_pf, eta_pf, lambda, theta, start, fin)

function [size_pf, strain_pf] = Langford_batch(H_pf, eta_pf, lambda, theta, start, fin)
    size_pf = H_pf(start:fin);
    strain_pf = H_pf(start:fin);
    for i=start:fin
        %% Genero las GPF de tamaño y deformacion
        [size_pf(i), strain_pf(i)] = Langford_pf(H_pf(i), eta_pf(i), lambda, theta(i));

        %% Eliminio los resultados sin sentido fisico
        inf_values = get(size_pf(i), 'intensities') == Inf;
        size_pf(i) = delete(size_pf(i), inf_values);
        inf_values = get(strain_pf(i), 'intensities') == Inf;
        strain_pf(i) = delete(strain_pf(i), inf_values);
    end
end