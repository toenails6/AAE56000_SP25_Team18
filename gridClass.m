% This class contains information on the grid blocks, such as risk factor
% of getting fires due to geological conditions, etc. 
% There would be an initial risk factor generated from a seeded RNG. 
% The risk factor would then oscillate periodically through a sine function
% to mimic seasonal influence. 
% There will be a seeded RNG generated amplitude for each grid block. 
% There can be also be manual tuning of these parameters. 
classdef gridClass < handle
    properties
        gridSize = [128, 256]; 
        riskFactor; 
        riskFactor_0; 
        riskFactorAmplitudes; 
        gridHealth; 

        % The desired number of ticks to be in a year.
        % Used to tune oscillation frequencies. 
        ticksPerYear; 
    end
    methods
        % Class constructor. 
        function obj = gridClass(gridSize1, gridSize2, ticksPerYear)
            obj.gridSize = [gridSize1, gridSize2]; 
            obj.ticksPerYear = ticksPerYear; 

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
        end

        % Update risk factor, simulating periodic seasonal changes. 
        % Limit risk factors to minimum of 0 to maximum of 1. 
        function obj  = updateRiskFactor(obj, tick)
            obj.riskFactor = obj.riskFactor_0 + ...
                obj.riskFactorAmplitudes*sin(tick * ...
                2*pi/obj.ticksPerYear); 
            obj.riskFactor = min(max(obj.riskFactor, 0), 1); 
        end
    end
end



