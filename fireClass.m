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
    end
    methods
        % Class constructor. 
        function obj = fireClass( ...
                gridSize, ...
                newFireIntensityMean, ...
                newFireIntensityStandardDeviation)
            
            % Initializations. 
            obj.gridSize = gridSize; 
            obj.intensity = zeros(obj.gridSize); 
            obj.newFireIntensityMean = newFireIntensityMean; 
            obj.newFireIntensityStandardDeviation = ...
                newFireIntensityStandardDeviation; 
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
            stochasticNewFireIntensities = normrnd( ...
                obj.newFireIntensityMean, ...
                obj.newFireIntensityStandardDeviation, ...
                obj.gridSize(1), obj.gridSize(2)); 

            % Generate new fires. 
            obj.intensity(newFireOccurrence) = ...
                stochasticNewFireIntensities(newFireOccurrence); 
        end
    end
end
