function pf_out = remove_center(pf_in)
    pf_out = pf_in;
    
    for i=1:pf_in.numPF
        aux = pf_out({i});
        condition = (aux.r.rho/degree <= -89.9 & ...
            aux.r.rho/degree >= -90.1) | ...
            (aux.r.rho/degree <= 90.1 & aux.r.rho/degree >= 89.9);
        aux(condition) = [];
        pf_out({i}) = aux;
    end

end