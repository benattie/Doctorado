%% Extraccion de HG y HL
% Para hacer los calculos parto de las GPF de H y eta sin procesar
% HG_pf = rotate(Al70R_H_pfd, yrot);
% HL_pf = rotate(Al70R_E_pfd, yrot);
[HG_pf, HL_pf] = Decon_batch(Al70R_H_pfu, Al70R_E_pfu);
HG_pf = regularizacion(HG_pf(1:3), 2, 99, 1);
HG_pf = regular_pf(HG_pf(1:3), 5, 5, 'nearest');
HL_pf(1) = regularizacion(HL_pf(1), 1, 91.5, 0);
HL_pf(2) = regularizacion(HL_pf(2), 1, 94, 0);
HL_pf(3) = regularizacion(HL_pf(3), 0, 98, 0);
HL_pf = regular_pf(HL_pf(1:3), 5, 5, 'nearest');
%% Grafico los resultados
figure(1);
plot(100 .* HG_pf(1:3), 'contourf');
fname = sprintf('%s/Al70R_100HG_ind_up.pdf', pname);
savefigure(fname);
colorbar;
fname = sprintf('%s/Al70R_100HG_up.pdf', pname);
savefigure(fname);
figure(2);
plot(100 .* HL_pf(1:3), 'contourf');
fname = sprintf('%s/Al70R_100HL_ind_up.pdf', pname);
savefigure(fname);
colorbar;
fname = sprintf('%s/Al70R_100HL_up.pdf', pname);
savefigure(fname);
%% Analisis de Langford
% Posicion de los picos de las figuras de polos
theta = [1.742 2.013 2.85 3.337 3.494 4.028 4.391];
% Longitud de onda de la radiacion en nm
lambda = 0.014235;
% Generacion de las figuras de polos de tamaño de dominio y deformacion
% acumulada
% strain_pf = rotate(Al70R_H_pfd, yrot);
% size_pf = rotate(Al70R_E_pfd, yrot);
% [size_pf, strain_pf] = Langford_batch(Al70R_H_pfd, Al70R_E_pfd, lambda, theta);
[size_pf, strain_pf] = Langford_batch(Al70R_H_pfu, Al70R_E_pfu, lambda, theta);
%% Postprocesado
size_pf(1) = regularizacion(size_pf(1), 10, 95, 0);
size_pf(2) = regularizacion(size_pf(2), 8, 95, 0);
size_pf(3) = regularizacion(size_pf(3), 5, 95, 0);
size_pf = regular_pf(size_pf, 5, 5, 'nearest');
% Calculo el microstrain
strain_pf = 1e6 .* strain_pf;
strain_pf = regularizacion(strain_pf(1:3), 5, 95, 1);
strain_pf = regular_pf(strain_pf, 5, 5, 'nearest');
%% Grafico los resultados
figure(3);
% size_pf = rotate(size_pf, yrot);
plot(size_pf(1:3), 'contourf');
fname = sprintf('%s/Al70R_size_ind_up.pdf', pname);
savefigure(fname);
colorbar;
fname = sprintf('%s/Al70R_size_up.pdf', pname);
savefigure(fname);
figure(4);
% strain_pf = rotate(strain_pf, yrot);
plot(strain_pf(1:3), 'contourf');
fname = sprintf('%s/Al70R_mustrain_ind_up.pdf', pname);
savefigure(fname);
colorbar;
fname = sprintf('%s/Al70R_mustrain_up.pdf', pname);
savefigure(fname);