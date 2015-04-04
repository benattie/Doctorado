%% Para ver el significado y derivacion de los simbolos utilizado ver (aca va el papel de Ungar)

%% Carpeta que va a guardar las figuras
figpath = sprintf('%s/figures', pname);
mkdir(figpath);
%% Grafico las PF
%% q
i = 1;
figure(1);
plot(Al70R_PHYSSOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_q_pf.pdf', figpath);
title('q Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i), 'contourf');
colorbar;
title('q Pole Figure (contours)')
fig = sprintf('%s/Al70R_q_pf_contourf.pdf', figpath);
savefigure(fig);
%% m
i = 2;
figure(1);
plot(Al70R_PHYSSOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_m_pf.pdf', figpath);
title('m Pole Figure (nm)')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i), 'contourf');
colorbar;
title('m Pole Figure (nm) (contours)')
fig = sprintf('%s/Al70R_m_pf_contourf.pdf', figpath);
savefigure(fig);
%% sigma
i = 3;
figure(1);
plot(Al70R_PHYSSOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_sigma_pf.pdf', figpath);
title('\sigma Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i), 'contourf');
colorbar;
title('\sigma Pole Figure (contours)')
fig = sprintf('%s/Al70R_sigma_pf_contourf.pdf', figpath);
savefigure(fig);
%% d
i = 4;
figure(1);
plot(Al70R_PHYSSOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_d_pf.pdf', figpath);
title('d Pole Figure (nm)')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i), 'contourf');
colorbar;
title('d Pole Figure (nm) (contours)')
fig = sprintf('%s/Al70R_d_pf_contourf.pdf', figpath);
savefigure(fig);
%% L0
i = 5;
figure(1);
plot(Al70R_PHYSSOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_L0_pf.pdf', figpath);
title('L0 Pole Figure (nm)')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i), 'contourf');
colorbar;
title('L0 Pole Figure (nm) (contours)')
fig = sprintf('%s/Al70R_L0_pf_contourf.pdf', figpath);
savefigure(fig);
%% rho
i = 6;
figure(1);
plot(Al70R_PHYSSOL_pfc(i)*1e4);
colorbar;
fig = sprintf('%s/Al70R_rho_1e4_pf.pdf', figpath);
title('\rho Pole Figure (10^{14} m^{-2})')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i)*1e4, 'contourf');
colorbar;
title('\rho Pole Figure (10^{14} m^{-2}) (contours)')
fig = sprintf('%s/Al70R_rho_1e4_pf_contourf.pdf', figpath);
savefigure(fig);
%% Re*
i = 7;
figure(1);
plot(Al70R_PHYSSOL_pfc(i)*100);
colorbar;
fig = sprintf('%s/Al70R_Re_100_pf.pdf', figpath);
title('Re* Pole Figure (x 100)')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i)*100, 'contourf');
colorbar;
title('Re* Pole Figure (x 100) (contours)')
fig = sprintf('%s/Al70R_Re_100_pf_contourf.pdf', figpath);
savefigure(fig);
%% M*
i = 8;
figure(1);
plot(Al70R_PHYSSOL_pfc(i)*100);
colorbar;
fig = sprintf('%s/Al70R_M_100_pf.pdf', figpath);
title('M* Pole Figure (x 100)')
savefigure(fig);
figure(2);
plot(Al70R_PHYSSOL_pfc(i)*100, 'contourf');
colorbar;
title('M* Pole Figure (x 100) (contours)')
fig = sprintf('%s/Al70R_M_100_pf_contourf.pdf', figpath);
savefigure(fig);