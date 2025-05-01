%This is a class to simulate several fire stations at once in a grid. It
%simulates their actions using fire intensities.

classdef stationGridClass < handle
    %Station Grid is a list of the current fire stations
    %Air grid is a 2D matrix that details the current number of air
    %resources throughout the entire grid
    %The ground grid details how many ground grids there are as well
    properties
        stationGrid;
        airGrid;
        groundGrid;
        gridHandle gridclass;
    end

    methods
        %Constructor
        %x is the x location of the station, y is the y location
        function obj = stationGridClass(gridHandle,x,y,n)
            obj.gridHandle = gridHandle;
            obj.stationGrid = {};
            obj.airGrid = zeros(x,y);
            obj.groundGrid = zeros(x,y);
            
            for ii = 1:n
                loc = [randi(x),randi(y)];
                initAir = randi(4);
                initGround = randi([3,8]);
                obj.stationGrid{ii} = stationClass(gridHandle,loc,initAir,initGround);
                obj.airGrid(loc(1),loc(2)) = initAir;
                obj.groundGrid(loc(1),loc(2)) = initGround;
            end
        end

    end
    methods (Static)
        function updateStations(stationGrid, fireIntensities, healths)
            stations = stationGrid.stationGrid;
            airResources = stationGrid.airGrid;
            groundResources = stationGrid.groundGrid;

        
            for jj = 1:length(stations)
                stationClass.generatePriorityList(stations{jj},fireIntensities,healths);
                newResources = stationClass.sendResources(stations{jj},groundResources,airResources);

                groundResources = newResources{1};
                airResources = newResources{2};

                newResources = stationClass.returnResources(stations{jj},fireIntensities,groundResources,airResources);

                groundResources = newResources{1};
                airResources = newResources{2};

                stationClass.updateResources(stations{jj},groundResources,airResources);
                
            end
        end
    end
end