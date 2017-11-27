function list = getOptiStimList(animalName)
%%
if nargin <1
    animalName = 'default';
end

list = struct;

switch upper(animalName)
    case 'MK027'
        % definte all the locations with laser Powers
        ML = [-1.7, 1.7];
        AP = [-2, -2];
        laserPower = [1.5 1.5];
        
        % define possible stimulation types
        % stimType = {'POSITION', 'POSITION', 'POSITION'};
        % onset = [0 35 70]; stimulating during the first, second, or third third
        % of the maze
        % offset = [35 70 110];
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'MK028'
        ML = [-1.7, 1.7];
        AP = [-2, -2];
        laserPower = [1 1];
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    otherwise
        % default values - PPC
        ML = [-1.7, 1.7];
        AP = [-2, -2];
        laserPower = [1 1];
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
        
end

nPoints = length(ML);
nTypes = length(stimType);

% make a list with all the necessary combinations
% for each stimulation type we go through all the locations, which can be
% 'on' or 'off' independently of each other
% 'on' or 'off' state will be controlled by the laser power

nStates = nPoints^2;
states = dec2bin(0:nStates-1, nPoints) == '1';
iStim = 0;
for iType = 1:nTypes
    for iState = 1:nStates
        
        iStim = iStim + 1;
        list(iStim).ML = ML;
        list(iStim).AP = AP;
        list(iStim).laserPower = laserPower.*states(iState, :);
        list(iStim).stimType = stimType{iType};
        list(iStim).onset = onset(iType);
        list(iStim).offset = offset(iType);
    end
end
