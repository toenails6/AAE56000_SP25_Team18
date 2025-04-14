%Class for Satellite object
%Satellites can scan for info and send it to stations

classdef satelliteClass < handle
    properties
        gridHandle gridclass;
        scanFrequency;
        fireList;
    end
    methods
        %Class Constructor
        function obj = satelliteClass(gridHandle)


        end
        
        %Determines whether a satellite will scan at a given time
        %Returns True or False
        function isTime = isSatelliteTime()

        end

        %Develops the information package to send to each station for a
        %fire
        function message = satelliteInfo(fire)

        end

    end

end