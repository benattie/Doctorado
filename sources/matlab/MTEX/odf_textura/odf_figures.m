%% Srcipt de generación de figuras de polos, figuras de polos inversa y ODF continuas

%***********************************************************************
%% Fix the map aspect ratio and dimensions
%***********************************************************************
ratio = (max(get(ebsd,'x')) - min(get(ebsd,'x')))...
       /(max(get(ebsd,'y')) - min(get(ebsd,'y')));
% plot height (you can change this value)
% I normally use for plot_h = 600
% But for teaching larger plots with plot_h = 1200 is useful
plot_h = 600;
% plot width with correct aspect ratio
plot_w = round(plot_h*ratio);
%***********************************************************************
%% Calculo la ODF
%***********************************************************************
% grains reconstruction
grains = calcGrains(ebsd);

% correct for to small grains
grains = grains(grainSize(grains) > 5);

% compute optimal halfwidth from grains
psi = calcKernel(grains);

% compute the ODF with the kernel psi
odf = calcODF(ebsd,'kernel',psi);

% odf = calcODF(ebsd);
%***********************************************************************
%% Figura de polos
%***********************************************************************
% Indices de Miller
h  = [Miller(1,1,1) Miller(1,0,0) Miller(1,1,0)];

% Graficar y guardar la figura de polos
figure('position',[200 200 plot_w plot_h])
plotpdf(odf, h);
figname = sprintf('%s/pdf_F138_900C.pdf', pname);
% savefigure(figname);
%***********************************************************************
%% Figura de polos inversa
%***********************************************************************
% Direccion RD
figure('position',[200 200 plot_w plot_h])
plotipdf(odf, xvector);
figname = sprintf('%s/ipdf_RD_F138_900C.pdf', pname);
% savefigure(figname);

% Direccion TD
figure('position',[200 200 plot_w plot_h])
plotipdf(odf, yvector);
figname = sprintf('%s/ipdf_TD_F138_900C.pdf', pname);
% savefigure(figname);

% Direccion ND
figure('position',[200 200 plot_w plot_h])
plotipdf(odf, zvector);
figname = sprintf('%s/ipdf_ND_F138_900C.pdf', pname);
% savefigure(figname);
%***********************************************************************
%% ODF(convención de Bunge)
%***********************************************************************
figure('position',[200 200 plot_w plot_h])
plotodf(odf, 'sections', 6, 'PHI1');
figname = sprintf('%s/Scatter_odf_PHI1_F138_900C.pdf', pname);
% savefigure(figname);

figure('position',[200 200 plot_w plot_h])
plotodf(odf, 'sections', 6, 'PHI2');
figname = sprintf('%s/Scatter_odf_PHI2_F138_900C.pdf', pname);
% savefigure(figname);