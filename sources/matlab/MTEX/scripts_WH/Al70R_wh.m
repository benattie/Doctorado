%% Para entender que se representa en cada gráfica ver
% Ungar et al Mat Science and Eng. A319-321 (2001) 274-278
%% Limpiar el espacio de trabajo
clear all;
%% Importar los datos
Al70R_wh_importscript;
%% Postprocesado
Al70R_wh_postscript;
%% Mostrar y guardar las figuras
% Path para guardar las figuras
figpath = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/wh_plots/figures';
% Rotacion (eje de laminado hacia arriba)
% yrot = rotation('axis', yvector, 'angle', 90 * degree);
Al70R_wh_plotscript