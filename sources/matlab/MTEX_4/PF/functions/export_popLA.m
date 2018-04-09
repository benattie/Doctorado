function export_popLA(pf, path, filename, varargin)
% export_popLA(pf, filename, varargin)
    filepath = [path filename '.epf'];
    fp = fopen(filepath, 'w');
    formatOut = 'mm/dd/yy';
    d = datestr(now,formatOut);
    for i=1:pf.numPF
        fprintf(fp, '%-9s%-21s%-9s5x5\r\n', filename, d, 'DFB=NN');
        h = strtrim(num2str(pf.h.hkl(i,:)));
        h(isspace(h)) = [];
        alphamin = min(pf({i}).r.theta/degree);
        alphamax = max(pf({i}).r.theta/degree);
        betamin =  min(pf({i}).r.rho/degree) + 180 - 2.53;
        betamax =  max(pf({i}).r.rho/degree) + 180 + 2.54;
        fprintf(fp, '(%s)  %.1f %2.1f  %.1f%-3.1f 1 1 2-1 3  1      1\r\n',...
            h, alphamin, alphamax, betamin, betamax);
        fprintf(fp, ' ');
        f = get_option(varargin, 'factor', 100);
        int = pf({i}).intensities;
        if any(f*int>9999)
            display('Warning: There are values greater than 9999')
            display('Change f')
        end
        for j=1:72
            fprintf(fp, '%4d', 0);
            if(mod(j,18) == 0 && mod(j, 72) ~= 0)
                fprintf(fp, '\r\n ');
            end
            if(mod(j, 72) == 0)
                fprintf(fp, '%4d\r\n ', 0);
            end
        end
        for j=1:length(int)
            if(int(j) >= 0)
                fprintf(fp, '%4d', int32(f*int(j)));
            else
                fprintf(fp, '%4d', 0);
            end
            if(mod(j,18) == 0 && mod(j, 72) ~= 0)
                fprintf(fp, '\r\n ');
            end
            if(mod(j, 72) == 0)
                tmp_int = int(j - 71:j);
                fprintf(fp, '%4d\r\n ', int32(f*mean(tmp_int(tmp_int > 0))));
            end
        end
        fprintf(fp, '\r\n');
    end
    fclose(fp);
end