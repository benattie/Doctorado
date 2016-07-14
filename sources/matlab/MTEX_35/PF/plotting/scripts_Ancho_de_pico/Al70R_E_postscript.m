%% Upper hemisphere
% figure(1);
% plot(Al70R_E_pfu);
% for i=1:7
%     aux = Al70R_E_pfu(i);
%     neg_values = get(aux, 'intensities') < 0.15;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') > 0.90;
%     aux = delete(aux, high_values);
%     Al70R_E_pfcu(i) = aux;
% end
Al70R_E_pfcu = regularizacion(Al70R_E_pfu, 5, 99.5, 1);
Al70R_E_pfcu = regular_pf(Al70R_E_pfcu, 5, 5, 'nearest');
% figure(2);
% plot(Al70R_E_pfcu);
%% Lower hemisphere
% figure(1);
% plot(Al70R_E_pfu);
% for i=1:7
%     aux = Al70R_E_pfd(i);
%     neg_values = get(aux, 'intensities') <= 0;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') > 1;
%     aux = delete(aux, high_values);
%     Al70R_E_pfcd(i) = aux;
% end
% Al70R_E_pfcu = regularizacion(Al70R_E_pfd, 5, 99.5, 1);
% Al70R_E_pfcu = regular_pf(Al70R_E_pfcd, 5, 5, 'nearest');
% figure(3);
% plot(Al70R_E_pfcd);