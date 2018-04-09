function clean_pf = poleFigure_cleanup(pf, varargin)
% Cleans experimental pole figures using different criteria.
% Options
%   'min' - Real. Determines the percentile given by low (called q1) and 
%   sets all values below q1 to q1
%   'max' - Real. Determines the percentile given by high (called q4) and 
%   sets all values below q4 to q4
%   'neg2max' - Real. Determines the percentile given by neg2max and 
%   sets all negatives values to that number
%   'neg2min' - Real. Determines the percentile given by neg2min and 
%   sets all negatives values to that number
%   'neg2mean' - Real. Determines the mean of all positives values and 
%   sets all negatives values to that number
%
% If no options are given, the isOutlier method for the class PoleFigure of
% MTEX is used to remove outliers. The result is the same as setting
% 'max' to 99, 'min' to 1 and removing all negative values.

    %% Check for options
    low = get_option(varargin, 'min', 0);
    high = get_option(varargin, 'max', 100);
    neg2max = get_option(varargin, 'neg2max', 0);
    neg2min = get_option(varargin, 'neg2min', 0);
    neg2ave = get_option(varargin, 'neg2ave', 0);
    
    clean_pf = pf;
    
    %% Manual cleanup
    if high ~= 100 || low || neg2max || neg2min || neg2ave
        for i=1:pf.numPF
            int = clean_pf.allI{i};
            
            if high
                %% q4 is the value of the high percentile set by the user
                q4 = prctile(int(int > 0), high);
                int(int > q4) = q4;
            end

            if low
                %% q1 is the value of the low percentile set by the user
                q1 = prctile(int(int > 0), low);
                int(int < q1 & int > 0) = q1;
            end
            
            if neg2max
                tmp = prctile(int(int > 0), neg2max);
                int(int < 0) = mean(int(int > tmp));
            else
                if neg2min
                    tmp = prctile(int(int > 0), neg2min);
                    int(int < 0) = mean(int(int < tmp) & int(int > 0));
                else
                    if neg2ave
                        int(int < 0) = mean(int(int > 0));
                    end
                end
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