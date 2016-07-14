function s_pf = sum_pole_figures(pf_a, pf_b)
    s_pf = pf_a;
    for i=1:pf_a.numPF
        alpha = pf_a.allR{i}.theta;
        beta = pf_a.allR{i}.rho;
        for j=1:numel(alpha)
            condition = pf_b.allR{i}.theta == alpha(j) & pf_b.allR{i}.rho == beta(j);
            s_pf.allI{i}(j) = pf_a.allI{i}(j) + pf_b.allI{i}(condition);
        end
    end
end