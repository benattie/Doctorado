function [strain, size] = WarrenAverbach(ttheta, H, eta, crystal_data, inst_data, diff_data)


    % Coeficientes de los picos medidos
    lambda = diff_data{1};
    cutoff = diff_data{2};
    step = diff_data{3};
    L_max = diff_data{4};
    [AL, L] = fourierCoeff(ttheta, cutoff, lambda, step, eta, H, L_max);
    
    % Coeficientes de ancho instrumental
    U = inst_data(1);
    V = inst_data(2);
    W = inst_data(3);
    eta_inst = inst_data(4);
    H_inst = Caglioti(U, V, W, 0.5*ttheta);
    [AL_inst, ~] = fourierCoeff(ttheta, cutoff, lambda, step, eta_inst, H_inst, L_max);
  
    % Correccion instrumental
    AL_corr = AL ./ AL_inst;
%     AL_corr = AL;

    % Ajuste de los coeficientes de Fourier
    y = log(AL_corr)./L.^2;
    x = log(L);
    P = polyfit(x(end-5:end), y(end-5:end), 1);
    
    % Crystal parameters
    b = crystal_data{1};
    K = 2 * sind(0.5*ttheta) / lambda;
    C = crystal_data{2};
    
    % Calculo la densida de dislocaciones
    LAMBDA = (0.5*pi*b^2*C*K^2);
    rho = P(1) / LAMBDA;
    Re = 0.5*exp(-0.25)*exp(-P(2)/LAMBDA);
    M = Re * sqrt(rho);
    strain = [rho Re M];
    
    % Coeficientes de strain
    ALD = exp(- LAMBDA * rho * L.^2 .* Wilkens(L, Re));
    
    % Coeficientes de Size
    ALS = AL_corr ./ ALD;
%     figure;
%     plot(L, AL, 'o')
%     hold on
%     plot(L, AL_corr, 's')
%     plot(L, ALD, '*')
%     plot(L, ALS, 'd')
    size = 0*ALS;

end


function w = Wilkens(L, Re)
    eta = 0.5*exp(-0.25)*(L/Re);
    w = eta;
    w(eta <= 1) = -log(eta(eta<=1)) + 1.75 - log(2) + eta(eta<=1).^2 / 6 - (32 * eta(eta<=1).^3) / (225 * pi);
    w(eta > 1) = (256) ./ (45 * pi * eta(eta>1)) - (11/24 + log(2 * eta(eta>1)) / 4) .* eta(eta>1).^(-2);
end

function FWHM = Caglioti(U, V, W, theta)

    FWHM = sqrt(U * tand(theta).^2 + V * tand(theta) + W);

end