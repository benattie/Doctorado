clear all
close all

import_sync
I = pf_up.allI{1};
x = pf_up.allR{1}.x;
y = pf_up.allR{1}.y;
z = pf_up.allR{1}.z;
F = scatteredInterpolant(x, y, z,I, 'natural', 'linear')

alpha = 0:5:85;
beta = 0:1:359;
r = regularS2Grid('points',[numel(alpha) numel(beta)]);
xq = r.x;
yq = r.y;
zq = r.z;
xq = reshape(xq, numel(xq), 1);
yq = reshape(yq, numel(yq), 1);
zq = reshape(zq, numel(zq), 1);
Iq = F(xq(:),yq(:),zq(:));
rpf = PoleFigure(pf_up.allH{1}, r, Iq);
plot(rpf)