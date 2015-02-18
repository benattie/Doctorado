%**************************************************************************
%% Single grain analysis
%**************************************************************************
%% Plot all grains and select a grain using the a curser on the phase map
%**************************************************************************
% plot grain map
close all
figure('position',[0 0 plot_w plot_h])
plot(selected_grains,'property','phase')
% selecting a single grain by x,y coordinates
disp(' ') 
disp('Select grain with cursor and one mouse click')
disp(' ')
%helpdlg('Move cursor to grain, CLICK to select','GRAIN SELECTION')
% Displays a cursor over the map and waits for one click on the selected grain 
[xgg, ygg]=ginput(1); 
% select single grain by position in map
selected_single_grain = findByLocation(grains,[xgg  ygg])
% fix the grain map aspect ratio and dimensions
ratio = (max(get(selected_single_grain,'x')) - min(get(selected_single_grain,'x')))...
       /(max(get(selected_single_grain,'y')) - min(get(selected_single_grain,'y')));
% plot height (you can change this value)
plot_hgrain = 1200;
% plot width with correct aspect ratio
plot_wgrain = round(plot_hgrain*ratio);
% calculates the x,y barycenter of the  single grain-polygon
bary_center_xy = centroid(selected_single_grain);
figure('position',[0 0 plot_wgrain plot_hgrain])
% plot boundary, grain, bary center (red square)
plotBoundary(selected_single_grain,'linewidth',2)
hold on
plot(bary_center_xy(1),bary_center_xy(2),...
 's','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10)
hold off
grain_mean_orientation = get(selected_single_grain,'meanOrientation')
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Selected_Single_grain_1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Visualize the misorientation ANGLE from mean within a grain
% with black grain boundaries
%**************************************************************************
close all
% get all misorientations from the mean orientation
o = get(selected_single_grain,'mis2mean')
max_deviation_degrees = max(angle(o))/degree
min_deviation_degrees = min(angle(o))/degree
% plot misorientation angles from the mean
figure('position',[200 200 plot_wgrain plot_hgrain])
hold all
plotspatial(selected_single_grain,'property',angle(o)/degree)
%hold on
LineThickness = 3;
% superpose misorientation boundaries with specific angle ranges
% 20-25 magenta, 15-20 cyan, 10-15 blue,5-10 green,0-5 red
plotBoundary(selected_single_grain,'property',[20 25]*degree,'linecolor','m','linewidth',LineThickness)
plotBoundary(selected_single_grain,'property',[15 20]*degree,'linecolor','c','linewidth',LineThickness)
plotBoundary(selected_single_grain,'property',[10 15]*degree,'linecolor','b','linewidth',LineThickness)
plotBoundary(selected_single_grain,'property',[ 5 10]*degree,'linecolor','g','linewidth',LineThickness)
plotBoundary(selected_single_grain,'property',[ 2  5]*degree,'linecolor','r','linewidth',LineThickness)
hold off
title('Misorientation ANGLE from mean within single grain - color boundaries','FontSize',18)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Misorientation_angles_from_mean_within_grain_plus_color_GB_1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Visualize the misorientation ANGLE from mean within a grain
% no grain boundaries but with colorbar
%**************************************************************************
close all
% get all misorientations from the mean orientation
o = get(selected_single_grain,'mis2mean')
max_deviation_degrees = max(angle(o))/degree
min_deviation_degrees = min(angle(o))/degree
% plot misorientation angles from the mean
figure('position',[200 200 plot_wgrain plot_hgrain])
plotspatial(selected_single_grain,'property',angle(o)/degree)
colorbar
title('Misorientation ANGLE from mean within single grain','FontSize',18)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Misorientation_angles_from_mean_within_grain_1_plus_colorbar_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Visualize the misorientation AXIS from mean within a grain
%**************************************************************************
close all
figure('position',[200 200 plot_wgrain plot_hgrain])
hold on
plotspatial(selected_single_grain,'property','mis2mean','antipodal')
% plot grain boundary
plotBoundary(selected_single_grain,'linewidth',2)
hold off
title('Misorientation Axis from mean within single grain','FontSize',18)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Misorientation_axes_from_mean_within_grain_1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% 1st order Kernel average misorientation angle between adjacent measurements
%**************************************************************************
close all
figure('position',[200 200 plot_wgrain plot_hgrain])
plotKAM(selected_single_grain)
hold on
plotBoundary(selected_single_grain,'linecolor','k','linewidth',2)
colorbar
title('Kernel average misorientation (KAM) 1st order map','FontSize',18)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Map_KAM_1st_angles_from_mean_within_grains_1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% 2nd order Kernel average misorientation angle between adjacent measurements
%**************************************************************************
close all
figure('position',[200 200 plot_wgrain plot_hgrain])
plotKAM(selected_single_grain,'secondorder')
hold on
plotBoundary(selected_single_grain,'linecolor','k','linewidth',2)
colorbar
title('Kernel average misorientation (KAM) 2nd order map','FontSize',18)
% Correct MatLab problem with colour buffer
set(gcf,'renderer','zbuffer')
% save plot
figname = ...
    sprintf('%s/Map_KAM_2nd_angles_from_mean_within_grains_1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% plot a histogram of the misorientation angles from the mean
%**************************************************************************
close all
figure('position',[0 0 600 600])
Mis_data = angle(o)/degree;
% stats
max_Mis = max(Mis_data)
min_Mis = min(Mis_data)
mean_Mis = mean(Mis_data)
std_dev_Mis = std(Mis_data)
nbins = 25;
hist(Mis_data,nbins)
xlabel('Misorientation angles in degrees','FontSize',18)
ylabel('Counts','FontSize',18)
title('Histogram of the misorientation angles from the mean - single grain','FontSize',18)
% save plot
figname = ...
    sprintf('%s/Histo_misorientation_angles_from_mean_within_grain1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Kernel averaged misorientation (KAM) histogram
%**************************************************************************
KAM_data = calcKAM(selected_grains)/degree;
% remove NaN from array
KAM_data=(KAM_data(isfinite(KAM_data)));
% stats
max_KAM = max(KAM_data)
min_KAM = min(KAM_data)
mean_KAM = mean(KAM_data)
std_dev_KAM = std(KAM_data)
nbins = 25;
figure('position',[0 0 600 600])
hist(KAM_data,nbins)
xlabel('Misorientation angles in degrees','FontSize',18)
ylabel('Counts','FontSize',18)
title('Kernel averaged misorientation (KAM) histogram - single grain','FontSize',18)
% save plot
figname = ...
    sprintf('%s/Histo_KAM_angles_from_mean_within_grain1_%s.png', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Find number of neighbouring grains
%**************************************************************************
[n_neighbours,pairs] = neighbors(selected_grains);
max_neighbours = max(n_neighbours)
min_neighbours = min(n_neighbours)
mean_neighbours = mean(n_neighbours)
std__neighbours = std(n_neighbours)
nbins = 90;
figure('position',[0 0 600 600])
hist(n_neighbours,nbins)
xlabel('Number of neighbours','FontSize',18)
ylabel('Counts','FontSize',18)
title('Number of neighbours for all grains','FontSize',18)
% save plot
figname = ...
    sprintf('%s/Histo_number_neighbours_%s.png', pname, name);
savefigure(figname);

%**************************************************************************
%% Find number of neighbouring grains - zoom
%**************************************************************************
[n_neighbours,pairs] = neighbors(selected_grains);
n_neighbours=(n_neighbours(n_neighbours<11));
max_neighbours = max(n_neighbours)
min_neighbours = min(n_neighbours)
mean_neighbours = mean(n_neighbours)
std__neighbours = std(n_neighbours)
nbins = 10;
figure('position',[0 0 600 600])
hist(n_neighbours,nbins)
xlabel('Number of neighbours','FontSize',18)
ylabel('Counts','FontSize',18)
title('Number of neighbours for all grains','FontSize',18)
% save plot
figname = ...
    sprintf('%s/Histo_number_neighbours_zoom_%s.png', pname, name);
savefigure(figname);
%