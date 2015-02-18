% rpf = regular_pf(pf, pf_start, pf_end, res_polar, res_azimuth)

function rpf = regular_pf(pf, pf_start, pf_end, res_polar, res_azimuth)
    reg_s2g =  S2Grid('regular', 'resolution', [res_polar * degree res_azimuth * degree], 'antipodal');
    [theta_q, rho_q] = polar(reg_s2g); % saco los angulos polares
    theta_q = reshape(theta_q, 1, length(theta_q(:)));
    rho_q = reshape(rho_q, 1, length(rho_q(:)));
    p_q = sph2vec(theta_q, rho_q);
%     s2g_q =  S2Grid(p_q, 'complete', 'antipodal');
    s2g_q =  S2Grid(p_q);
    % las coordenadas x y z de los puntos de la grilla regular
    x_q = getx(p_q);
    y_q = gety(p_q);
    z_q = getz(p_q);
    Xq = [x_q(:) y_q(:) z_q(:)];
    % recorro todas las figuras de polos que me pasa el usuario
    for i=pf_start:pf_end
        % los puntos de la grilla irregular
        theta = get(pf(i), 'theta');
        rho = get(pf(i), 'rho');
        p = sph2vec(theta, rho);
        s2g =  S2Grid(p, 'antipodal');
        [theta, rho] = polar(s2g); % saco los angulos polares
        p = sph2vec(theta, rho);
        x = getx(p);
        y = gety(p);
        z = getz(p);
        X = [x(:) y(:) z(:)];
        % las intensidades de los puntos de la grilla irregular
        int = get(pf(i),'intensities');
        % obtengo los puntos interpolados
        int_q = griddatan(X, int, Xq, 'nearest');
        % ahora genero la figura de polos regular
        aux_h = get(pf(i), 'h'); % obtengo el indice de Miller
        aux_cs = get(pf(i), 'CS');
        aux_ss = get(pf(i), 'SS');
        rpf(i) = PoleFigure(aux_h, s2g_q, int_q, aux_cs, aux_ss);
    end
end
