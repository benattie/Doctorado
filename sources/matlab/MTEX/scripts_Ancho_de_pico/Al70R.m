%% Limpiar el espacio de trabajo
clear all;
%% Importar los datos
AlARMH_importscript
% Path para guardar las figuras
pname = '/home/benattie/Documents/Doctorado/XR/Sync/AlARMH/out/figures';
%% Post procesar los datos
% Elimino outliers
AlARMH_I_postscript
AlARMH_H_postscript
AlARMH_E_postscript
% Rotacion
yrot = rotation('axis', yvector, 'angle', 90 * degree);
%% Mostrar y guardar las figuras
% Path para guardar las figuras
figpath = sprintf('%s/figures', pname);
mkdir(figpath);
AlARMH_plotscript
%% Analisis de Langford
AlARMH_langfordscript
