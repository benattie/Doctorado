%% Grafico las PF
%% delta
figure(1);
plot(Al70R_delta_pfdc ./ [0.491 0.491 0.491 0.491]);
colorbar;
fig = sprintf('%s/Al70R_delta_pf.pdf', figpath);
title('\delta Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_delta_pfdc ./ [0.491 0.491 0.491 0.491], 'contourf');
colorbar;
title('\delta Pole Figure (contours)')
fig = sprintf('%s/Al70R_delta_pf_contourf.pdf', figpath);
savefigure(fig);
%% q
figure(1);
plot(Al70R_q_pfdc);
colorbar;
fig = sprintf('%s/Al70R_q_pf.pdf', figpath);
title('q Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_q_pfdc, 'contourf');
colorbar;
title('q Pole Figure (contours)')
fig = sprintf('%s/Al70R_q_pf_contourf.pdf', figpath);
savefigure(fig);
%% Ch00
figure(1);
plot(Al70R_Ch00_pfdc);
colorbar;
fig = sprintf('%s/Al70R_Ch00_pf.pdf', figpath);
title('Ch00 Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_Ch00_pfdc, 'contourf');
colorbar;
title('Ch00 Pole Figure (contours)')
fig = sprintf('%s/Al70R_Ch00_pf_contourf.pdf', figpath);
savefigure(fig);
%% M^4rho
figure(1);
plot(Al70R_rho_pfdc*1e4);
colorbar;
fig = sprintf('%s/Al70R_M4rho_pf.pdf', figpath);
title('M^4\rho Pole Figure (10^{14} m^2)')
savefigure(fig);
figure(2);
plot(Al70R_rho_pfdc*1e4, 'contourf');
colorbar;
title('M^4\rho Pole Figure (10^{14} m^2) (contours)')
fig = sprintf('%s/Al70R_M4rho_pf_contourf.pdf', figpath);
savefigure(fig);
%% D
figure(1);
plot(Al70R_D_pfdc);
colorbar;
fig = sprintf('%s/Al70R_D_pf.pdf', figpath);
title('D Pole Figure (nm)')
savefigure(fig);
figure(2);
plot(Al70R_D_pfdc, 'contourf');
colorbar;
title('D Pole Figure (nm) (contours)')
fig = sprintf('%s/Al70R_D_pf_contourf.pdf', figpath);
savefigure(fig);