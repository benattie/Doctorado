%**************************************************************************
%% Detect grains using the segmentation angle and keep non-indexed option
%**************************************************************************
%
% You can loop over this cell changing segmentation angle and the
% the 'keepNotIndexed' options
% You should compared the resulting grain map with EBSD (pixel) phase
% or orientation (pixel) map
%**************************************************************************
%
disp(' ')
disp(' Grain segmentation angle option ')
disp(' Choose a high angle typically between 10 to 15 degrees for geological samples')
disp(' OR choose low angle of 2 degrees if you want to detect sub-grains')
segmentation_angle = input('The segmentation angle (e.g. 2-15):');
segAngle = segmentation_angle*degree;
%
disp(' ')
disp(' Keep non-indexed points option ')
disp('*1= Scientifically correct, not extrapolating raw indexed data')
disp('    model grains BUT keep non-index points')
disp(' 2= May be more geologically correct in some cases, use with care')
disp('    model grains AND include non-index points within grains boundaries')
disp('    N.B. this option does NOT ADD map pixels with neighouring ORIENTATIONS')
non_indexed_option = input('Option an integer  (1-2):');
% non_indexed_option = 1;
%
% keep non-indexed
if(non_indexed_option == 1)
  grains = calcGrains(ebsd,'angle',segAngle,'keepNotIndexed')
end
% remove non-indexed points
if(non_indexed_option == 2)
  grains = calcGrains(ebsd,'angle',segAngle)
end
%
% number of ORIENTATIONS using length
n_orientations = length(grains)
% number of GRAINS using numel
n_grains = numel(grains)
% plot 'grain' phase map
figure('position',[200 200 plot_w plot_h])
plot(grains,'property','phase')
figname = sprintf('%s/Grain_%s_mis_%d_degrees.pdf',...
        pname, name, segmentation_angle);
savefigure(figname);