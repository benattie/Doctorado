function clean_pf = cleanFrompf(pf, pf_to_clean, varargin)
    if pf.numPF ~= pf_to_clean.numPF
        disp('Number of pole figures do not match!')
        return;
    else
        clean_pf = pf_to_clean;
        for i=1:pf.numPF
            tmp_pf = pf({i});
            tmp_pf_2 = clean_pf({i});
            treshold = get_option(varargin, 'treshold', 1);
            tresh_int = prctile(tmp_pf.intensities, treshold);
            conditition = tmp_pf.intensities < tresh_int;
            tmp_pf_2(conditition) = [];
            clean_pf({i}) = tmp_pf_2;
        end
    end
end