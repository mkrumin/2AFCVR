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
        laserPower = [4, 4];
        
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
    case 'JC001'
        % default values - PPC
        ML = [-1.7, 1.7];
        AP = [-2, -2];
        laserPower = [4 4];
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'JC003'
        % PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[4 4]; [4 4]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'JC004'
        % default values - PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[4 4]; [4 4]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'MK031'
        % default values - PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[8 8]; [8 8]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'MK033'
        % default values - PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[4 4]; [4 4]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    case 'MK032'
        % default values - PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[8 8]; [8 8]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
    otherwise
        % default values - PPC & V1
        ML = {[-1.7, 1.7]; [-2.5, 2.5]};
        AP = {[-2, -2]; [-3.5 -3.5]};
        laserPower = {[1 1]; [1 1]};
        stimType = {'POSITION'};
        onset = [10];
        offset = [110];
        
end

% for backwards compatibility
if ~iscell(ML)
    ML = {ML};
    AP = {AP};
    laserPower = {laserPower};
end

nTypes = length(stimType);
nGroups = length(ML);
% make a list with all the necessary combinations
% for each stimulation type we go through all the locations, which can be
% 'on' or 'off' independently of each other
% 'on' or 'off' state will be controlled by the laser power

iStim = 0;
for iGroup = 1:nGroups
    nPoints = length(ML{iGroup});
    nStates = nPoints^2;
    states = dec2bin(0:nStates-1, nPoints) == '1';
    for iType = 1:nTypes
        for iState = 1:nStates
            iStim = iStim + 1;
            list(iStim).ML = ML{iGroup};
            list(iStim).AP = AP{iGroup};
            list(iStim).laserPower = laserPower{iGroup}.*states(iState, :);
            list(iStim).stimType = stimType{iType};
            list(iStim).onset = onset(iType);
            list(iStim).offset = offset(iType);
        end
    end
end