%**************************************************************************
% Determine all MTEX standard Grain Size and Shape parameters
% for ALL phases in 'selected_grains' or selected_grains etc
%**************************************************************************
%
% calculate all parameters
% ** area (with holes = non-indexed points)
g_area = area(selected_grains);
% ** aspect ratio is the ratio between the two (X/Y) principal components
% what we normally use
g_aspectratio = aspectratio(selected_grains);
% centroid = barycenter of the grain-polygon, with respect to its holes
% note that the barycenter can be outside the grain for some complex shapes
g_centroid = centroid(selected_grains);
% equivalent radius er = sqrt(area/pi)
g_equivalentradius = equivalentradius(selected_grains);
% equivalent diameter ed = 2*sqrt(area/pi)
g_equivalentdiameter = 2 * equivalentradius(selected_grains);
% equivalent perimeter ep = 2*pi*equivalent radius
g_equivalentperimeter =  equivalentperimeter(selected_grains);
% calculates the perimeter (p) of a grain, with holes
g_perimeter = perimeter(selected_grains);          
% shapefactor = perimeter/equivalent perimeter = p/ep
% this parameter is more like tortuosity of grain boundaries
% (total boundary length / length for circle with same area)
g_shapefactor = shapefactor(selected_grains);
% increase number of bins for greater resolution
nbins=25;
% text size
font_size_text=16;
% close all plots
close all
%
% **************************************************************************
%% Plot frequency versus equivalent grain diameter
%**************************************************************************
% get counts per bin and bin centres (in microns)
[g_diameter_counts,g_diameter_bin_centres] = hist(g_equivalentdiameter,nbins);
% define bin lo and hi ranges in Equivalent diameter (microns)
% avoid 2 - 1 sometimes gives slight error
Bin_width = g_diameter_bin_centres(3)-g_diameter_bin_centres(2);
Half_bin_width = Bin_width/2.0;
Bin_lo=zeros(nbins);
Bin_hi=zeros(nbins);
for i=1:nbins
    Bin_lo(i) = g_diameter_bin_centres(i)-Half_bin_width;
    Bin_hi(i) = g_diameter_bin_centres(i)+Half_bin_width;
end
% ensure all diameters of data in bin window
Bin_lo(1)=min(g_equivalentdiameter);
Bin_hi(nbins)=max(g_equivalentdiameter);
% Percent counts per bin
g_diameter_percent = (100*g_diameter_counts)/sum(g_diameter_counts);
% plot
figure
bar(g_diameter_bin_centres,g_diameter_percent,'histc')
% plot labels
xlabel('Equivalent grain diameter (microns)','FontSize',font_size_text)
ylabel('Frequency (%)','FontSize',font_size_text)
% plot title
title('Equivalent grain diameter distribution','FontSize',font_size_text)
% save plot
figname = ...
    sprintf('%s/Plot_freqency_grain_diameter_histogram_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Plot frequency versus Log equivalent grain diameter
%**************************************************************************
% get counts per bin and bin centres (in microns)
[g_diameter_counts,g_diameter_bin_centres] = hist(g_equivalentdiameter,nbins);
% define bin lo and hi ranges in Equivalent diameter (microns)
% avoid 2 - 1 sometimes gives slight error
Bin_width = g_diameter_bin_centres(3)-g_diameter_bin_centres(2);
Half_bin_width = Bin_width/2.0;
Bin_lo=zeros(nbins);
Bin_hi=zeros(nbins);
for i=1:nbins
    Bin_lo(i) = g_diameter_bin_centres(i)-Half_bin_width;
    Bin_hi(i) = g_diameter_bin_centres(i)+Half_bin_width;
end
% ensure all diameters of data in bin window
Bin_lo(1)=min(g_equivalentdiameter);
Bin_hi(nbins)=max(g_equivalentdiameter);
% Percent counts per bin
g_diameter_percent = (100*g_diameter_counts)/sum(g_diameter_counts);
% plot
figure
bar(g_diameter_bin_centres,g_diameter_percent,'histc')
% set log grain diameter scale
set(gca,'XScale','log')
% plot labels
xlabel('Log equivalent grain diameter (microns)','FontSize',font_size_text)
ylabel('Frequency (%)','FontSize',font_size_text)
% plot title
title('Equivalent grain diameter distribution','FontSize',font_size_text)
% save plot
figname = ...
    sprintf('%s/Plot_freqency_Log_grain_diameter_histogram_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Grain diameter (plot percent weighted by area fraction)
%**************************************************************************
%
% Total surface area
Total_surface_area = sum(g_area);
% accumulate in bins
n_sample=length(g_equivalentdiameter);
area_per_bin = zeros(nbins);
area_counts_per_bin = zeros(nbins);
for n=1:n_sample
% search bins
      for i=1:nbins
           if (g_equivalentdiameter(n) >= Bin_lo(i)) && ...
              (g_equivalentdiameter(n) <= Bin_hi(i))
              area_per_bin(i)=area_per_bin(i)+g_area(n);
              area_counts_per_bin(i)=area_counts_per_bin(i)+1;
           end
      end
end
% Percent surace area per bin
g_counts_percent_wt_area = zeros(nbins);
for i=1:nbins
    g_counts_percent_wt_area(i) = 100.0*area_per_bin(i,1)/Total_surface_area;
end
% get array into format (1 x ibin)
g_counts_percent_wt_area2 = g_counts_percent_wt_area(:,1);
% transpose
g_counts_percent_wt_area3 = g_counts_percent_wt_area2';
% plot
figure;
bar(g_diameter_bin_centres,g_counts_percent_wt_area2,'histc')
xlabel('Grain diameter (microns)','FontSize',font_size_text)
ylabel('Frequency (%)','FontSize',font_size_text)
% plot title
title('Grain diameter distribution - Weighted by Area fraction','FontSize',font_size_text)
% save plot
figname = ...
    sprintf('%s/Plot_hist_grain_diameter_wt_area_%s.pdf', pname, name);
savefigure(figname);
%
%**************************************************************************
%% Grain diameter (plot percent counts AND weighted by area fraction)
%**************************************************************************
% vertically concatenates and transposed
Combined_count_wt_area = [g_diameter_percent; g_counts_percent_wt_area3]';
% plot
figure;
bar(g_diameter_bin_centres,Combined_count_wt_area,'histc')
xlabel('Equivalent Grain diameter (microns)','FontSize',font_size_text)
ylabel('Frequency (%)','FontSize',font_size_text)
% plot title
title('Grain diameter distribution - Number & Area fraction','FontSize',font_size_text)
hold off
legend('Number','Area fraction')
% save plot
figname = ...
    sprintf('%s/Plot_hist_grain_diameter_counts_wt_area_%s.pdf', pname, name);
savefigure(figname);