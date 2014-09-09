function spf = smooth_pf(pf, pf_start, pf_end)
    % recorro todas las figuras de polos que me pasa el usuario
    for i=pf_start:pf_end
        % los puntos de la grilla
        theta = get(pf(i), 'theta');
        rho = get(pf(i), 'rho');
        p = sph2vec(theta, rho);
        s2g =  S2Grid(p, 'antipodal');
        [theta, rho] = polar(s2g); % saco los angulos polares
        p = sph2vec(theta, rho);
        x = getx(p);
        y = gety(p);
        z = getz(p);
        X = {x, y, z};
        % las intensidades de los puntos de la grilla irregular
        pf_int = get(pf(i), 'intensities');
        int = pf_int;
        % obtengo los puntos interpolados (verificar que ande)
        f = csaps(p, int);
        int_smooth = fnval(f, X);
        % ahora genero la figura de polos regular
        aux_h = get(pf(i), 'h'); % obtengo el indice de Miller
        aux_cs = get(pf(i), 'CS');
        aux_ss = get(pf(i), 'SS');
        spf(i) = set(pf(i), 'intensities', int_smooth);
    end
end
