function pf_reg = make_regular_poleFigure(pf, method)
%% Make pole figure in a regular grid from a pole figure in an irregular one
% Uses the griddatan function to create a pole figure in a regular grid
% from a pole figure that is in a irregular one.
% Usage - pf_reg = make_regular_poleFigure(pf, n_polar, n_azi, method)
%% Input
% pf - Pole figure in an irregular grid
% n_polar - Number of polar coordinates
% n_azi - Number of azimuthal coordinates
% method - Method of interpolation 'nearest' for nearest neighbor
% interpolation or 'linear' for linear interpolation (use with caution,
% ussually gives bad results)
%% Output
% pf_reg - pole figure in a regular grid
    % define regular grid
    
    S2G = regularS2Grid('rho',linspace(0,2*pi,72),'theta',linspace(5*degree,90*degree,18), 'antipodal');
%     S2G = regularS2Grid('points',[n_azi, n_polar], 'antipodal');
    S2G = reshape(S2G, length(S2G), 1);
    % get the coordinates of the point in the regular grid
    Xq = [S2G.x S2G.y S2G.z];
    % loop over the pole figures
    for i=1:pf.numPF
        x = pf.allR{i}.x;
        y = pf.allR{i}.y;
        z = pf.allR{i}.z;
        X = [x(:) y(:) z(:)];
        % get the intensities from the irregular pole figure
        int = pf.allI{i};
        % get the interpolated points
        if(strcmp(method, 'linear') == 1)
            int_q = griddatan(X, int, Xq, 'linear');
        else
            int_q = griddatan(X, int, Xq, 'nearest');
        end
        % make the regular pole figure
        rpf{i} = PoleFigure(pf.allH{i}, S2G, int_q, pf.CS, pf.SS);
    end
    pf_reg = [rpf{:}];
end