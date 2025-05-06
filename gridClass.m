% This is the overarching simulation grid class. 
% This class inherits from the grid settings class, and copies settings
% upon instantiation. 
classdef gridClass < gridSettingsClass
    properties
        tick = 1; 
        tickSpanRNG_Seed; 
        riskFactor; 
        riskFactor_0; 
        riskFactorAmplitudes; 
        gridHealth; 
        airResources; 
        groundResources; 
        tickRestorationCosts; 
        tickCost; 
        totalCosts; 

        % Subclasses: 
        fires fireClass; 
        fireScan fireScanClass; 
        stations stationGridClass; 
    end
    methods
        % Class constructor. 
        function obj = gridClass(gridSettings)
            % Restrict input type for coding convenience. 
            arguments
                gridSettings gridSettingsClass; 
            end

            % Copy sim and grid settings. 
            gridSettingsProperties = properties(gridSettings); 
            for i = 1: length(gridSettingsProperties)
                obj.(gridSettingsProperties{i}) = ...
                    gridSettings.(gridSettingsProperties{i}); 
            end

            % Generate RNG seed for every tick of the simulation. 
            rng(1024); 
            obj.tickSpanRNG_Seed = randi(1E8, size(obj.tickSpan)); 

            % Initialize grid health. 
            obj.gridHealth = ones(obj.gridSize); 

            % Initialize total costs. 
            obj.totalCosts = 0; 

            % Generate initial risk factor matrix via seeded gaussian RNG. 
            % Risk factor ranges from minimum of 0 to maximum of 1. 
            obj.riskFactor_0 = zeros(obj.gridSize(1), obj.gridSize(2)); 
            rng(117); 
            obj.riskFactor_0 = min(max( ...
                normrnd( ...
                obj.riskFactorMean, ...
                obj.riskFactorStandardDeviation, obj.gridSize), ...
                0), 1); 

            % Generate risk factor oscillation amplitudes. 
            obj.riskFactorAmplitudes = zeros(obj.gridSize); 
            rng(54); 
            obj.riskFactorAmplitudes = min(max( ...
                normrnd( ...
                obj.riskFactorAmplitudeMean, ...
                obj.riskFactorAmplitudeStandardDeviation, ...
                obj.gridSize), 0), 1); 

            % Instantiate fire simulations class. 
            obj.fires = fireClass(obj); 

            % Instantiate fire scan class. 
            obj.fireScan = fireScanClass(obj); 

            % Instantiate station grid class. 
            % stationCount = round(prod(obj.gridSize)/32); 
            stationCount = 8; 
            obj.stations = stationGridClass( ...
                obj.gridSize(1), obj.gridSize(2), stationCount); 
        end

        % Update risk factor method, simulating periodic seasonal changes. 
        % Risk factors constrained to minimum of 0 and maximum of 1. 
        function obj  = updateRiskFactor(obj)
            obj.riskFactor = obj.riskFactor_0 + ...
                obj.riskFactorAmplitudes*sin(obj.tick * ...
                2*pi/obj.ticksPerYear); 
            obj.riskFactor = min(max(obj.riskFactor, 0), 1); 
        end

        % Restore grid block health method. 
        function obj = restoreGridHealth(obj)
            % Locate grid blocks without fire. 
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
            obj.tickRestorationCosts = costs; 
        end

        % Update tick method. 
        function obj = updateTick(obj)
            obj.tick = obj.tick + 1; 
        end

        % Simulation grid update method. 
        function obj = updateGrid(obj)
            obj.updateRiskFactor(); 
            obj.restoreGridHealth(); 
            obj.fires.generateFires(); 
            obj.fires.updateIntensity(); 
            obj.fireScan.satelliteScan(); 

            % Fire stations functionality. 
            obj.stations.updateStations( ...
                obj.stations, ...
                obj.fires.intensity, ...
                obj.fireScan.scannedGridHealth); 
            obj.airResources = obj.stations.airGrid; 
            obj.groundResources = obj.stations.groundGrid; 

            % Extinguish fires. 
            obj.fires.extinguish(); 

            % Calculate costs. 
            obj.updateCost(); 

            % Update tick at the end of the grid update method. 
            obj.updateTick(); 
        end

        % Cost estimation method. 
        function obj = updateCost(obj)
            obj.tickCost = sum( ...
                obj.tickRestorationCosts + ...
                obj.stations.totalCost, "all"); 
            obj.totalCosts = obj.totalCosts + obj.tickCost; 
        end
    end
end
