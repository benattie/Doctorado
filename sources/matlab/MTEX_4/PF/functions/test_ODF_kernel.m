function test_ODF_kernel(pf, varargin)

    %% Get options and set variables
    hw_range = get_option(varargin, 'HW_RANGE', [1 10]);
    kernel_name = get_option(varargin, 'kernel', 'vonMises');
    other_options = char(extract_option(varargin,'silent'));
    n_hw = hw_range(2) - hw_range(1) + 1;
    err = zeros(n_hw, pf.numPF);
    alpha = zeros(n_hw, pf.numPF);

    %% For the specified kernel, estimate the ODF for differents halfwidth
    if strcmp(kernel_name,'Abel')
       for hw = hw_range(1):hw_range(2)
            psi = AbelPoissonKernel('HALFWIDTH', hw*degree);
            indx = (hw - hw_range(1) + 1);
            [alpha(indx, :), err(indx, :)] = calc_and_plot_ODF(pf, psi, other_options);
       end
    elseif strcmp(kernel_name,'vonMises')
        for hw = hw_range(1):hw_range(2)
            psi = vonMisesFisherKernel('HALFWIDTH', hw*degree);
            indx = (hw - hw_range(1) + 1);
            [alpha(indx, :), err(indx, :)] = calc_and_plot_ODF(pf, psi, other_options);
        end
    elseif strcmp(kernel_name, 'bump')
        for hw = hw_range(1):hw_range(2)
            psi = bumpKernel('HALFWIDTH', hw*degree);
            indx = (hw - hw_range(1) + 1);
            [alpha(indx, :), err(indx, :)] = calc_and_plot_ODF(pf, psi, other_options);
        end
    else
        for hw = hw_range(1):hw_range(2)
            psi = deLaValeePoussinKernel('HALFWIDTH', hw*degree);
            indx = (hw - hw_range(1) + 1);
            [alpha(indx, :), err(indx, :)] = calc_and_plot_ODF(pf, psi, other_options);
        end
    end
    
    %% Plot scaling coefficients
    figure; plot(hw_range(1):hw_range(2), log(alpha), '-s')
    legend_text = [];
    for i=1:pf.numPF
        legend_text = [legend_text; num2str(pf.h(i).hkl)];
    end
    legend(legend_text);
    
    %% Plot errors
    data = cat(2, err, mean(err,2));
    figure; plot(hw_range(1):hw_range(2), data, '-o')
    tmp_string = 'avergage error';
    legend_text = [legend_text; tmp_string(1:length(num2str(pf.h(1).hkl)))];
    legend(legend_text);
end


function [alpha, err] = calc_and_plot_ODF(pf, psi, other_options)
    [odf, alpha] = calcODF(pf, 'kernel', psi, other_options);
%     figure; plotDiff(pf, odf);
%     figure; plotPDF(odf, pf.h, 'contourf', 'complete')
    err = calcError(pf, odf);
end