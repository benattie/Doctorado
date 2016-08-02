function clean_pf = poleFigure_cleanup(pf, varargin)
    %% Check for options
    low = get_option(varargin, 'min', 0);
    high = get_option(varargin, 'max', 100);
    neg2max = get_option(varargin, 'neg2max', 0);
    
    clean_pf = pf;
    
    %% Manual cleanup
    if high || low || neg2max
        for i=1:pf.numPF
            int = clean_pf.allI{i};
            if neg2max
                    int(int < 0) = max(int);
            end

            if high
                q4 = prctile(int, high);
                int(int > q4) = q4;
            end

            if low
                q1 = prctile(int, low);
                int(int < q1) = q1;
            end
            clean_pf.allI{i} = int;
        end
    else
    %% Automatic cleanup (the same as setting 1 and 99 in the previous setting)
        clean_pf(clean_pf.isOutlier) = [];
        condition = clean_pf.intensities < 0;
        clean_pf(condition) = [];
    end
end