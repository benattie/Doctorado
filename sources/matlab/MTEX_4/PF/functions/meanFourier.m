function power = meanFourier(odf,varargin)
% get the mean Fourier coefficients of the odf
%
% Syntax
%
%   meanFourier(odf)
%   meanFourier(odf,'bandwidth',32)
%
% Input
%  odf - @ODF
%
% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%
% See also
% ODF_calcFourier ODF_Fourier

L = get_option(varargin,'bandwidth',32);

if ~isFourier(odf), odf = FourierODF(odf,L); end

power = zeros(L+1,1);
LL = min(L,odf.bandwidth);
power(1:LL+1) = odf.components{1}.power(1:LL+1);

end