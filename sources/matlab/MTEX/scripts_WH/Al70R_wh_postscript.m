Al70R_delta_pfdc = regularizacion(Al70R_delta_pfd, 5, 98, 0);
Al70R_q_pfdc = regularizacion(Al70R_q_pfd, 5, 98, 0);
Al70R_Ch00_pfdc = regularizacion(Al70R_Ch00_pfd, 0, 100, 0);
Al70R_rho_pfdc = regularizacion(Al70R_rho_pfd, 5, 98, 0);
Al70R_D_pfdc = regularizacion(Al70R_D_pfd, 5, 98, 0);

Al70R_delta_pfdc = regular_pf(Al70R_delta_pfdc, 5, 5, 'nearest');
Al70R_q_pfdc = regular_pf(Al70R_q_pfdc, 5, 5, 'nearest');
Al70R_Ch00_pfdc = regular_pf(Al70R_Ch00_pfdc, 5, 5, 'nearest');
Al70R_rho_pfdc = regular_pf(Al70R_rho_pfdc, 5, 5, 'nearest');
Al70R_D_pfdc = regular_pf(Al70R_D_pfdc, 5, 5, 'nearest');


% figure(1);
% plot(pf, 'contourf');
% pf = regular_pf(pf, 5, 5, 'nearest');
% figure(2);
% plot(pf, 'contourf');