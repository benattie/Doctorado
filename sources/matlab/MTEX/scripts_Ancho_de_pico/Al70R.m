%% Limpiar el espacio de trabajo
clear all;
%% Importar los datos
Al70R_importscript
% Path para guardar las figuras
pname = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/out/figures';
%% Post procesar los datos
% Elimino outliers
Al70R_I_postscript
Al70R_H_postscript
Al70R_E_postscript
% Rotacion
yrot = rotation('axis', yvector, 'angle', 90 * degree);
%% Graficar y guardar los datos
Al70R_plotscript
%% Analisis de Langford
Al70R_langfordscript