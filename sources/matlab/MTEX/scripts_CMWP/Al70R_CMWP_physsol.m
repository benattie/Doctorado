%% Borrar las variables
clear all;
%% Importar los datos y crear las PF
% Al70R_CMWP_physsol_importscript
Al70R_CMWP_physsol_importscript_simetrico
%% Postprocesado de los datos
Al70R_CMWP_physsol_postscript
%% Rotacion de las figuras de polos
% yrot = rotation('axis', yvector, 'angle', 90 * degree);
% Al70R_SOL_pfcr = rotate(Al70R_SOL_pfc, yrot);
%% Grafico las figuras de polos
Al70R_CMWP_physsol_plotscript