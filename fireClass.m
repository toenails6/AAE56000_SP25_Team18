% Class that simulates fires across the grid. 
% Fire intensities are constrained to minimum of 0 and maximum of 1. 
% Fire intensity of 0 means no active presence of fires. 
% A fire intensity of 1 effectively instantly depletes the health of the
% grid block. 
% Intensity grows stochastically based on risk factor of the grid block. 
% Fires can spread based on intensity and neighbouring risk factors, which
% means local intensity grows after neighbouring intensity reaches beyond a
% certain threshold based on local risk factor. 
classdef fireClass < handle
    properties
        intensity; 
        peakIntensityHealth; 
        gridHandle gridClass; 
    end
    methods
        % Class constructor. 
        function obj = fireClass(gridHandle)
            % Restrict input type for coding convenience. 
            arguments
                gridHandle gridClass; 
            end

            % Record the handle to the parent class, the simulation grid. 
            obj.gridHandle = gridHandle; 

            % Initialize fire intensities matrix. 
            obj.intensity = zeros(gridHandle.gridSize); 

            % Generate health at which fire intensity growth rate peaks for
            % the grid. 
            rng(117); 
            obj.peakIntensityHealth = min(max(normrnd( ...
                gridHandle.peakIntensityHealth_mean, ...
                gridHandle.peakIntensityHealth_standardDeviation, ...
                gridHandle.gridSize), ...
                obj.gridHandle.peakIntensityHealthMin), ...
                obj.gridHandle.peakIntensityHealthMax); 
            rng("default"); 
        end

        % New fire generation method. 
        function obj = generateFires(obj)
            % Generate new fires based on stochastic risk factor. 
            % Also check whether a fire already exists. 
            
            % Grid locations to generate new fires, based on risk factor
            % probability, and whether a fire already exists. 
            newFireOccurrence = ...
                ( ...
                rand(obj.gridHandle.gridSize) < ...
                obj.gridHandle.riskFactor) & ...
                (~obj.intensity); 

            % Stochastically generated intensities of new fires. 
            stochasticNewFireIntensities = min(max(normrnd( ...
                obj.gridHandle.newFireIntensityMean, ...
                obj.gridHandle.newFireIntensityStandardDeviation, ...
                obj.gridHandle.gridSize), ...
                0), obj.gridHandle.newFireIntensityMax); 

            % Generate new fires. 
            obj.intensity(newFireOccurrence) = ...
                stochasticNewFireIntensities(newFireOccurrence); 
        end

        % Update intensity method. 
        function obj = updateIntensity(obj)
            % Discrete time state space. 
            c = obj.gridHandle.fireIntensityScaler; 
            R = obj.gridHandle.riskFactor; 
            I = obj.intensity; 
            H = obj.gridHandle.gridHealth; 
            mu = obj.peakIntensityHealth; 
            
            intensityUpdate = 1 + ...
                c*R.*(-(mu.^2-2*mu+1).^-1.*(H.^2-2*mu.*H+2*mu-1)); 
            I = intensityUpdate.*I; 
            H = -I+H; 

            % Update intensity and health. 
            obj.intensity = min(max(I, 0), 1); 
            obj.gridHandle.gridHealth = min(max(H, 0), 1); 
        end
    end
end



