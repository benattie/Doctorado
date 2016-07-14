function [pf_up, pf_down] = import_sync(varargin)
    %% Import Script for PoleFigure Data

    %
    % This script was automatically created by the import wizard. You should
    % run the whoole script or parts of it in order to import your data. There
    % is no problem in making any changes to this script.

    %% Specify Crystal and Specimen Symmetries

    % crystal symmetry
    CS = crystalSymmetry('m-3m', [4 4 4]);

    % specimen symmetry
    SS = specimenSymmetry('1');

    % plotting convention
    setMTEXpref('xAxisDirection','east');
    setMTEXpref('zAxisDirection','outOfPlane');

    %% Specify File Names

    % path to files
    pname = '/home/benattie/Documents/Doctorado/XR/Sync/2013/AlSR70/out';

    % which files to be imported
    fname = {...
      [pname '/New_Al-R7-tex_PF_1.mtex'],...
      [pname '/New_Al-R7-tex_PF_2.mtex'],...
      [pname '/New_Al-R7-tex_PF_3.mtex'],...
      };


    %% Specify Miller Indice

    h = { ...
      Miller(1,1,1,CS),...
      Miller(2,0,0,CS),...
      Miller(2,2,0,CS),...
      };

    %% Import the Data
    pf_var = 'INT';
    pf_var = get_option(varargin,'variable',pf_var);
    % create a Pole Figure variable containing the data
    [pf_up, pf_down] = create_pf_from_sync(fname, pf_var, h, SS);
end