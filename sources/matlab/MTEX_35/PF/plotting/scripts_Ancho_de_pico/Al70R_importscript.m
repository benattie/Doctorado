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
pname = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/out';

% which files to be imported
fname = {...
  [pname '/New_Al70R-tex_PF_1.mtex'],...
  [pname '/New_Al70R-tex_PF_2.mtex'],...
  [pname '/New_Al70R-tex_PF_3.mtex'],...
  [pname '/New_Al70R-tex_PF_4.mtex'],...
  [pname '/New_Al70R-tex_PF_5.mtex'],...
  [pname '/New_Al70R-tex_PF_6.mtex'],...
  [pname '/New_Al70R-tex_PF_7.mtex'],...
  };
%% Specify Miller Indice

h = { ...
  Miller(1,1,1,CS),...
  Miller(2,0,0,CS),...
  Miller(2,2,0,CS),...
  Miller(3,1,1,CS),...
  Miller(2,2,2,CS),...
  Miller(4,0,0,CS),...
  Miller(3,3,1,CS),...
  };

%% Preprocess the data (separate upper hemisphere from lower hemisphere)
[nrow,ncol] = size(fname);
for i=1:ncol
    fp = fopen(char(fname(i)), 'r');
    tline = fgets(fp);
    tline = fgets(fp);
    header = textscan(fp, '%s', 21, 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    data = textscan(fp, '%d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    matdata = cell2mat(data(2:end));
    fclose(fp);
    % escribo los datos de la esfera superior
    mat = [matdata(:,1),matdata(:,3:4),matdata(:,6:2:10)]; 
    [nrows,ncol] = size(mat);
    foutu{i} = sprintf('%s/Al70R_up_%d.mtex', pname, i);
    dlmwrite(foutu{i}, mat(1:nrows/2,:), 'Delimiter', '\t');
    % tengo que reescribir los angulos porque salen mal desde IDEA
    mat = [matdata(int32(nrows/2) + 1:end,1),matdata(int32(nrows/2) + 1:end,3:4),matdata(int32(nrows/2) + 1:end,6:2:10)]; 
    % extraigo la columna con el angulo azimutal
    beta = mat(:, 3);
    % intercambio la posicion del primer y el cuarto cuadrante
    beta((beta > 0 & beta < 90) | (beta > 270 & beta < 360))  = 360 - beta((beta > 0 & beta < 90) | (beta > 270 & beta < 360));
    % escribo los datos corregidos
    mat = [mat(:,1:2),beta,mat(:,4:end)];
    foutd{i} = sprintf('%s/Al70R_down_%d.mtex', pname, i);
    dlmwrite(foutd{i}, mat, 'Delimiter', '\t');
end

%% Import the Data
% create a Pole Figure variable containing the data
% Treshold = 5
% Upper Hemisphere
Al70R_I_pfu = loadPoleFigure(foutu,h,CS,SS,'interface','generic',...
  'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 4], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
Al70R_H_pfu = loadPoleFigure(foutu,h,CS,SS,'interface','generic',...
  'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 5], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
Al70R_E_pfu = loadPoleFigure(foutu,h,CS,SS,'interface','generic',...
  'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 6], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
% Lower Hemisphere
% Al70R_I_pfd = loadPoleFigure(foutd,h,CS,SS,'interface','generic',...
%   'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 4], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
% Al70R_H_pfd = loadPoleFigure(foutd,h,CS,SS,'interface','generic',...
%   'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 5], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
% Al70R_E_pfd = loadPoleFigure(foutd,h,CS,SS,'interface','generic',...
%   'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [2 3 6], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');

%% Plot the data
% figure(1);
% plot(normalize(Al70R_I_pfu(1:3)));
% figure(2);
% plot(Al70R_H_pfu);
% figure(3);
% plot(Al70R_E_pfu);
% 
% figure(2);
% plot(normalize(Al70R_I_pfd(1:3)));
% yrot = rotation('axis', yvector, 'angle', 90 * degree);
% pf = rotate(Al70R_I_pfd, yrot);
% figure(3);
% plot(normalize(pf(1:3)));
% figure(5);
% plot(Al70R_H_pfd);
% figure(6);
% plot(Al70R_E_pfd);
