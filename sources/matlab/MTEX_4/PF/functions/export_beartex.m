function export_beartex(pf, filename, varargin)
% function export_beartex(pf, filename, varargin)
    fp = fopen(filename, 'w');
    formatOut = 'mm/dd/yy';
    d = datestr(now,formatOut);
    for i=1:pf.numPF
        fprintf(fp, '%-9s%-21s%-49s#\r\n', filename, d, 'DFB=NN');
        fprintf(fp, '\r\n');
        fprintf(fp, '\r\n');
        fprintf(fp, '\r\n');
        fprintf(fp, '\r\n');
        text = '    2.877     2.877     2.877    90.0000   90.0000   90.0000    7    1';
        fprintf(fp, '%s\r\n', text);
        h = strtrim(num2str(pf.h.hkl(i,:)));
        h(isspace(h)) = [];
         alphamin = min(pf({i}).r.theta/degree);
        alphamax = max(pf({i}).r.theta/degree);
%          betamin =  min(pf({i}).r.rho/degree) + 180;
        betamax =  max(pf({i}).r.rho/degree) + 180;
        fprintf(fp, '%4s  %s  %s  %3.1f %3.1f  %3.1f   .0%3.1f  %3.1f 1 1 2-1 3  100    0\r\n',...
            h(1), h(2), h(3), alphamin + 5, alphamax, 5, betamax, 5);
        fprintf(fp, ' ');
        f = get_option(varargin, 'factor', 100);
        int = pf({i}).intensities;
        if any(f*int>9999)
            display('Warning: There are values greater than 9999')
            display('Change f')
        end
        for j=1:length(int)
            if(int(j) >= 0)
                fprintf(fp, '%4d', int32(f*int(j)));
            else
                fprintf(fp, '%4d', int32(int(j)));
            end
            if(mod(j,18) == 0)
                fprintf(fp, '\r\n ');
            end
        end
        fprintf(fp, '\r\n');
    end
    fclose(fp);
end