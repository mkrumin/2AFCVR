function list = getOptiStimList()

list = struct;

ML = [-1.7, 1.7];
AP = [-2, -2];
laserPower = [2 2];

stimType = {'POSITION'};
onset = [0];
offset = [110];


nPoints = length(ML);
nTypes = length(stimType);

iStim = 0;
for iType = 1:nTypes
    for iPoint = 1:nPoints
        for jPoint = iPoint:nPoints
            iStim = iStim + 1;
        list(iStim).ML = ML;
        list(iStim).AP = AP;
        list(iStim).laserPower = 
        list(iStim).stimType = stimType{iType};
        list(iStim).onset = onset(iType);
        list(iStim).offset = offset(iType);
        end
    end
end