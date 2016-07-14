%size = debye_scherrer(lambda, Hl, theta)
function size = debye_scherrer(lambda, Hl, theta)
    size = (360 * lambda) ./ (pi ^ 2 .* Hl .* cos(theta * degree));
end