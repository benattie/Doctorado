%**************************************************************************
%% Image quality (IQ) with misorientation boundaries all angles black
%**************************************************************************
% close all
figure('position',[200 200 plot_w plot_h])
% band contrast map
plot(ebsd,'property','bc');
% gray color map
colormap(gray)
%colorbar
hold on
% misorientation boundaries color 'k' = black
plotBoundary(selected_grains,'linecolor','k','linewidth',0.2)
hold off
title('Image quality (IQ) map with misorienation boundaries (black)','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/IQ_map_with white_grain_sub_boundaries_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Orientation IPF map sample direction Z with blue misorientation boundaries
%**************************************************************************
% close all
figure('position',[200 200 plot_w plot_h])
% IPF sample direction z 'into plane' direction EBSD map (r = zvector)
plot(ebsd,'colorcoding','ipdfHSV','r',zvector,'antipodal')
% Standard IPF colorbar for High-Cubic (43) with antipodal option
% red grains   [100] parallel sample Z
% green grains [101] parallel sample Z
% blue grains  [111] parallel sample Z
hold on
% misorientation boundaries color 'b' = blue
plotBoundary(selected_grains,'linecolor','b','linewidth',0.2)
hold off
title('Orientation IPF-Z map with misorienation boundaries (blue)','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/IPF_z_map_with_blue_grain_sub_boundaries_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% EBSD map with misorientation boundaries angle ranges in colour
% With No overlay
%**************************************************************************
% close all
figure(2);
figure('position',[200 200 4*plot_w 4*plot_h])
% plot all misorientation boundaries of all angles as black lines (k=black)
plotBoundary(selected_grains,'linecolor','k','linewidth',1.5)
hold on
LineThickness = 2;

%Forma 1
% superpose misorientation boundaries with specific angle ranges
% 20-25 magenta, 15-20 cyan, 10-15 blue,5-10 green,0-5 red
plotBoundary(selected_grains,'property',[20 25]*degree,'linecolor','m','linewidth',LineThickness)
plotBoundary(selected_grains,'property',[15 20]*degree,'linecolor','c','linewidth',LineThickness)
plotBoundary(selected_grains,'property',[10 15]*degree,'linecolor','b','linewidth',LineThickness)
plotBoundary(selected_grains,'property',[ 5 10]*degree,'linecolor','g','linewidth',LineThickness)
plotBoundary(selected_grains,'property',[ 1  5]*degree,'linecolor','r','linewidth',LineThickness)
hold off
% legend
legend('>25^\circ',...
       '20^\circ-25^\circ',...
       '15^\circ-20^\circ',...
       '10^\circ-15^\circ',...
       '5^\circ-10^\circ',...
       '0^\circ-5^\circ','Location','EastOutside')
% Fin Forma 1

% Forma 2
% Otra forma de caracterizar los bordes de subgranos es utilizar el comando
% siguiente, que va a colorear en forma continua, de azul (0 grados)
% a rojo (20 grados en este caso) los bordes de grano. Los bordes que
% quedan fuera del rango son coloreados en negro.
% Si se trabaja con este comando es preciso comentar las lineas precedentes
% que contienen el comando plotBoundary
% plotBoundary(grains, 'property', zvector, 'delta', 20*degree, 'linewidth', LineThickness)
% colorbar
% Fin Forma 2

% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
title('Misorientation boundaries colour angles map','FontSize',16)
% save plot
figname = ...
    sprintf('%s/Map_with_colour_grain_sub_boundaries_ranges_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Plot internal misorientation AXES from mean grain orientations
% No over lay
%**************************************************************************
% close all;
figure('position',[200 200 plot_w plot_h])
plot(selected_grains,'property','mis2mean','antipodal')
colorbar
title('Misorientation AXES from the mean map','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/Grain_map_mis2mean_Axes_only_color_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Plot internal misorientation AXES from mean grain orientations (antipodal)
%**************************************************************************
% close all;
figure('position',[100 100 plot_w plot_h])
hold all
plot(selected_grains,'property','mis2mean','antipodal')
plotBoundary(selected_grains,'linecolor','k','linewidth',1.5)
hold off
title('Misorientation AXES from the mean map','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/Grain_map_mis2mean_Axes_boundaries_color_antipodal_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% plot internal misorientation ANGLES from the mean grain orientations
%**************************************************************************
% close all;
figure('position',[100 100 5*plot_w 5*plot_h])
hold all
plot(selected_grains,'property','mis2mean','colorcoding','angle')
plotBoundary(selected_grains,'linecolor','k','linewidth',1.5)
hold off
colorbar
title('Misorientation ANGLES from the mean map','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/Grain_map_mis2mean_Angle_boundaries_color_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% 1st order Kernel average misorientation angle between adjacent measurements
%**************************************************************************
% close all;
figure('position',[100 100 5*plot_w 5*plot_h])
plotKAM(selected_grains)
hold on
plotBoundary(selected_grains,'linecolor','k','linewidth',1.5)
colorbar
title('Kernel average misorientation (KAM) 1st order map','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/Map_KAM_1st_angles_from_mean_within_grains_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% 2nd order Kernel average misorientation angle between adjacent measurements
%**************************************************************************
% close all;
figure('position',[100 100 5*plot_w 5*plot_h])
plotKAM(selected_grains,'secondorder')
hold on
plotBoundary(selected_grains,'linecolor','k','linewidth',1.5)
colorbar
title('Kernel average misorientation (KAM) 2nd order map','FontSize',16)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','opengl')
% save plot
figname = ...
    sprintf('%s/Map_KAM_2nd_angles_from_mean_within_grains_%s.pdf', pname, name);
savefigure(figname);