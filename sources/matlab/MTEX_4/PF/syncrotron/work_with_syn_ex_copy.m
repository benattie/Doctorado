%% Clear everything
close all
clear all

%% Import the data
[AlSR70_pf, ~] = import_sync();
[AlSR70_Hpf, ~] = import_sync('variable', 'FWHM');
[AlSR70_Epf, ~] = import_sync('variable', 'ETA');

%% Cleanup and plot the data
condition = AlSR70_pf.intensities < 0;
AlSR70_pf(condition) = [];
AlSR70_pf(AlSR70_pf.isOutlier) = [];
figure; plot(AlSR70_pf, 'contourf')

condition = AlSR70_Hpf.intensities < 0;
AlSR70_Hpf(condition) = [];
AlSR70_Hpf(AlSR70_Hpf.isOutlier) = [];
figure; plot(AlSR70_Hpf, 'contourf')

condition = AlSR70_Epf.intensities < 0;
AlSR70_Epf(condition) = [];
AlSR70_Epf(AlSR70_Epf.isOutlier) = [];
figure; plot(AlSR70_Epf, 'contourf')

%% Get the data on the left and mirror it
[AlSR70_pf, ~] = symetrise_pf(AlSR70_pf);
figure; plot(AlSR70_pf, 'contourf')
[AlSR70_Hpf, ~] = symetrise_pf(AlSR70_Hpf);
figure; plot(AlSR70_Hpf, 'contourf')
[AlSR70_Epf, ~] = symetrise_pf(AlSR70_Epf);
figure; plot(AlSR70_Epf, 'contourf')