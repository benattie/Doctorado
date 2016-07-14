function [size_pf, strain_pf] = makeLangford_poleFigure(Hg_pf, Hl_pf, lambda, theta)
   % [size_pf, strain_pf] = makeLangford_poleFigure(Hg_pf, Hl_pf, lambda, theta)
    if (Hg_pf.numPF ~= Hl_pf.numPF)
        m = min(Hg_pf.numPF, Hl_pf.numPF);
        wmsg = sprintf('Warning: PF sizes differ');
        display(wmsg);
    else
        m = Hg_pf.numPF;
    end
    
    if length(theta) ~= m
        wmsg = sprintf('Warning: The number of theta angles does not match the number of Pole Figures!');
        display(wmsg);
    end
    
    size_pf = Hg_pf;
    strain_pf = Hg_pf;
    for i=1:m
        %% Genero las GPF de tamaño y deformacion
        %% Get data
        Hg = Hg_pf.allI{i}; 
        Hl = Hl_pf.allI{i}; 
        
        %% Separar ancho gaussiano y lorentziano
        % Debye Scherrer formula
        size = (360 * lambda) ./ (pi ^ 2 .* Hl .* cos(theta(i)*degree));
        size_pf.allI{i} = size;
        % Deformacion acumulada
        strain = (pi / 1440) .* sqrt(pi / log(2)) .* (Hg ./ tan(theta(i)*degree));
        strain_pf.allI{i} = strain;
    end
end