function [A_L, L] = fourierCoeff(x0, cutoff, lambda, step, eta, H, L_max)
%    x0 ; % 2theta Bragg, degrees
%    cutoff = 0.25; % degrees
%    lambda = 0.014; % nm
%    step = 0.001; %degrees
%    eta = 0.5; %componente lorentziana, adimensional
%    H = 0.02; %FWHM, degrees
%    L_max = 60; maximo valor de L a calcular, nm

    theta0 = x0 * 0.5; %theta_Bragg, degrees
    K0 = 2 * sind(theta0) / lambda;
    x = x0 - cutoff:step:x0 + cutoff;
    theta = x * 0.5;
    
    A_idea = [x0 eta H];
    I = pseudoVoigt(A_idea, x);
    K = 2 * sind(theta) / lambda;
%     plot(x, I, 'o')

    A0 = [K0,eta,H*degree];
    opts = optimoptions('lsqcurvefit', 'Display', 'off');
    A = lsqcurvefit(@pseudoVoigt,A0,K,I,[],[],opts);
    
%     L0 = lambda ./ (2 .* sind(theta0));
%     n_max = L_max / L0;
%     L = lambda ./ (2 .* sind(theta0)) * (0:1:n_max);
%     L = L(L <= L_max);
    
    s = K - K0;
    L = 1 ./ s(s>0);
    L = L(L <= L_max);
    
    sigma = A(3) / (2. * sqrt(2. * log(2)));
    gamma = A(3) / 2;
    A_L_Lorenz = A(2) .* exp(-gamma .* L);
    A_L_Gauss = (1 - A(2)) .* exp(-sigma^2 .* L.^2 .* 0.5);
%     FNorm = 1. / sqrt(2*pi);
    FNorm = 1;
    A_L = FNorm .* (A_L_Lorenz + A_L_Gauss);

end 

function y = pseudoVoigt(A, x)
%%  A(1) = x0 = centro de la distribucion
%   A(2) = eta = componente lorenztiana
%   A(3) = FWHM
    sigma = A(3) / (2. * sqrt(2. * log(2)));
    gamma = A(3) / 2;
    
%     habria que ver como ajustar una distribucion custom a la data    
%     y = A(2) * pdf('tLocationScale',x,A(1),gamma,1) + (1 - A(2)) * normpdf(x,A(1),sigma); 

    y = A(2) * 1 ./ (gamma .* pi .* (1 + ((x-A(1)) ./ gamma).^2)) + (1 - A(2)) .* (1 ./ sqrt(2*pi*sigma)) .* exp(-(x-A(1)).^2 ./ (2 * sigma^2));

end