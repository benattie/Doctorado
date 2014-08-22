%B = beta(H, eta)
function B = beta(H, eta)
    B = (pi * H * 0.5) / (eta + (1 - eta) * sqrt(pi * log(2)));
end