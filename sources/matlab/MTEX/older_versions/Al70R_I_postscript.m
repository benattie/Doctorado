%% Upper hemisphere
% for i=1:7
%     aux = Al70R_I_pfu(i);
%     neg_values = get(aux, 'intensities') < 0;
%     aux = delete(aux, neg_values);
%     high_values = get(aux, 'intensities') >= 10000;
%     aux = delete(aux, high_values);
%     Al70R_I_pfcu(i) = aux;
% end
% i = 1;
% aux = Al70R_I_pfu(i);
% neg_values = get(aux, 'intensities') < 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 300;
% aux = delete(aux, high_values);
% Al70R_I_pfcu(i) = aux;
% i = 2;
% aux = Al70R_I_pfu(i);
% neg_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 400;
% aux = delete(aux, high_values);
% Al70R_I_pfcu(i) = aux;
% i = 3;
% aux = Al70R_I_pfu(i);
% neg_values = get(aux, 'intensities') < 5;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') > 300;
% aux = delete(aux, high_values);
% Al70R_I_pfcu(i) = aux;
% i = 4;
% aux = Al70R_I_pfu(i);
% neg_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 150;
% aux = delete(aux, high_values);
% Al70R_I_pfcu(i) = aux;
% i = 5;
% aux = Al70R_I_pfu(i);
% neg_values = get(aux, 'intensities') < 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 35;
% aux = delete(aux, high_values);
% Al70R_I_pfcu(i) = aux;

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
% i = 1;
% aux = Al70R_I_pfd(i);
% neg_values = get(aux, 'intensities') < 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 300;
% aux = delete(aux, high_values);
% Al70R_I_pfcd(i) = aux;
% i = 2;
% aux = Al70R_I_pfd(i);
% neg_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 400;
% aux = delete(aux, high_values);
% Al70R_I_pfcd(i) = aux;
% i = 3;
% aux = Al70R_I_pfd(i);
% neg_values = get(aux, 'intensities') < 5;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') > 300;
% aux = delete(aux, high_values);
% Al70R_I_pfcd(i) = aux;
% i = 4;
% aux = Al70R_I_pfd(i);
% neg_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 150;
% aux = delete(aux, high_values);
% Al70R_I_pfcd(i) = aux;
% i = 5;
% aux = Al70R_I_pfd(i);
% neg_values = get(aux, 'intensities') < 0;
% aux = delete(aux, neg_values);
% high_values = get(aux, 'intensities') >= 35;
% aux = delete(aux, high_values);
% Al70R_I_pfcd(i) = aux;

% figure(1);
% plot(Al70R_I_pfcd);