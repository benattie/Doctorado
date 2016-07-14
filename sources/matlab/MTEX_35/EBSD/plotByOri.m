function selected_grains = plotByOri(grains, ori, treshold)
    % select all grain with misorientation angle to ori less then 20 degree
    selected_grains = grains(angle(grains.meanOrientation, ori) < treshold);
    plot(grains_selected);

end