%Class that models the various fire stations for the simulation.
%Stations can have intrinsic resources available to it such as ground and
%Aerial resources.
%Stations also receive information from satellites and generate it
%inaccurately from nearby fires.
%Stations have a priority list that determines how they share their
%resources.
%Stations can send resource to a fire, another station, or keep
%Stations can also mobilize new units at a max rate determining on need

classdef stationClass < handle
    properties
        location; %[row,col]
        airResources; %Amount of air recources
        groundResources; %Amount of ground resources
        priorityList; %The list priority for actions
        gridHandle;
        resourceTracker;

    end

    methods
        %Constructor
        function obj = stationClass(gridHandle, location, ...
                initAir, initGround)

            %Connects station to grid
            obj.gridHandle = gridHandle;
            %Places the station
            obj.location = location;
            %Initializes the resources for the station
            obj.airResources = initAir;
            obj.groundResources = initGround;
            %Initializes priority list to cell array
            obj.priorityList = {};
            obj.resourceTracker = {};

        end
    end
    methods (Static)
        %Determines the priority of a fire
        function priority = firePriority(station,fire,distance, health, type)
            arguments
                station stationClass
                fire
                distance
                health
                type
            end

            %Example weights for the priority eqn (CAN CHANGE)
            if type == "AIR"
                DISTANCE_WEIGHT = 1;
                INTENSITY_WEIGHT = 1;
                GRID_HEALTH_WEIGHT = 1;
            else
                DISTANCE_WEIGHT = 2;
                INTENSITY_WEIGHT = 1;
                GRID_HEALTH_WEIGHT = 1;
            end
            
            %generates an estimate for fire information from satellite or
            %self
            %example equation to determine the fire priority (CAN CHANGE)
            priority = ((INTENSITY_WEIGHT*fire)... 
                + 1/(GRID_HEALTH_WEIGHT*health))...
                / (DISTANCE_WEIGHT*distance)^2;
        end

        %Determines Priority of another station for resources
        %Station 1 is home station, station 2 would be receiving
        function priority = stationPriority(station1, station2, type)
            arguments
                station1 stationClass
                station2 stationClass
                type
            end
            
            %Parameter weights (CAN CHANGE)
            AIR_WEIGHT = 1;
            GROUND_WEIGHT = 1;
            DISTANCE_WEIGHT = 1;

            %Max number of resources a station can hold (CAN CHANGE)
            MAX_AIR = 5;
            MAX_GROUND = 10;
            
            %Ensures that if same station, no priority
            if station1.location == station2.location
                priority = 0;
                return
            end

            %Ensures that if station is at capacity, don't send more
            if station2.airResources >= MAX_AIR || station2.groundResources >= MAX_GROUND
                priority = 0;
                return
            end


            distance = sqrt((station2.location(1)-station1.location(1))^2 ...
                + (station2.location(2)-station1.location(2))^2);


            %Example priority equation (CAN CHANGE)
            if type == "AIR"
                priority = AIR_WEIGHT*(MAX_AIR-station2.airResources)...
                    / (DISTANCE_WEIGHT*distance);
            else
                priority = (GROUND_WEIGHT*(MAX_GROUND-station2.groundResources))...
                    / (DISTANCE_WEIGHT*distance);
            end
        end

        %Determines how important it is to keep resources available
        %If high priority, will not send resources
        %station: the home station object
        %priority: double value indicating the priority to keep resources
        function priority = selfPriority(station)
            
            %Parameter Weights
            AIR_WEIGHT = 1;
            GROUND_WEIGHT = 1;
            GENERAL_GAIN = 0.5;
            MAX_AIR = 5;
            MAX_GROUND = 10;

            if station.airResources >= MAX_AIR || station.groundResources >= MAX_GROUND
                priority = 0;
                return
            end

            priority = GENERAL_GAIN * (AIR_WEIGHT*(MAX_AIR - station.airResources) ...
                + GROUND_WEIGHT*(MAX_GROUND - station.groundResources));
        end

        %Creates the list of priorities
        %station: the home station
        %fireList: list of all fires on a grid
        %stationList: list of all stations on the grid
        %satList: List of all satellites
        function generatePriorityList(station, intensityList, healthList, stationList)
            arguments
                station stationClass
                intensityList double
                healthList double
                stationList cell
            end
            sz = size(intensityList);

            
            station.priorityList = {};

            station.priorityList{1} = {[stationClass.selfPriority(station),stationClass.selfPriority(station)],station.location};
            index = 2;
            for x = 1:sz(1)
                for y = 1:sz(2)
                    if intensityList(x,y) > 0
                        distance = sqrt((station.location(1)-x)^2 + (station.location(2)-y)^2);
                        station.priorityList{index} = ...
                            {[stationClass.firePriority(station,intensityList(x,y),distance, healthList(x,y), "GROUND"),...
                            stationClass.firePriority(station,intensityList(x,y),distance,healthList(x,y),"AIR")], [x,y]};
                            index = index+1;
                    end
                end
            end

            for ii = 1:length(stationList)
                st = stationList{ii};
                station.priorityList{index} = {[stationClass.stationPriority(station,st,"GROUND"), stationClass.stationPriority(station,st,"AIR")],...
                    [st.location(1),station.location(2)]};
                index = index+1;
            end
            
        end

        %This will determine how the home station sends resources from the
        %overall priority list
        function newResources  = sendResources(station,groundList, airList)
            arguments
                station stationClass
                groundList double
                airList double
            end

            newResources = {};

            priorities = station.priorityList;
            
            total = 0;
            for ii = 1:length(priorities)
                total = total + priorities{ii}{1}(1) + priorities{ii}{1}(2);
            end

            for ii = 1:length(priorities)
                tempGround = round(station.groundResources*priorities{ii}{1}(1)/total);
                tempAir = round(station.airResources*priorities{ii}{1}(2)/total);

                if tempGround >= 0
                    groundList(priorities{ii}{2}(1),priorities{ii}{2}(2)) = ...
                        groundList(priorities{ii}{2}(1),priorities{ii}{2}(2)) + tempGround;
                    groundList(station.location(1),station.location(2)) = groundList(station.location(1),station.location(2)) - tempGround;
                    station.resourceTracker{length(station.resourceTracker)+1} = [tempGround,0;priorities{ii}{2}(1),priorities{ii}{2}(2)];
                end
                if tempAir >= 0
                    airList(priorities{ii}{2}(1),priorities{ii}{2}(2)) = ...
                        airList(priorities{ii}{2}(1),priorities{ii}{2}(2)) + tempAir;
                    station.resourceTracker{length(station.resourceTracker)+1} = [0,tempAir;priorities{ii}{2}(1),priorities{ii}{2}(2)];
                    airList(station.location(1),station.location(2)) = airList(station.location(1),station.location(2)) - tempAir;
                end
            end
            
            

            newResources{1} = groundList;
            newResources{2} = airList;


            %What I expect is that the priorities are first summed, and
            %then for each item in the list, you do (available resources) *
            %(individual priority/ total Priority). Then you round it to
            %the nearest integer value. Thus, low priority tasks will not
            %receive any resources.

            %Then, for each resource being used, call receiveResources()
            %for the object which adds resources to the specific object

            %Then, adjust the home station resources down

        end

        function newResources = returnResources(station,intensities,groundList,airList,stationList)
            arguments
                station stationClass
                intensities double
                groundList double
                airList double
                stationList
            end
            newResources = {};
            ii = 1;
            while ii <= length(station.resourceTracker)
                log = station.resourceTracker{ii};
                x = log(2,1);
                y = log(2,2);

                ground = log(1,1);
                air = log(1,2);
                B1 = 1;
                for jj = 1:length(stationList)
                    st = stationList{jj};
                    x2 = st.location(1);
                    y2 = st.location(2);
                    if x == x2 && y == y2
                        B1 = 0;
                        station.resourceTracker(ii) = [];
                        ii = ii-1;
                    elseif ground == 0 & air == 0;
                        B1 = 0;
                        station.resourceTracker(ii) = [];
                        ii = ii-1;
                    end
                end
                if intensities(x,y) == 0 & (ground > 0 || air > 0) & B1 == 1
                    groundList(x,y) = groundList(x,y) - ground;
                    airList(x,y) = airList(x,y) - air;

                    groundList(station.location(1),station.location(2)) =...
                        groundList(station.location(1),station.location(2))+ground;
                    airList(station.location(1),station.location(2)) =...
                        airList(station.location(1),station.location(2))+air;
                    station.resourceTracker(ii) = [];
                    ii = ii-1;
                    
                end
                ii = ii+1;

            end

            newResources{1} = groundList;
            newResources{2} = airList;

        end

        %This will happen when a station receives resources from another
        %station or returning from an extinguished fire
        function updateResources(station, groundList,airList)
            arguments
                station stationClass
                groundList double
                airList double
            end

            x = station.location(1);
            y = station.location(2);

            station.groundResources = groundList(x,y);
            station.airResources = airList(x,y);
        end

        %Allows a station to mobilize/generate more supplies if there is a
        %large amount of need
        function mobilize(station)
            %what I'm imagining is that the total priority of the home
            %station is summed up, and if the total priority crosses a
            %certain threshold (meaning that either there are several high
            %prioirity fires or several stations in need), then it will
            %start to mobilize ground units first, and if the priority
            %rises higher, it will generate aerial units as well
            
            arguments
                station stationClass
            end

            AIR_THRESHOLD = 10;
            GROUND_THRESHOLD = 10;

            MAX_AIR = 5;
            MAX_GROUND = 10;

            priorities = station.priorityList;
            groundTotal = 0;
            airTotal = 0;

            for ii = 1:length(priorities)
                groundTotal = groundTotal + priorities{ii}(1);
                airTotal = airTotal + priorities{ii}(2);
            end
        

            %sum priority values from priority list
            if groundTotal > GROUND_THRESHOLD & station.groundResources < MAX_GROUND
                receiveResources(station,0,1);
            end
            if airTotal > AIR_THRESHOLD & station.airResources < MAX_AIR
                sreceiveResources(station,1,0);
            end
            %if total priority > ground threshold, begin adding 1 ground
            %unit

            %if total priority > air threshold, begin adding 1 air unit
        end

    end
end  