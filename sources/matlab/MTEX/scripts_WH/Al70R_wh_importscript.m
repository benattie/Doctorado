%% Import Script for PoleFigure Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = symmetry('cubic');

% specimen symmetry
SS = symmetry('triclinic');

% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names

% path to files
pname = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/wh_plots/qmin';

% which files to be imported
fname = {...
%   [pname '/New_Al70R-tex_PF_BREADTH_1_WH_R.dat'],...
%   [pname '/New_Al70R-tex_PF_BREADTH_2_WH_R.dat'],...
  [pname '/New_Al70R-tex_PF_BREADTH_1_WH_R.dat'],...
%   [pname '/New_Al70R-tex_PF_FWHM_2_WH_R.dat'],...
  };
%% Specify Miller Indice

h = { ...
    Miller(1,0,0,CS),...
    Miller(2,0,0,CS),...
    Miller(1,1,0,CS),...
    Miller(2,2,0,CS)...
    };

%% Preprocess the data (separate upper hemisphere from lower hemisphere)
[nrow,ncol] = size(fname);
for i=1:ncol
    fp = fopen(char(fname(i)), 'r');
%     tline = fgets(fp);
%     tline = fgets(fp);
    % tline = fgets(fp);
    header = textscan(fp, '%s', 11, 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    data = textscan(fp, '%d %f %f %f %f %f %f %f %f %f ', 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    matdata = cell2mat(data(2:end));
    fclose(fp);
    
    mat = [matdata(:,1:end)]; 
    [nrows,ncol] = size(mat);
    % Escribo los datos de la esfera superior
    fout{i} = sprintf('%s/Al70R_wh_up_%d.mtex', pname, i);
    dlmwrite(fout{i}, mat(1:nrows/2,:), 'Delimiter', '\t');
    % Escribo los datos de la esfera inferior
%     fout{i} = sprintf('%s/Al70R_wh_down_%d.mtex', pname, i);
%     dlmwrite(fout{i}, mat(int32(nrows/2) + 1:end,:), 'Delimiter', '\t');
end

%% Import the Data
[nrow,ncol] = size(fname);
for i=1:ncol
    Al70R_delta_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 3], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_q_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 4], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_Ch00_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 5], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_rho_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 7], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_D_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 6], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_R_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 8], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    
    Al70R_chi_pfd(i) = loadPoleFigure(fout(i),h(i),CS,SS,'interface','generic',...
        'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 9], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
end

%% Grafico los datos
% figure(1);
% plot(Al70R_delta_pfd);
% figure(2);
% plot(Al70R_q_pfd);
% figure(3);
% plot(Al70R_Ch00_pfd);
% figure(4);
% plot(1e18 .* Al70R_rho_pfd);
% figure(5);
% plot(Al70R_D_pfd);