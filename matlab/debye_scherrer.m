%size = debye_scherrer(lambda, Hl, theta)
function size = debye_scherrer(lambda, Hl, theta)
    radian = pi / 180.;
    size = (360 * lambda) ./ (pi ^ 2 .* Hl .* cos(theta * radian));
end