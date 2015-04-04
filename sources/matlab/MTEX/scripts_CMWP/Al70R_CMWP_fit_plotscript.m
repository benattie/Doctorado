%% Grafico las PF de calidad de los ajustes
%% Carpeta que va a guardar las figuras
figpath = sprintf('%s/figures', pname);
mkdir(figpath);
%% Parametros de calidad del ajuste
%% WSSR
i = 1;
figure(1);
plot(Al70R_FIT_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_WSSR_pf.pdf', figpath);
title('WSSR Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_FIT_pfc(i), 'contourf');
colorbar;
title('WSSR Pole Figure (contours)')
fig = sprintf('%s/Al70R_WSSR_pf_contourf.pdf', figpath);
savefigure(fig);
%% rms = WSSR/NDF
i = 2;
figure(1);
plot(Al70R_FIT_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_rms_pf.pdf', figpath);
title('rms Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_FIT_pfc(i), 'contourf');
colorbar;
title('rms Pole Figure (contours)')
fig = sprintf('%s/Al70R_rms_pf_contourf.pdf', figpath);
savefigure(fig);
%% red_chi_sq = sqrt(WSSR/ndf)
i = 3;
figure(1);
plot(Al70R_FIT_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_chisq_pf.pdf', figpath);
title('\chi^2 Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_FIT_pfc(i), 'contourf');
colorbar;
title('\chi^2 Pole Figure (contours)')
fig = sprintf('%s/Al70R_chisq_pf_contourf.pdf', figpath);
savefigure(fig);