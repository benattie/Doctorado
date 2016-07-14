function C = absortion(mu_rho, rho, t, theta, alpha)
% Funcion para calcular el factor de corrección por absorción de una muestra
%
%% Input
% Coeficiente de absorción másico (mu_rho), la densidad del material (rho),
% el espesor de la muestra (t), el ángulo de Bragg de la reflexión que se
% está estudiando (theta) y el ángulo de rotación de la muestra (alpha).
%
% Los ángulos deben ir en grados y mu_rho, rho y t deben ir en unidades
% tales que el producto mu_rho * rho * t sea adimensional.
%
% ¡Cuidado! A la hora de poner alpha se debe tener cuidado con el signo. Si
% la rotación de la muestra fue en sentido anti-horario, el ángulo alpha es
% positivo. Si la rotación fue en sentido horario, el ángulo que va debe
% ser negativo. Por lo tanto -90 < alpha < 90.
%
%% Output
% Factor de corrección de la intensidad. La intensidad medida debe ser
% multiplicada por este factor para obtener la corregida.
%
    mu_t = mu_rho * rho * t;
    cos_theta = cos(theta * degree);
    cos_alptheta = cos((theta + alpha) * degree);
    cos_almtheta = cos((theta - alpha) * degree);
    cos_pm = cos_alptheta / cos_almtheta;
    exp_theta = exp(-mu_t / cos_theta);
    exp_palpha = exp(-mu_t / cos_alptheta);
    exp_malpha = exp(-mu_t / cos_almtheta);
    
    C = ((mu_t * exp_theta) / cos_theta) *...
        ((cos_alptheta / cos_almtheta - 1.0) / (exp_palpha - exp_malpha));
end