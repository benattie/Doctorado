%% Borrar las variables
clear all;
%% Importar los datos y crear las PF
Al70R_CMWP_fit_importscript
%% Postprocesado de los datos
Al70R_CMWP_fit_postscript

%% Rotacion de las figuras de polos
% yrot = rotation('axis', yvector, 'angle', 90 * degree);
% Al70R_fit_pfcr = rotate(Al70R_fit_pfc, yrot);

%% Grafico las soluciones
Al70R_CMWP_fit_plotscript