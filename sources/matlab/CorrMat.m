function Rout = CorrMat(pf1, pf2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    [~, col1] = size(pf1);
    [~, col2] = size(pf2);
    Rout = zeros(col1, col2);
    for i=1:col1
        for j=i:col2
            int1 = get(pf1(i), 'intensities');
            int2 = get(pf2(j), 'intensities');
            Rtmp = corrcoef(int1, int2);
            Rout(i, j) = Rtmp(1, 2);
        end
    end
end

