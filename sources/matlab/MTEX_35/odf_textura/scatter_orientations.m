%% Srcipt de generación de figuras de polos, figuras de polos inversa y ODF discretas

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

% Obtengo las orientaciones
o = get(ebsd, 'orientations');
grains = calcGrains(ebsd);
%% Figura de polos discreta
% Indices de Miller
h  = [Miller(1,1,1) Miller(1,0,0) Miller(1,1,0)];

% Graficar y guardar la figura de polos
figure('position',[200 200 plot_w plot_h])
plotpdf(o, h);
figname = sprintf('%s/Scatter_pdf_F138_900C.pdf', pname);
% savefigure(figname);

% Grafica combinada con el IQ
figure('position',[200 200 plot_w plot_h])
plotpdf(ebsd, h,'antipodal','MarkerSize', 4, 'property','imagequality');
mtexColorMap black2white;
colorbar;
figname = sprintf('%s/Scatter_IQ_pdf_F138_900C.pdf', pname);
% savefigure(figname);
%% Figura de polos inversa discreta
% Direccion RD
figure('position',[200 200 plot_w plot_h])
plotipdf(o, xvector);
figname = sprintf('%s/Scatter_ipdf_RD_F138_900C.pdf', pname);
% savefigure(figname);

% Direccion TD
figure('position',[200 200 plot_w plot_h])
plotipdf(o, yvector);
figname = sprintf('%s/Scatter_ipdf_TD_F138_900C.pdf', pname);
% savefigure(figname);

% Direccion ND
figure('position',[200 200 plot_w plot_h])
plotipdf(o, zvector);
figname = sprintf('%s/Scatter_ipdf_ND_F138_900C.pdf', pname);
% savefigure(figname);
%% ODF discreta (convención de Bunge)
% Figura de phi1
figure('position',[200 200 plot_w plot_h])
plotodf(o, 'points', 5000, 'sections', 6, 'PHI1');
figname = sprintf('%s/Scatter_odf_PHI1_F138_900C.pdf', pname);
% savefigure(figname);

% Figura de phi2
figure('position',[200 200 plot_w plot_h])
plotodf(o, 'points', 5000, 'sections', 6, 'PHI2');
figname = sprintf('%s/Scatter_odf_PHI2_F138_900C.pdf', pname);
% savefigure(figname);