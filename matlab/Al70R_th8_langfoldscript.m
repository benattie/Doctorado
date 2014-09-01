%posicion de los picos de las figuras de polos
theta = [1.742 2.013 2.850 3.342 3.489 4.025 4.391];
%lambda en nm
lambda = 0.014235;
%trabajo con los datos sin corregir
[size_pf, strain_pf] = langfold_batch(Al70R_H_th8_pf, Al70R_E_th8_pf, lambda, theta, 7);
% %trabajo restando el ancho instrumental
% [size_pf_ins, strain_pf_ins] = langfold_batch(Al70R_cH_th8_pf, Al70R_cE_th8_pf, lambda, theta, 7);

%comandos de postprocesamiento
for i=1:7
    aux = size_pf(i);
    neg_values = get(aux, 'intensities') <= 0.2;
    aux = delete(aux, neg_values);
    high_values = get(aux, 'intensities') >= 100;
    aux = delete(aux, high_values);
    size_pf(i) = aux;
    
    aux = size_pf_ins(i);
    neg_values = get(aux, 'intensities') < 0;
    aux = delete(aux, neg_values);
    high_values = get(aux, 'intensities') >= 1000;
    aux = delete(aux, high_values);
    size_pf_ins(i) = aux;

    aux = strain_pf(i);
    neg_values = get(aux, 'intensities') < 0;
    aux = delete(aux, neg_values);
    complex_values = (imag(get(aux, 'intensities')) ~= 0);
    aux = delete(aux, complex_values);
    high_values = get(aux, 'intensities') >= 0.1;
    aux = delete(aux, high_values);
    strain_pf(i) = aux;
    
    aux = strain_pf_ins(i);
    neg_values = get(aux, 'intensities') < 0;
    aux = delete(aux, neg_values);
    high_values = get(aux, 'intensities') >= 0.1;
    aux = delete(aux, high_values);
    complex_values = (imag(get(aux, 'intensities')) ~= 0);
    aux = delete(aux, complex_values);
    strain_pf_ins(i) = aux;
end

%correccion fina
i = 1;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 150;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 2;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 90;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 3;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 90;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 4;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 60;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 5;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 60;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 6;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 60;
aux = delete(aux, high_values);
size_pf(i) = aux;
i = 7;
aux = size_pf(i);
high_values = get(aux, 'intensities') >= 90;
aux = delete(aux, high_values);
size_pf(i) = aux;



% i = 2;
% aux = strain_pf(i);
% high_values = get(aux, 'intensities') >= 70e-4;
% aux = delete(aux, high_values);
% strain_pf(i) = aux;
% 
% i = 5;
% aux = strain_pf_ins(i);
% high_values = get(aux, 'intensities') >= 100e-4;
% aux = delete(aux, high_values);
% strain_pf_ins(i) = aux;


%grafico las figuras de polos
%figuras de polos sin corregir por ancho instrumental
figure(1);
plot(size_pf);
figure(2);
plot(strain_pf);

% %figuras de polos con ancho instrumental restado
% figure(3);
% plot(size_pf_ins);
% figure(4);
% plot(1e4 .* strain_pf_ins);