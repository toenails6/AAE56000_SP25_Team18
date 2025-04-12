% Simulation and grid settings class. 
classdef gridSettingsClass < handle
    properties
        % Grid size. 
        gridSize; 

        % The desired number of ticks to be in a year.
        % Used to tune oscillation frequencies. 
        ticksPerYear; 

        % Length of the simulation in ticks. 
        tickSpan; 
        
        % Grid health restore rate, in units of fraction per tick. 
        restoreGridHealthRate; 
        
        % Cost corresponding to grid health regeneration rate. 
        restoreGridHealthCost; 
        
        % New fire stochastic generation settings. 
        newFireIntensityMax; 
        newFireIntensityMean; 
        newFireIntensityStandardDeviation; 

        % Fire intensity growth rate relation with health settings. 
        fireIntensityScaler; 
        peakIntensityHealthMin; 
        peakIntensityHealthMax; 
        peakIntensityHealth_mean; 
        peakIntensityHealth_standardDeviation; 
    end
end



