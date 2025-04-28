% Fire information scanning class. 
classdef fireScanClass < handle
    properties
        gridHandle gridClass; 
        scanFrequency; 
        scannedFireIntensities; 
        scannedGridHealth; 
    end
    methods
        % Class Constructor
        function obj = fireScanClass(gridHandle)
            % Restrict input type for coding convenience. 
            arguments
                gridHandle gridClass; 
            end

            % Record the handle to the parent class, the simulation grid. 
            obj.gridHandle = gridHandle; 

            % Initializations. 
            obj.scannedFireIntensities = ...
                zeros(obj.gridHandle.gridSize); 
            obj.scannedGridHealth = ones(obj.gridHandle.gridSize); 
        end

        % Scans fire intensities and grid health via satellites. 
        function obj = satelliteScan(obj)
            % Check whether it is satellite scan time. 
            if ~mod( ...
                    obj.gridHandle.tick, ...
                    obj.gridHandle.satelliteScanFrequency)
                % Updates satellite scanned fire intensities information. 
                obj.scannedFireIntensities = ...
                    obj.gridHandle.fires.intensity; 

                % Updates satellite scanned grid health information. 
                obj.scannedGridHealth = obj.gridHandle.gridHealth; 
            end
        end
    end
end



