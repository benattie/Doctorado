function pf = remove_theta_from_pf(input_pf, theta)
    pf = input_pf;
    for i=1:pf.numPF
        buf_pf = pf({i});
        condition = buf_pf.allR{1}.theta > theta*degree;
        buf_pf(condition) = [];
        pf({i}) = buf_pf;
    end
    plot(pf)
end
    
