% Class that contains the information of all fires across the grid. 
% Intensity can be a negative number, leaving a small margin to zero. 
% Fires exist after intensity goes above zero. 
% Fires are considered put out, or risk controlled, if intensity is below
% an arbitrary negative value. 
% Intensity grows stochastically based on risk factor of the grid block. 
% Fires can spread based on intensity and neighbouring risk factors, which
% means local intensity grows after neighbouring intensity reaches beyond a
% certain threshold based on local risk factor. 
classdef fireClass < handle
    properties
        Intensity; 
    end
end
