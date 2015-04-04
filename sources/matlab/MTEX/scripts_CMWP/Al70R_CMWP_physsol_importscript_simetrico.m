% function PF_simetrica(fname, CS, SS, h, )

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
pname = '/home/benattie/Documents/Doctorado/XR/Sync/Al70R/cmwp/semilla_inicial/dif_completo/cmwp_idea_pole_figures';

% % which files to be imported
% fname = {...
%   [pname '/New_Al70R-tex_CMWP_PHYSSOL_PF.mtex'],...
%   };

% which files to be imported
fname = {...
  [pname '/New_Al70R-tex_CMWP_PHYSSOL_PF.mtex'],...
  };

%% Preprocess the data (separate upper hemisphere from lower hemisphere)
[nrow,ncol] = size(fname);
for i=1:ncol
    fp = fopen(char(fname(i)), 'r');
    tline = fgets(fp);
    header = textscan(fp, '%s', 14, 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    data = textscan(fp, '%d %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ' ', 'MultipleDelimsAsOne', 1);
    matdata = cell2mat(data(2:end));
    fclose(fp);
    
    mat = matdata(:,3:end);
    sort_mat = sortrows(mat, [2 1]);
    idx = ( sort_mat(:,2) > 90 & sort_mat(:,2) < 270 );
    red_mat = sort_mat(idx,:); % mitad izquierda
    right_mat = red_mat;
    right_mat(:,2) = 180 - right_mat(:,2);
    mat = [red_mat;right_mat];
    fout{i} = sprintf('%s/Al70R_simetrico.dat', pname);
    dlmwrite(fout{i}, mat, 'Delimiter', '\t');
end

%% Import the Data
% create a Pole Figure variable containing the data
for i = 1:8
    h(i) = Miller(i,i,i,CS);
    Al70R_PHYSSOL_pf(i) = loadPoleFigure(fout,h(i),CS,SS,'interface','generic',...
      'ColumnNames', { 'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 2 + i], 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard', 'wizard');
end
% plot(Al70R_PHYSSOL_pf, 'contourf')