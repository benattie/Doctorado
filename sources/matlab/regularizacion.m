% rpf = regularizacion(pf, low_boundary, high_boundary, neg2max)

function rpf = regularizacion(pf, low_boundary, high_boundary, neg2max)
    [~, icol] = size(pf);
    for i=1:icol
        int = get(pf(i), 'intensities');
        q1 = prctile(int, low_boundary);
        q4 = prctile(int, high_boundary);
        if neg2max == 1
            int(int < 0) = max(int);
        end
        int(int < q1) = q1;
        int(int > q4) = q4;
        rpf(i) = set(pf(i), 'intensities', int);
    end
end
