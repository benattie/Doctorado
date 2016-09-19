function [pf_up, pf_down] = create_pf_from_sync(fname, arg, h, SS)
    for i=1:numel(h)
        msg = sprintf('Reading data file %s', fname{i});
        display(msg)
        fp = fopen(fname{i});
        textscan(fp, '%s', 1, 'delimiter', '\n');
        header = textscan(fp, '%s', 1, 'delimiter', '\n');
        header = strsplit(header{1}{1});
        rep = length(header) - 1;
        read_str = repmat('%f ', [1 rep]);
        data = textscan(fp, read_str, 'delimiter', '\t');
        fclose(fp);
        %import data
        switch arg
            case 'POS'
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'2theta')}];
            case 'FWHM'
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'FWHM')}];
            case 'ETA'
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'eta')}];
            case 'SABO_INT'
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'raw_int')}];
            case 'INT'
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'fit_int')}];
            otherwise
                display('You have not choosed what kind of GPF you want to do')
                display('Using intensities by default')
                data_M = [data{strcmp(header,'Row')} data{strcmp(header,'2theta')}...
                    data{strcmp(header,'omega')} data{strcmp(header,'gamma')}...
                    data{strcmp(header,'alpha')} data{strcmp(header,'beta')}...
                    data{strcmp(header,'fit_int')}];
        end
        
        % separate data
        [data_up, data_down] = separate_spheres(data_M);
        % PF_UP
        alpha = data_up(:, 5);
        beta = data_up(:, 6);
        r = vector3d('polar',alpha*degree,beta*degree);
        I = data_up(:, 7);
        pf_up{i} = PoleFigure(h{i},r,I);
        pf_up{i}.SS = SS;
        % PF_DOWN
        alpha = data_down(:, 5);
        beta = data_down(:, 6);
        r = vector3d('polar',alpha*degree,beta*degree);
        I = data_down(:, 7);
        pf_down{i} = PoleFigure(h{i},r,I);
        pf_down{i}.SS = SS;
    end
    pf_up = [pf_up{:}];
    pf_up = unique(pf_up);
    pf_down = [pf_down{:}];
    pf_down = unique(pf_down);
end