%% WSSR
i = 1;
aux = Al70R_FIT_pf(i);
neg_values = get(aux, 'intensities') < 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 8000;
aux = delete(aux, high_values);
Al70R_FIT_pfc(i) = aux;
%% rms = WSSR/NDF
i = 2;
aux = Al70R_FIT_pf(i);
neg_values = get(aux, 'intensities') < 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 1e4;
aux = delete(aux, high_values);
Al70R_FIT_pfc(i) = aux;
%% red_chi_sq = sqrt(WSSR/ndf)
i = 3;
aux = Al70R_FIT_pf(i);
neg_values = get(aux, 'intensities') < 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 1e4;
aux = delete(aux, high_values);
Al70R_FIT_pfc(i) = aux;

%% Grafico los datos
plot(Al70R_FIT_pfc);