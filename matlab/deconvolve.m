%[Hg, Hl] = deconvolve(H, eta)
function [Hg, Hl] = deconvolve(H, eta)
    Hl = H .* (0.72928 .* eta + 0.19289 .* eta .^ 2 + 0.07783 .* eta .^ 3);
    Hg = H .* sqrt(1 - 0.74417 .* eta - 0.24781 .* eta .^ 2 - 0.00810 .* eta .^ 3);
end