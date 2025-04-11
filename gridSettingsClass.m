% Grid settings class. 
classdef gridSettingsClass < handle
    properties
        gridSize

        % The desired number of ticks to be in a year.
        % Used to tune oscillation frequencies. 
        ticksPerYear; 
        
        % Rate at which grid health is restored. 
        % Measured in fraction per tick. 
        restoreGridHealthRate; 
        
        % Cost corresponding to grid health regeneration rate. 
        restoreGridHealthCost; 
        
        newFireIntensityMax; 
        newFireIntensityMean; 
        newFireIntensityStandardDeviation; 

        fireIntensityScaler; 
        peakIntensityHealth_mean; 
        peakIntensityHealth_standardDeviation; 
    end
end