function export_reg_PF(pf, fname, res_alpha, res_beta)
%% Use
%  export_reg_PF(pf, fname, res_alpha, res_beta)
% pf - Array of pole figures
% fname - Cell array with the file names. It must contains the same number of
% components that the number of pole figures, otherwise it will raise an
% error
% res_alpha - Resolution in the polar angle (from 0 to 90)
% re_beta - Resolution in the azimuth angle (from 0 to 360)
    if pf.numPF ~= length(fname)
        exception = MException('VerifyNumberOfFiles:MismatchNumbers', ...
       'The number of filenames does not match the number of pole figures');
        throw(exception);
    end
    
    for i=1:pf.numPF
        int = pf({i}).intensities;
        fid = fopen(fname{i}, 'w');
        k = 1;
        for al = 1:res_alpha:91
           for be = 1:res_beta:360
              fprintf(fid, '%7.0f', int(k));
              if(mod(k, 10) == 0)
                  fprintf(fid, '\n');
              end
              k = k + 1;
           end
        end
        fclose(fid);
    end
end