%% Grafico las PF
%% Para ver el significado y derivacion de los simbolos utilizado ver (aca va el papel de Ungar)

%% Carpeta que va a guardar las figuras
sprintf(figpath, '%s/figures', pname);
mkdir figpath;
%% Soluciones del ajuste
%% a
i = 1;
figure(1);
plot(Al70R_SOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_a_pf.pdf', figpath);
title('a Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_SOL_pfc(i));
colorbar;
title('a Pole Figure (contours)')
fig = sprintf('%s/Al70R_a_pf_contourf.pdf', figpath);
savefigure(fig);
%% b
i = 2;
figure(1);
plot(Al70R_SOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_b_pf.pdf', figpath);
title('b Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_SOL_pfc(i));
colorbar;
title('b Pole Figure (contours)')
fig = sprintf('%s/Al70R_b_pf_contourf.pdf', figpath);
savefigure(fig);
%% c
i = 3;
figure(1);
plot(Al70R_SOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_c_pf.pdf', figpath);
title('c Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_SOL_pfc(i));
colorbar;
title('c Pole Figure (contours)')
fig = sprintf('%s/Al70R_c_pf_contourf.pdf', figpath);
savefigure(fig);
%% d
i = 4;
figure(1);
plot(Al70R_SOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_d_pf.pdf', figpath);
title('d Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_SOL_pfc(i));
colorbar;
title('d Pole Figure (contours)')
fig = sprintf('%s/Al70R_d_pf_contourf.pdf', figpath);
savefigure(fig);
%% e
i = 5;
figure(1);
plot(Al70R_SOL_pfc(i));
colorbar;
fig = sprintf('%s/Al70R_e_pf.pdf', figpath);
title('L0 Pole Figure')
savefigure(fig);
figure(2);
plot(Al70R_SOL_pfc(i));
colorbar;
title('e Pole Figure (contours)')
fig = sprintf('%s/Al70R_e_pf_contourf.pdf', figpath);
savefigure(fig);