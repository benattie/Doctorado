Al70R_PHYSSOL_pfc = regularizacion(Al70R_PHYSSOL_pf, 1, 99, 0);
Al70R_PHYSSOL_pfc = regular_pf(Al70R_PHYSSOL_pfc, 5, 5, 'nearest');
% plot(Al70R_PHYSSOL_pfc, 'contourf')