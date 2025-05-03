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
        totalCost;
    end

    methods
        %Constructor
        %x is the x location of the station, y is the y location
        function obj = stationGridClass(x,y,n)
            obj.stationGrid = {};
            obj.airGrid = zeros(x,y);
            obj.groundGrid = zeros(x,y);
            obj.totalCost = 0;
            
            for ii = 1:n
                loc = [randi(x),randi(y)];
                initAir = randi(4);
                initGround = randi([8,16]);
                obj.stationGrid{ii} = stationClass(ii,loc,initAir,initGround);
                obj.airGrid(loc(1),loc(2)) = initAir;
                obj.groundGrid(loc(1),loc(2)) = initGround;
                obj.totalCost = obj.totalCost + obj.stationGrid{ii}.cost;
            end
        end

    end
    methods (Static)
        function updateStations(stationGrid, fireIntensities, healths)
            stations = stationGrid.stationGrid;
            airResources = stationGrid.airGrid;
            groundResources = stationGrid.groundGrid;
            stationGrid.totalCost = 0;

        
            for jj = 1:length(stations)
                stationClass.generatePriorityList(stations{jj},fireIntensities,healths,stations);
            end
            for jj = 1:length(stations)
                newResources = stationClass.sendResources(stations{jj},groundResources,airResources);

                groundResources = newResources{1};
                airResources = newResources{2};
                
                newResources = stationClass.mobilize(stations{jj},groundResources,airResources);

                groundResources = newResources{1};
                airResources = newResources{2};

                newResources = stationClass.returnResources(stations{jj},fireIntensities,groundResources,airResources,stations);

                groundResources = newResources{1};
                airResources = newResources{2};

                stationClass.updateResources(stations{jj},groundResources,airResources);
                stationGrid.totalCost = stationGrid.totalCost + stations{jj}.cost;
                
            end
            stationGrid.groundGrid = groundResources;
            stationGrid.airGrid = airResources;
        end
    end
end