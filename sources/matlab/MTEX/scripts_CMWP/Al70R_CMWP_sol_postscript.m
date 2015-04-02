%% a
i = 1;
aux = Al70R_SOL_pf(i);
neg_values = get(aux, 'intensities') <= -10;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 10;
aux = delete(aux, high_values);
Al70R_SOL_pfc(i) = aux;
%% b
i = 2;
aux = Al70R_SOL_pf(i);
neg_values = get(aux, 'intensities') <= 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 10;
aux = delete(aux, high_values);
Al70R_SOL_pfc(i) = aux;
%% c
i = 3;
aux = Al70R_SOL_pf(i);
neg_values = get(aux, 'intensities') < 0; % 0.1
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 10;
aux = delete(aux, high_values);
Al70R_SOL_pfc(i) = aux;
%% d
i = 4;
aux = Al70R_SOL_pf(i);
neg_values = get(aux, 'intensities') < 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 500;
aux = delete(aux, high_values);
Al70R_SOL_pfc(i) = aux;
%% e
i = 5;
aux = Al70R_SOL_pf(i);
neg_values = get(aux, 'intensities') <= 0;
aux = delete(aux, neg_values);
high_values = get(aux, 'intensities') > 500;
aux = delete(aux, high_values);
Al70R_SOL_pfc(i) = aux;

plot(Al70R_SOL_pfc);