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
    end
    methods
        % Class constructor. 
        function obj = gridClass(gridSize1, gridSize2)
            obj.gridSize = [gridSize1, gridSize2]; 

            % Generate risk factor matrix, seeded gaussian RNG. 
            % risk factor ranges from minimum of 0 to maximum of 1. 
            obj.riskFactor = zeros(obj.gridSize(1), obj.gridSize(2)); 
            rng(117); 
            obj.riskFactor = min(max( ...
                normrnd(-0.5, 0.4, obj.gridSize(1), obj.gridSize(2)), ...
                0), 1); 
            rng("default"); 
        end
    end
end



