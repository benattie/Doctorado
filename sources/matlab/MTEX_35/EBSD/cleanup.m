function [grains, ebsd, grainId, mis2mean] = cleanup(ebsd, grainangle, grainssize)
    display('Reconstruccion de granos')
    [grains, ebsd.grainId] = calcGrains(ebsd, 'angle', grainangle);
    display('Eliminando granos pequeños')
    grainsToRemove = grains(grains.grainSize < grainssize);
    ebsd(grainsToRemove) = [];
    display('Recalculando granos')
    [grains, grainId, mis2mean] = calcGrains(ebsd, 'angle', grainangle);
end
