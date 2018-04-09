function testhw(pf, set_hw, varargin)
%% Runs calcODF for different halfwidths
% Always uses the vonMisesFisher Kernel
    for hw = set_hw
       msg = sprintf('Testing for hw=%d', hw);
       display(msg)
       psi = vonMisesFisherKernel('HALFWIDTH',hw*degree);
       if check_option(varargin,'noGhostCorrection'),
            calcODF(pf, 'kernel', psi, 'NOGHOSTCORRECTION');
       else
            calcODF(pf, 'kernel', psi);
       end
    end
end