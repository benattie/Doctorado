%% Borrar las variables
clear all;
%% Importar los datos y crear las PF
Al70R_CMWP_sol_importscript
%% Postprocesado de los datos
Al70R_CMWP_sol_postscript

%% Rotacion de las figuras de polos
% yrot = rotation('axis', yvector, 'angle', 90 * degree);
% Al70R_SOL_pfcr = rotate(Al70R_SOL_pfc, yrot);
%% Obtengo las soluciones fisicas a partir de los ajustes

%% Grafico las soluciones
% Al70R_CMWP_plotscript