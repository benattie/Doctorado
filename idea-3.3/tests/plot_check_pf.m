%% Import Script for PoleFigure Data
%
% This script was automatically created by the import wizard. You should
% run the whoole script or parts of it in order to import your data. There
% is no problem in making any changes to this script.

%% Specify Crystal and Specimen Symmetries

% crystal symmetry
CS = crystalSymmetry('m-3m', [1 1 1]);

% specimen symmetry
SS = specimenSymmetry('1');

% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

%% Specify File Names

% path to files
pname = '/home/benattie/Documents/Doctorado/Git/idea-3.3/tests';

% which files to be imported
fname = [pname '/check_pf.dat'];

%% Specify Miller Indice

h = { ...
  Miller(1,0,0,CS),...
  };

%% Import the Data

% create a Pole Figure variable containing the data
pf = loadPoleFigure(fname,h,CS,SS,'interface','generic',...
  'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [5 6 7]);
figure;
plot(pf)
