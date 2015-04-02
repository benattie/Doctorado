%% q
i = 1;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < -10;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% m
i = 2;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% sigma
i = 3;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% d
i = 4;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% L0
i = 5;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% rho
i = 6;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 1000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% Re*
i = 7;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

%% M*
i = 8;
aux = Al70R_PHYSSOL_pf(i);
low_values = get(aux, 'intensities') < 0;
aux = delete(aux, low_values);
high_values = get(aux, 'intensities') > 10000;
aux = delete(aux, high_values);
Al70R_PHYSSOL_pfc(i) = aux;

Al70R_PHYSSOL_pfc = regularizacion(Al70R_PHYSSOL_pf, 1, 99, 0);
Al70R_PHYSSOL_pfc = regular_pf(Al70R_PHYSSOL_pfc, 5, 5, 'nearest');
% plot(Al70R_PHYSSOL_pfc, 'contourf')