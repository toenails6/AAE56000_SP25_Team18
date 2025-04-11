% This class contains information on the grid blocks, such as risk factor
% of getting fires due to geological conditions, etc. 
% There would be an initial risk factor generated from a seeded RNG. 
% The risk factor would then oscillate periodically through a sine function
% to mimic seasonal influence. 
% There will be a seeded RNG generated amplitude for each grid block. 
% There can be also be manual tuning of these parameters. 
classdef gridClass < gridSettingsClass
    properties
        riskFactor; 
        riskFactor_0; 
        riskFactorAmplitudes; 
        fires fireClass; 
        gridHealth; 
    end
    methods
        % Class constructor. 
        function obj = gridClass(gridSettings)
            % Restrict input type for coding convenience. 
            arguments
                gridSettings gridSettingsClass; 
            end

            % Initialize grid and sim properties. 
            obj.gridSize = gridSettings.gridSize; 
            obj.ticksPerYear = gridSettings.ticksPerYear; 
            obj.restoreGridHealthRate = ...
                gridSettings.restoreGridHealthRate; 
            obj.restoreGridHealthCost = ...
                gridSettings.restoreGridHealthCost; 

            % Initialize grid health. 
            obj.gridHealth = ones(obj.gridSize(1), obj.gridSize(2)); 

            % Generate initial risk factor matrix via seeded gaussian RNG. 
            % Risk factor ranges from minimum of 0 to maximum of 1. 
            obj.riskFactor_0 = zeros(obj.gridSize(1), obj.gridSize(2)); 
            rng(117); 
            obj.riskFactor_0 = min(max( ...
                normrnd(-0.5, 0.4, obj.gridSize(1), obj.gridSize(2)), ...
                0), 1); 
            rng("default"); 

            % Generate risk factor oscillation amplitudes. 
            obj.riskFactorAmplitudes = zeros( ...
                obj.gridSize(1), obj.gridSize(2)); 
            rng(54); 
            obj.riskFactorAmplitudes = min(max( ...
                normrnd(0.2, 0.1, obj.gridSize(1), obj.gridSize(2)), ...
                0), 1); 
            rng("default"); 

            % Instantiate fire class. 
            obj.fires = fireClass( ...
                obj.gridSize, ...
                obj.newFireIntensityMean, ...
                obj.newFireIntensityStandardDeviation); 
        end

        % Update risk factor, simulating periodic seasonal changes. 
        % Limit risk factors to minimum of 0 to maximum of 1. 
        function obj  = updateRiskFactor(obj, tick)
            obj.riskFactor = obj.riskFactor_0 + ...
                obj.riskFactorAmplitudes*sin(tick * ...
                2*pi/obj.ticksPerYear); 
            obj.riskFactor = min(max(obj.riskFactor, 0), 1); 
        end

        % Restore grid block health. 
        function obj = restoreGridHealth(obj)
            % Check the grid for existence of fires. 
            noFireGrids = ~obj.fires.intensity; 

            % Calculate amount of health to restore. 
            % Considers grid blocks close to full health. 
            restoreAmount = ...
                min(1 - obj.gridHealth, obj.restoreGridHealthRate); 
            restoreAmount(~noFireGrids) = 0; 
            
            % Restore grid blocks without fire. 
            obj.gridHealth = obj.gridHealth + restoreAmount; 

            % Calculate restoration costs. 
            costs = sum( ...
                restoreAmount/obj.restoreGridHealthRate * ...
                obj.restoreGridHealthCost, "all"); 
        end
    end
end



