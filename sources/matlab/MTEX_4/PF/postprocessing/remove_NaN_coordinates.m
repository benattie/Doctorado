function out_pf = remove_NaN_coordinates(in_pf)
    out_pf = in_pf;
    for i=1:out_pf.numPF
        % x
        pf = out_pf({i});
        pf(isnan(pf.allR{1}.x)) = [];
        out_pf({i}) = pf;
        % y
        pf = out_pf({i});
        pf(isnan(pf.allR{1}.y)) = [];
        out_pf({i}) = pf;
        % z
        pf = out_pf({i});
        pf(isnan(pf.allR{1}.z)) = [];
        out_pf({i}) = pf;
    end
end