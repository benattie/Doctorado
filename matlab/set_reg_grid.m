%AlARMH_I_th5_importscript;
%theta == angulo polar
%rho = angulo azimutal
%cada columna de estos tiene el dato de cada figura de polo
in_pf = AlARMH_I_th5_pf;
out_pf = in_pf;

firstpf = 1;
lastpf = 7;

minpolar = 0;
steppolar = 5;
maxpolar = 90;

minaz = 0;
stepaz = 5;
maxaz = 355;

alpha = [minpolar:steppolar:maxpolar];
beta = [minaz:stepaz:maxaz];
S2G = S2Grid('regular', 'upper');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
int_grid = zeros((lastpf - firstpf) + 1, maxpolar / steppolar + 1, maxaz / stepaz + 1);
ave_int_grid = zeros((lastpf - firstpf) + 1, maxpolar / steppolar + 1, maxaz / stepaz + 1);
n_grid = zeros((lastpf - firstpf) + 1, maxpolar / steppolar + 1, maxaz / stepaz + 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for m = firstpf:lastpf
    polar_angle = get(in_pf(m), 'theta');
    azimuth_angle = get(in_pf(m), 'rho');
    int = get(in_pf(m), 'intensities');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for l = 1:numel(int)
        for i = 1:(maxpolar / steppolar + 1)
%        for i = 1:(35/5 + 1)
            for j = 1:(maxaz / stepaz + 1)
%             for j = 1:(180 / 5 + 1)
                if(polar_angle(l) / degree >= alpha(i) -  0.5 * steppolar && polar_angle(l) / degree < alpha(i) + 0.5 * steppolar)
                    if(azimuth_angle(l) / degree >= beta(j) - 0.5 * stepaz && azimuth_angle(l) / degree < beta(j) + 0.5 * stepaz)
                        int_grid(m, i, j) = int_grid(m, i, j) + int(l);
                        n_grid(m, i, j) = n_grid(m, i, j) + 1;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if(azimuth_angle(l) / degree >= beta(maxaz / stepaz + 1) + 0.5 * stepaz)
                        int_grid(m, i, 1) = int_grid(i, 1) + int(l);
                        n_grid(m, i, 1) = n_grid(i, 1) + 1;
                    end
                end
            end
        end
    end
    
    %promediar los datos
%     for i = 1:(maxpolar / steppolar + 1)
%         for j = 1:(maxaz / stepaz + 1)
%             if(n_grid(m, i, j) == 0)
%                 ave_int_grid(m, i, j) = 0;
%             else
%                 ave_int_grid(m, i, j) = nan;
%             end
%         end
%     end
    for i = 1:(maxpolar / steppolar + 1)
        for j = 1:(maxaz / stepaz + 1)
            if(n_grid(m, i, j) == 0)
                ave_int_grid(m, i, j) = nan;
            else
                ave_int_grid(m, i, j) = int_grid(m, i, j) / n_grid(m, i, j);
            end
        end
    end
    %elimino los nan
%     for i = 1:(maxpolar / steppolar + 1)
%         for j = 1:(maxaz / stepaz + 1)
%             if(isnan(ave_int_grid(m, i, j)))
%                 v = [ave_int_grid(m, index(i + 1, minpolar / steppolar + 1, maxpolar / steppolar + 1),...
%                      pindex(j + 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, index(i - 1, minpolar / steppolar + 1, maxpolar / steppolar + 1),...
%                      pindex(j + 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, index(i + 1, minpolar / steppolar + 1, maxpolar / steppolar + 1),...
%                      pindex(j - 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, index(i - 1, minpolar / steppolar + 1, maxpolar / steppolar + 1),...
%                      pindex(j - 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, i, pindex(j + 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, i, pindex(j - 1, minaz / stepaz + 1, maxaz / stepaz + 1))...
%                      ave_int_grid(m, index(i + 1, minpolar / steppolar + 1, maxpolar / steppolar + 1), j)...
%                      ave_int_grid(m, index(i - 1, minpolar / steppolar + 1, maxpolar / steppolar + 1), j)];
%                 ave_int_grid(m, i, j) = nanmean(v);
%             end
%         end
%     end
       
    %promediar la cupula
    ave = mean(int_grid(1,:));
    for j = 1:(maxaz / stepaz)
        int_grid(m, 1, j) = ave;
    end
    
    %generar la nueva figura de polos
    aux = squeeze(ave_int_grid(m,:,:));
    intensities = reshape(aux', 1, (maxpolar / steppolar + 1) * (maxaz / stepaz + 1));
    out_pf(m) = PoleFigure(get(in_pf(m),'h'), S2G, intensities, CS, SS);
end
figure(1);
% plot(normalize(out_pf));
plot(out_pf);

out_pf_cut = out_pf;
for i=1:7
    hangle = get(out_pf_cut(i),'theta') > 85 * degree;
    out_pf_cut(i) = delete(out_pf_cut(i), hangle);
    langle = get(out_pf_cut(i),'theta') < 50 * degree;
    out_pf_cut(i) = delete(out_pf_cut(i), langle);
end
figure(2);
plot(out_pf_cut);


