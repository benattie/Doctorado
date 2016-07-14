function [data_up, data_down] = separate_spheres(data_M)

    condition = data_M(:, 5) <= 90.0;
    data_up = data_M(condition, :);
    condition = data_M(:, 5) >= 90.0;
    data_down = data_M(condition, :);
    data_down(:, 5) = 180. - data_down(:, 5);
    data_down(:, 6) = 360. - data_down(:, 6);

end