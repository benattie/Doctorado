%**************************************************************************
%% Removing small grains - not representative small grains, may be errors
%**************************************************************************
% You can loop over this cell changing number of indexed points per grain
% You should compared the resulting grain map with EBSD (pixel) phase
% or orientation (pixel) map
%**************************************************************************
%
disp(' ')
disp(' Small grains option ')
disp(' Remove small grains containing less than a critical')
disp(' number of indexed points as they error prone or ')
disp(' If you require an accurate grain size and shape analysis')
disp(' the recommended minimum number indexed points per grain size is 10')
disp(' You can decide to keep all grain by accepting all grains with 0')
small_grains_option = input('Indexed points per grain an integer (e.g. 0-10):');
%
% remove grains containing less than critical number of indexed points, 
selected_grains = grains(grainSize(grains)>small_grains_option);
% number of ORIENTATIONS using length
n_Steel_orientations = length(grains)
% number of GRAINS using numel
n_Steel_grains = numel(grains)
% plot 'grain' map
figure('position',[200 200 plot_w plot_h])
plot(selected_grains,'property','phase')
figname = sprintf('%s/Grain_%s_withoutsmallgrains_%d.pdf',...
        pname, name, small_grains_option);
savefigure(figname);
%