%grilla regula 5x5 con simetria azimutal
S2G = S2Grid('regular','points',[1 19], 'upper');
figure(1);
pf = PoleFigure(Miller(1,1,1,CS), S2G, [1:19], CS, SS);
plot(pf);

%grilla regular sin simetria
S2G_2 = S2Grid('regular', 'upper');
I = 1;
I = repmat(1, 1, 72*19);
figure(2);
pf_2 = PoleFigure(Miller(1,1,1,CS), S2G_2, I', CS, SS);
plot(pf_2);

figure(3);
pfc = correct(pf_2, 'defocussing', pf); %defocussing divide a cada elemento de pf_2 por cada elemento de pf
plot(pfc);

pfcb = correct(pf_2, 'background', pf); %background resta a cada elemento de pf_2 cada elemento de pf
plot(pfcb);


