%***********************************************************************
%% Fix the map aspect ratio and dimensions
%***********************************************************************
ratio = (max(get(ebsd,'x')) - min(get(ebsd,'x')))...
       /(max(get(ebsd,'y')) - min(get(ebsd,'y')));
% plot height (you can change this value)
% I normally use for plot_h = 600
% But for teaching larger plots with plot_h = 1200 is useful
plot_h = 600;
% plot width with correct aspect ratio
plot_w = round(plot_h*ratio);

%% Standard gray map 8-bit image quality (IQ) Map - good indicator of grain boundaries
% non-index is black and grain internal microstructure more visible
% 255 levels RGB=000 (black) to RGB=111 (white)
close all
figure('position',[200 200 plot_w plot_h])
plot(ebsd,'property','bc');
mtexColorMap black2white
colorbar;
figname = sprintf('%s/Image_Quality_map_%s.pdf', pname, name);
savefigure(figname);

%% Orientation IPF map sample direction Z
close all
figure('position',[0 0 plot_w plot_h])
% IPF sample direction z 'into plane' direction EBSD map (r = zvector)
plot(ebsd,'colorcoding','ipdfHSV','r',zvector,'antipodal')
% red grains   [100]//Z
% green grains [101]//Z
% blue grains  [111]//Z
figname = sprintf('%s/Orientation_map_ipf_z_%s.pdf', pname, name);
savefigure(figname);
%% inverse pole figure (IPF) colorbar for orientation
ebsdColorbar(symmetry('m-3m'),'antipodal')
% title of colorbar
title('IPF colorbar cubic 43 antipodal','FontSize',12)
figname = sprintf('%s/IPF_colorbar_Cubic_43_%s.pdf', pname, name);
savefigure(figname);