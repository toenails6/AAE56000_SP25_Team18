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
        gridHandle gridclass
    end

    methods (Static)
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
        end

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
        function generatePriorityList(station, fireList, stationList)
            arguments
                station stationClass
                fireList
                stationList
            end
                
            station.priorityList{1} = {[selfPriority(station), selfPriority(station)], station};
            
            index = 2;
            for fire = fireList
                tempPriorityG = firePriority(station,fire,"GROUND");
                tempPriorityA = firePriority(station,fire,"AIR");
                station.priorityList{index} = {[tempPriorityG,tempPriorityA],fire};
                index = index + 1;
            end

            for station2 = stationList
                station.priorityList{index} = {[stationPriority(station,station2,"GROUND"),stationPriority(station,station2,"AIR")],station2};
                index = index + 1;
            end 
        end

        %This will determine how the home station sends resources from the
        %overall priority list
        function sendResources(station)
            arguments
                station stationClass
            end

            priorities = station.priorityList;
            
            total = 0;
            for ii = 1:length(priorities)
                total = total + priorities{ii}(1) + priorities{ii}(2);
            end

            for ii = 1:length(priorities)
                tempGround = round(station.groundResources*priorities{ii}(1)/total);
                tempAir = round(station.airResources*priorities{ii}(2)/total);

                if tempGround >= 0
                    receiveResources(priorities{ii}(2),0,tempGround);
                end
                if tempAir >= 0
                    receiveResources(priorities{ii}(2),tempAir,0);
                end
            end

            station.groundResources = station.groundResources - tempGround;
            station.airResources = station.airResources - tempAir;



            %What I expect is that the priorities are first summed, and
            %then for each item in the list, you do (available resources) *
            %(individual priority/ total Priority). Then you round it to
            %the nearest integer value. Thus, low priority tasks will not
            %receive any resources.

            %Then, for each resource being used, call receiveResources()
            %for the object which adds resources to the specific object

            %Then, adjust the home station resources down

        end


        %This will happen when a station receives resources from another
        %station or returning from an extinguished fire
        function receiveResources(station, air, ground)
            arguments
                station stationClass
                air double
                ground double
            end

            station.airResources = station.airResources + air;
            station.groundResources = station.groundResources + ground;
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