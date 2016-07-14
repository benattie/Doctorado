%% Limpiar el espacio de trabajo
clear all;
%% Importar los datos
Al70R_wh_importscript;

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

% %% delta
% aux = Al70R_delta_pfd;
% low_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, low_values);
% high_values = get(aux, 'intensities') > 0.1;
% aux = delete(aux, high_values);
% Al70R_delta_pfdc = aux;
% % figure(1);
% % plot(Al70R_delta_pfdc);
% 
% %% q
% aux = Al70R_q_pfd;
% low_values = get(aux, 'intensities') < -1;
% aux = delete(aux, low_values);
% high_values = get(aux, 'intensities') > 1.5;
% aux = delete(aux, high_values);
% Al70R_q_pfdc = aux;
% % figure(2);
% % plot(Al70R_q_pfdc, 'contourf');
%  
% %% Ch00
% aux = Al70R_Ch00_pfd;
% low_values = get(aux, 'intensities') <= 0;
% aux = delete(aux, low_values);
% high_values = get(aux, 'intensities') > 3;
% aux = delete(aux, high_values);
% Al70R_Ch00_pfdc = aux;
% % figure(3);
% % plot(Al70R_Ch00_pfdc);
% 
% %% Rho
% aux = Al70R_rho_pfd;
% low_values = get(aux, 'intensities') <= 1e-6;
% aux = delete(aux, low_values);
% high_values = get(aux, 'intensities') >= 1e-4;
% aux = delete(aux, high_values);
% Al70R_rho_pfcd = aux; %resultado en nm^-2
% % figure(4);
% % plot(Al70R_rho_pfcd*1e4, 'smooth');
% 
% %% D
% aux = Al70R_D_pfd;
% low_values = get(aux, 'intensities') < 0;
% aux = delete(aux, low_values);
% high_values = get(aux, 'intensities') > 20000;
% aux = delete(aux, high_values);
% Al70R_D_pfcd = aux;
% % figure(5);
% % plot(Al70R_D_pfcd);