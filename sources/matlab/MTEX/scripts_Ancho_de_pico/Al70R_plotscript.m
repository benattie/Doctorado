%% Graficar la figura de polos de intensidad
% Upper hemisphere
Al70R_I_pfcnu = normalize(Al70R_I_pfcu);
figure(1);
plot(Al70R_I_pfcnu(1:3));
colorbar;
title('Intensity Pole Figure');
fname = sprintf('%s/Al70R_raw_up.pdf', pname);
savefigure(fname);
plot(Al70R_I_pfcnu(1:3), 'contourf');
colorbar;
title('Intensity Pole Figure (contours)');
fname = sprintf('%s/Al70R_rawcont_up.pdf', pname);
savefigure(fname);
% % Lower Hemisphere
% Al70R_I_pfnd = normalize(Al70R_I_pfd);
% Al70R_I_pfnd_rot = rotate(Al70R_I_pfnd, yrot);
% figure(2);
% plot(Al70R_I_pfnd_rot(1:3));
% colorbar;
% fname = sprintf('%s/Al70R_raw_down.pdf', pname);
% savefigure(fname);
% plot(Al70R_I_pfnd_rot(1:3), 'contourf');
% colorbar;
% fname = sprintf('%s/Al70R_rawcont_down.pdf', pname);
% savefigure(fname);
%% Calculo la ODF
% Upper hemisphere
Al70R_odfu = calcODF(Al70R_I_pfu(1:4));
figure(3);
plotpdf(Al70R_odfu, h(1:3), 'COMPLETE');
colorbar;
title('Intensity Pole Figure (recalculated)');
fname = sprintf('%s/Al70R_rec_up.pdf', pname);
savefigure(fname);

% % Lower hemisphere
% Al70R_odfd = calcODF(Al70R_I_pfnd_rot(1:4));
% figure(4);
% plotpdf(Al70R_odfd, h(1:3), 'COMPLETE');
% colorbar;
% fname = sprintf('%s/Al70R_rec_down.pdf', pname);
% savefigure(fname);
%% GPF de H
figure(5);
plot(Al70R_H_pfcu(1:3));
colorbar;
title('FWHM Pole Figure');
fname = sprintf('%s/Al70R_H_up.pdf', pname);
savefigure(fname);
plot(Al70R_H_pfcu(1:3), 'contourf');
colorbar;
title('FWHM Pole Figure (contours)');
fname = sprintf('%s/Al70R_Hcont_up.pdf', pname);
savefigure(fname);
% % Lower hemisphere
% figure(6);
% Al70R_H_pfcd_rot = rotate(Al70R_H_pfcd, yrot);
% plot(Al70R_H_pfcd_rot(1:3));
% colorbar;
% fname = sprintf('%s/Al70R_H_down.pdf', pname);
% savefigure(fname);
% plot(Al70R_H_pfcd_rot(1:3), 'contourf');
% colorbar;
% fname = sprintf('%s/Al70R_Hcont_down.pdf', pname);
% savefigure(fname);
%% GPF de eta
figure(7);
plot(Al70R_E_pfcu(1:3));
colorbar;
title('\eta Pole Figure');
fname = sprintf('%s/Al70R_E_up.pdf', pname);
savefigure(fname);
plot(Al70R_E_pfcu(1:3), 'contourf');
colorbar;
title('\eta Pole Figure (contours)');
fname = sprintf('%s/Al70R_Econt_up.pdf', pname);
savefigure(fname);
% % Lower hemisphere
% figure(8);
% Al70R_E_pfcd_rot = rotate(Al70R_E_pfcd, yrot);
% plot(Al70R_E_pfcd_rot(1:3));
% colorbar;
% fname = sprintf('%s/Al70R_E_down.pdf', pname);
% savefigure(fname);
% plot(Al70R_E_pfcd_rot(1:3), 'contourf');
% colorbar;
% fname = sprintf('%s/Al70R_Econt_down.pdf', pname);
% savefigure(fname);
