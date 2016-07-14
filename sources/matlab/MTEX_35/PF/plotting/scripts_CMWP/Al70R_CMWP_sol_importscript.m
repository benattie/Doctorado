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
pname = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/cmwp/semilla_inicial/cmwp_idea_pole_figures';

% which files to be imported
fname = [pname '/New_Al70R-tex_CMWP_SOL_PF.mtex'];

%% Import the Data
% create a Pole Figure variable containing the data
for i = 1:5
    h(i) = Miller(i,i,i,CS);
    Al70R_SOL_pf(i) = loadPoleFigure(fname,h(i),CS,SS,'interface','generic',...
      'ColumnNames', {'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [4 5 4 + 2*i], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
    Al70R_SOLerr_pf(i) = loadPoleFigure(fname,h(i),CS,SS,'interface','generic',...
      'ColumnNames', {'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [4 5 5 + 2 * i], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
end
