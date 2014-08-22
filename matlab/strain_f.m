%strain = strain_f(Hg, theta)
function strain = strain_f(Hg, theta)
    radian = pi / 180.;
    strain = (pi / 1440) .* sqrt(pi / log(2)) .* (Hg ./ tan(theta * radian));
end