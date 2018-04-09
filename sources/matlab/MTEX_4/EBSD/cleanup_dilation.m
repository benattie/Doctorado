function [grains, ebsd, grainId, mis2mean] = cleanup_dilation(ebsd, varargin)
    display('Reconstruccion de granos')
    grainangle = get_option(varargin, 'treshold', 5*degree);
    [grains, ebsd.grainId] = calcGrains(ebsd, 'angle', grainangle);
    display('Eliminando granos pequeños')
    grainssize = get_option(varargin, 'grainSize', 5);
    grainsToRemove = grains(grains.grainSize < grainssize);
    ebsd(grainsToRemove).phase = -1;
    ebsd = ebsd('indexed');
    display('Recalculando granos')
    [grains, grainId, mis2mean] = calcGrains(ebsd, 'angle', grainangle);
end