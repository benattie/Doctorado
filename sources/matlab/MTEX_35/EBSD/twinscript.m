%**************************************************************************
%% Detecting twins - For example for FCC metals
%                   Sigma 3 twin 3 <111> / 60.0 degrees
%               and Sigma 9 twin 9 <110> / 38.9 degrees
%**************************************************************************
%
% Define misorientation rotations for twins
%
% Sigma 3 twin <111> / 60 degrees
Sigma_3 = rotation('axis',Miller(1,1,1,CS,'uvw','phase','Copper'),'angle',60.0*degree)
% Sigma 9 twin 9 <110> / 38.9 degrees
Sigma_9 = rotation('axis',Miller(1,1,0,CS,'uvw','phase','Copper'),'angle',38.9*degree)
%**************************************************************************
%% Estimate twin fractions
%**************************************************************************
% Calculate twin boundary segment length satisfying the special rotation
% of twins within detection error for each grain
%
Detection_angle = 2.0*degree;
% Sigma3
Sigma3_length = sum(perimeter(selected_grains,Sigma_3,'delta',Detection_angle));
% Sigma9
Sigma9_length = sum(perimeter(selected_grains,Sigma_9,'delta',Detection_angle));
% Total lengths of all plagioclase twins
Total_Twin_length = Sigma3_length + Sigma9_length;
% Total length of all Steel boundaries (twins and others)
Total_Grain_Steel_length = sum(perimeter(selected_grains));
% Fractions : Twin/total Twin
% Sigma3
Sigma3_Fraction = 100 * Sigma3_length/Total_Grain_Steel_length;
% Sigma 9
Sigma9_Fraction = 100 * Sigma9_length/Total_Grain_Steel_length;
Total_Twin_Fraction_Al =  100 * Total_Twin_length/Total_Grain_Steel_length;
%
%**************************************************************************
% Print twin table
%**************************************************************************
fprintf('   \n')
fprintf(' %s steel twin table \n', name)
fprintf('   \n')
fprintf('%s %6.2f\n',' Detection angle =',Detection_angle/degree)
fprintf(' -----------------------------------------\n')
fprintf(' Twin law                            Twin fractions (%%) \n')
fprintf('%s %6.2f  \n',' Sigma 3 twin <111> / 60.0 degrees ',Sigma3_Fraction)
fprintf('%s %6.2f  \n',' Sigma 9 twin <110> / 38.9 degrees ',Sigma9_Fraction)
fprintf('   \n')
fprintf('%s %6.2f  \n',' All twins/all Steel boundaries ',Total_Twin_Fraction_Al)
fprintf('   \n')
%%
%**************************************************************************
% Figure : ALL Detectable twins
% use twin fractions above 'low_fraction_limit' to reduce plotting time
%**************************************************************************
figure('position',[200 200 plot_w plot_h])
plotBoundary(grains,'linecolor','black','linewidth',1)
hold all
% detection error +/- 2 degrees
angle_error = 2.0*degree;
% low fraction limit 0.5 percent
low_fraction_limit = 0.005;
%
% Sigma3
if(Sigma3_Fraction > low_fraction_limit)
  plotBoundary(selected_grains,'property',Sigma_3,'delta',angle_error,'linecolor','blue','linewidth',2)
end
% Sigma9
if(Sigma9_Fraction > low_fraction_limit)
  plotBoundary(selected_grains,'property',Sigma_9,'delta',angle_error,'linecolor','red','linewidth',2)
end
hold off
legend('Grain boundary',...
       'Sigma 3',...)
       'Sigma 9', 'Location','NorthEastOutside')
title('All detectable twins : Steel 900C','FontSize',16)
% save plot
figname = ...
    sprintf('%s/Plot_all_twins_%s.pdf', pname, name);
savefigure(figname);
%