function pfPlot(regular_pf, fbasename)
    
    [~, npf] = size(regular_pf);
    % tendria que meter una rotacion antes de imprimir los datos
    for n=1:npf
        fname = sprintf('%s_%d.pol', fbasename, n);
        fid = efopen(fname, 'w');
        data = [get(regular_pf(n), 'theta') / degree; get(regular_pf(n), 'rho') / degree; get(regular_pf(n), 'intensities')'];
        [~, ncol] = size(data);
        for i = 1:ncol
            fprintf(fid, '%4.4E ', data(3, i));
            if(mod(i, 10) == 0)
                fprintf(fid, '\n');
            end
        end
        fclose(fid);
    end
end