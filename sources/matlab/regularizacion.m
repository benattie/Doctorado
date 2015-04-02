% rpf = regularizacion(pf, p1, p2, neg2max)

function rpf = regularizacion(pf, p1, p2, neg2max)
    [~, icol] = size(pf);
    for i=1:icol
        int = get(pf(i), 'intensities');
        q1 = prctile(int, p1);
        q4 = prctile(int, p2);
        if neg2max == 1
            int(int < 0) = max(int);
        end
        int(int < q1) = q1;
        int(int > q4) = q4;
        rpf(i) = set(pf(i), 'intensities', int);
    end
end
