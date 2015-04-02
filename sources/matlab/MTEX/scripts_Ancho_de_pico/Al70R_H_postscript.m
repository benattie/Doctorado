%% Upper hemisphere
% figure(1);
% plot(Al70R_H_pfu);
% for i=1:7
%     aux = Al70R_H_pfu(i);
%     neg_values = get(aux, 'intensities') < 0.00;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') > 0.04;
%     aux = delete(aux, high_values);
%     Al70R_H_pfcu(i) = aux;
% end
Al70R_H_pfcu = regularizacion(Al70R_H_pfu, 0, 99, 1);
Al70R_H_pfcu = regular_pf(Al70R_H_pfcu, 5, 5, 'nearest');
% figure(2);
% plot(Al70R_H_pfcu);
%% Lower hemisphere
% figure(1);
% plot(Al70R_H_pfu);
% for i=1:7
%     aux = Al70R_H_pfd(i);
%     neg_values = get(aux, 'intensities') <= 0.010;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') > 0.023;
%     aux = delete(aux, high_values);
%     Al70R_H_pfcd(i) = aux;
% end
% Al70R_H_pfcu = regularizacion(Al70R_H_pfd, 0, 99, 1);
% Al70R_H_pfcu = regular_pf(Al70R_H_pfcd, 5, 5, 'nearest');
% figure(2);
% plot(Al70R_H_pfcd);
