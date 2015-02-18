%% Limpiar el espacio de trabajo
clear all;
%% Nombre para identificar el conjunto de archivos
name = 'Dual_phase';
%% Importar los datos. El usuario debería crear este script.
importscript
%% Graficar los datos crudos
plotscript
%% Reconstruir los granos para una dada misorientacion
grainrecontructionscript
%% Seleccion y procesamiento de los datos a partir de granos seleccionados por tamaño
grainselectionscript
%% Histogramas de tamaño de grano
grainscript_freqplots
%% Graficar los bordes de grano y los subgranos
grainscript_subgrains
%% Estimacion de fracciones de maclas a partir de los granos seleccionados
% Solo para FCC!
% twinscript
%% Los mismos analisis que se hacen en F138_900_grainselectionscript,
% pero a partir de un unico grano seleccionado por el usuario
%
% F138_900_singlegrainscript
%% Pongo todas las figuras en la carpeta figures
movefile('*.pdf', 'figures/');
%% Cierro todas las ventanas abiertas
close all;
