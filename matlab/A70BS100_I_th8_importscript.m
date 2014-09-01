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
pname = '/home/benattie/Documents/Doctorado/Git/tmp/A70BS100/out/cut_pole_figures/raw';

% which files to be imported
fname = {...
  [pname '/int_New_A70-BS100-20sek-Tex_ALL_PF_1.mtex'],...
  [pname '/int_New_A70-BS100-20sek-Tex_ALL_PF_2.mtex'],...
  [pname '/int_New_A70-BS100-20sek-Tex_ALL_PF_3.mtex'],...
  [pname '/int_New_A70-BS100-20sek-Tex_ALL_PF_4.mtex'],...
  [pname '/int_New_A70-BS100-20sek-Tex_ALL_PF_5.mtex'],...
 };

%% Specify Miller Indice

h = { ...
  Miller(1,1,1,CS),...
  Miller(2,0,0,CS),...
  Miller(2,2,0,CS),...
  Miller(3,1,1,CS),...
  Miller(2,2,2,CS),...
  };

%% Import the Data

% create a Pole Figure variable containing the data
A70BS100_I_th8_pf = loadPoleFigure(fname,h,CS,SS,'interface','generic',...
  'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [4 5 6], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');

