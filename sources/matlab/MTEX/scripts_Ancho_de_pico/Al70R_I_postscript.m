%% Upper hemisphere
% for i=1:7
%     aux = Al70R_I_pfu(i);
%     neg_values = get(aux, 'intensities') < 0;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') >= 10000;
%     aux = delete(aux, high_values);
%     Al70R_I_pfcu(i) = aux;
% end

Al70R_I_pfcu = regularizacion(Al70R_I_pfu, 0, 99, 1);
Al70R_I_pfcu(2) = regularizacion(Al70R_I_pfu(2), 1, 93, 1);
Al70R_I_pfcu(6) = regularizacion(Al70R_I_pfu(6), 1, 93, 1);
Al70R_I_pfcu = regular_pf(Al70R_I_pfcu, 5, 5, 'nearest');
% figure(1);
% plot(Al70R_I_pfcu);

%% Lower hemisphere
% for i=1:7
%     aux = Al70R_I_pfd(i);
%     neg_values = get(aux, 'intensities') < 0;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') >= 10000;
%     aux = delete(aux, high_values);
%     Al70R_I_pfcd(i) = aux;
% end
% Al70R_I_pfcd = regularizacion(Al70R_I_pfd, 0, 99, 1);
% Al70R_I_pfcd(2) = regularizacion(Al70R_I_pfd(2), 1, 93, 1);
% Al70R_I_pfcd(6) = regularizacion(Al70R_I_pfd(6), 1, 93, 1);
% Al70R_I_pfcd = regular_pf(Al70R_I_pfcd, 5, 5, 'nearest');
%  figure(1);
% plot(Al70R_I_pfcd);