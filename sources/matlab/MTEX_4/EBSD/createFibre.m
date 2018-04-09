function fibre = createFibre(odf, varargin)
% get orientations along a fibre
%
% Syntax
%  createFibre(odf,h,r);
%
% Input
%  odf - @ODF
%  h   - @Miller crystal directions
%  r   - @vector3d specimen direction
%
% Options
%  CENTER     - for radially symmetric plot
%  points     - the number of orientations along the fiber (10 by default)
%
% Example
%   createFibre(SantaFe,Miller(1,1.2,1.6),vector3d(1.1,1.5,1.3))
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

%
    if isa(varargin{1},'vector3d')
      varargin{1} = odf.CS.ensureCS(varargin{1});
      npoints = get_option(varargin, 'points', 10);
      omega = linspace(-pi,pi,npoints);
      center = get_option(varargin,'CENTER',hr2quat(varargin{1},varargin{2}),{'quaternion','rotation','orientation'});
      fibre = axis2quat(varargin{2},omega) .* center;
    elseif isa(varargin{1},'quaternion')
      fibre = varargin{1};
    end

    %
    fibre = orientation(fibre,odf.CS,odf.SS);
end