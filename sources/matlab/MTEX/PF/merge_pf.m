function merged_pf = merge_pf (left_pf, right_pf)
    if (left_pf.numPF ~= right_pf.numPF)
        error('Las cantidades de PFs no coinciden')
    else
        merged_pf = left_pf;
        for i = 1:right_pf.numPF
           pf = right_pf({i});
           pf.allR{1}.x = cat(1, pf.allR{1}.x, left_pf.allR{i}.x);
           pf.allR{1}.y = cat(1, pf.allR{1}.y, left_pf.allR{i}.y);
           pf.allR{1}.z = cat(1, pf.allR{1}.z, left_pf.allR{i}.z);
           pf.allI{1} = cat(1, pf.allI{1}, left_pf.allI{i});
           merged_pf({i}) = pf;
        end
    end
end