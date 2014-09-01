Al70R_H_th8_importscript
Al70R_H_th8_postscript
yrot = rotation('axis', yvector, 'angle', 90 * degree);
Al70R_H_pfc_rot = rotate(Al70R_H_th8_pfc, yrot);
Al70R_H_rpfc_rot = smooth_pf(Al70R_H_pfc_rot, 1, 7);
figure(1);
% plot(Al70R_H_th8_pfc(1:4));
% plot(Al70R_H_pfc_rot(1:4));
% plot(Al70R_H_rpfcn_rot(1:4));
plot(Al70R_H_rpfc_rot(1:4), 'contourf');
% setcolorrange([0.016 0.031]);
colorbar;
% savefigure();