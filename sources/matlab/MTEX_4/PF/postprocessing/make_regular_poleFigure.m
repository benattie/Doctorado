% rpf = regular_pf(pf, res_polar, res_azimuth, method)

function out_pf = make_regular_poleFigure(pf, n_polar, n_azi, method)
    % defino la grilla regular
    S2G = regularS2Grid('points',[n_azi, n_polar], 'antipodal');
    S2G = reshape(S2G, length(S2G), 1);
    % las coordenadas x y z de los puntos de la grilla regular
    Xq = [S2G.x S2G.y S2G.z];
    % recorro todas las figuras de polos que me pasa el usuario
    for i=1:pf.numPF
        x = pf.allR{i}.x;
        y = pf.allR{i}.y;
        z = pf.allR{i}.z;
        X = [x(:) y(:) z(:)];
        % las intensidades de los puntos de la grilla irregular
        int = pf.allI{i};
        % obtengo los puntos interpolados
        if(strcmp(method, 'linear') == 1)
            int_q = griddatan(X, int, Xq, 'linear');
        else
            int_q = griddatan(X, int, Xq, 'nearest');
        end
        % ahora genero la figura de polos regular
        rpf{i} = PoleFigure(pf.allH{i}, S2G, int_q, pf.CS, pf.SS);
    end
    out_pf = [rpf{:}];
end