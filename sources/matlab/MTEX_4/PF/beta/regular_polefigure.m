function rpf = regular_polefigure(pf, res_polar, res_azimuth)
    % defino la grilla regular
    reg_s2g =  regularS2Grid('resolution',[res_polar*degree res_azimuth*degree]);
    x_q = reg_s2g.x;
    y_q = reg_s2g.y;
    z_q = reg_s2g.z;
    x_q = reshape(x_q, 1, length(x_q(:)));
    y_q = reshape(y_q, 1, length(y_q(:)));
    z_q = reshape(z_q, 1, length(z_q(:)));
    v = vector3d(x_q, y_q, z_q);
    X_q = [x_q(:) y_q(:) z_q(:)];    
    for i=1:pf.numPF
        x = pf.allR{i}.x;
        y = pf.allR{i}.y;
        z = pf.allR{i}.z;
        X = [x(:) y(:) z(:)];
        I = pf.allI{i};
        DT = delaunayTriangulation(X);
        [ti,bc] = pointLocation(DT,X_q)
        triVals = I(DT(ti,:));
        I_q = dot(bc',triVals')';
        % las intensidades de los puntos de la grilla irregular
        % obtengo los puntos interpolados
%         int_q = griddatan(X, pf.allI{i}, X_q, 'nearest');
        rpf{i} = PoleFigure(pf.allH{i}, v, I_q);
    end
    rpf = [rpf{:}];
end