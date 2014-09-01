A70BS100_I_th8_importscript
A70BS100_I_th8_postscript
yrot = rotation('axis', yvector, 'angle', 90 * degree);
A70BS100_I_pfcn = normalize(A70BS100_I_th8_pfc);
A70BS100_I_pfcn_rot = rotate(A70BS100_I_pfcn, yrot);
figure(1);
%figura de polos original, normalizada
% plot(A70BS100_I_th8_pfcn);

%figura de polos rotada, normalizada
% figure(2);
plot(A70BS100_I_pfcn_rot);

%figura de polos, tomada de la odf hecha a partir de la original
% A70BS100_I_pfcn_odf = calcODF(A70BS100_I_pfcn, 'ITER_MAX', 100);
% % figure(3);
% plotpdf(A70BS100_I_pfcn_odf, h(1:2), 'COMPLETE');
colorbar;
% savefigure();
% 
% %figura de polos, tomada de la odf hecha a partir de la rotada
% A70BS100_I_pfc_rot_odf = calcODF(A70BS100_I_pfcn_rot);
% % figure(4);
% plotpdf(A70BS100_I_pfcn_rot_odf, h, 'COMPLETE');