function pfout = SHpf(Nord, pfin)
    [~, npf] = size(pfin);
    pfout = pfin;
    for i = 1:npf
        % obtengo la informacion de la PF original
        int = get(pfin(i), 'intensities');
        theta = get(pfin(i), 'theta');
        theta = reshape(theta, numel(theta), 1);
        rho = get(pfin(i), 'rho');
        rho = reshape(rho, numel(rho), 1);
        dirs = [theta rho];
        Fnm = leastSquaresSHT(Nord, int, dirs, 'real');
        
        % Hago el ajuste por armonicos y creo la PF
        the = [0:5:80] * degree;
        the = repmat(the, 72, 1);
        the = reshape(the, numel(the), 1);
        rh = [0:5:355] * degree;
        rh = repmat(rh, 1, 17);
        rh = reshape(rh, numel(rh), 1);
        rh(1:72) = 0;
        dir = [the rh];
        S2G = sph2vec(the, rh);
        S2G = S2Grid(S2G);

        out = inverseSHT(Fnm, dir, 'real');
        
        h = get(pfin(i), 'Miller');
        CS = get(pfin(i), 'CS');
        SS = get(pfin(i), 'SS');
        pfout(i) = PoleFigure(h, S2G, out, CS, SS);
    end
end
