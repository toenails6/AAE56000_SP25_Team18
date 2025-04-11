% Class that contains the information of all fires across the grid. 
% Intensity can be a negative number, leaving a small margin to zero. 
% Fires exist after intensity goes above zero. 
% Fires are considered put out, or risk controlled, if intensity is below
% an arbitrary negative value. 
% Intensity grows stochastically based on risk factor of the grid block. 
% Fires can spread based on intensity and neighbouring risk factors, which
% means local intensity grows after neighbouring intensity reaches beyond a
% certain threshold based on local risk factor. 
classdef fireClass < handle
    properties
        gridSize; 
        intensity; 
        newFireIntensityMean; 
        newFireIntensityStandardDeviation; 
        peakIntensityHealth_mean; 
        peakIntensityHealth_standardDeviation; 
        peakIntensityHealth; 
    end
    methods
        % Class constructor. 
        function obj = fireClass(gridSettings)
            % Restrict input type for coding convenience. 
            arguments
                gridSettings gridSettingsClass; 
            end

            % Initializations. 
            obj.gridSize = gridSettings.gridSize; 
            obj.intensity = zeros(obj.gridSize); 
            obj.newFireIntensityMean = gridSettings.newFireIntensityMean; 

            obj.newFireIntensityStandardDeviation = ...
                gridSettings.newFireIntensityStandardDeviation; 

            obj.peakIntensityHealth_mean = ...
                gridSettings.peakIntensityHealth_mean; 
            
            obj.peakIntensityHealth_standardDeviation = ...
                gridSettings.peakIntensityHealth_standardDeviation; 

            % Generate health at which fire intensity growth rate peaks for
            % the grid. 
            rng(117); 
            obj.peakIntensityHealth = min(max(normrnd( ...
                obj.peakIntensityHealth_mean, ...
                obj.peakIntensityHealth_standardDeviation, ...
                obj.gridSize), 0.5), 0.7); 
            rng("default"); 
        end

        % New fire generation method. 
        function obj = generateFires(obj, riskFactor)
            % Generate new fires based on stochastic risk factor. 
            % Also check whether a fire already exists. 
            
            % Grid locations to generate new fires, based on risk factor
            % probability, and whether a fire already exists. 
            newFireOccurrence = ...
                ( ...
                rand(obj.gridSize(1), obj.gridSize(2)) < ...
                riskFactor) & ...
                (~obj.intensity); 

            % Stochastically generated intensities of new fires. 
            stochasticNewFireIntensities = min(max(normrnd( ...
                obj.newFireIntensityMean, ...
                obj.newFireIntensityStandardDeviation, ...
                obj.gridSize(1), obj.gridSize(2)), 0),1E-1); 

            % Generate new fires. 
            obj.intensity(newFireOccurrence) = ...
                stochasticNewFireIntensities(newFireOccurrence); 
        end

        % Update intensity method. 
        function obj = updateIntensity(obj, gridHandle)
            % Discrete time state space. 
            x = [obj.intensity; gridHandle.gridHealth]; 
            % x = [ ...
            %     1+] * x; 
        end
    end
end
