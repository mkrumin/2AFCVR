function obj = getVectors(obj)

trials = obj.SESSION.allTrials(1:obj.nTrials);
nTrials = length(trials);
[~, zInd] = intersect(trials(1).pospars, 'Z');
[~, xInd] = intersect(trials(1).pospars, 'X');
[~, thInd] = intersect(trials(1).pospars, 'theta');
[~, spInd] = intersect(trials(1).pospars, 'speed');
[~, daxInd] = intersect(trials(1).balldataParams, 'dax');
[~, dayInd] = intersect(trials(1).balldataParams, 'day');
[~, dbxInd] = intersect(trials(1).balldataParams, 'dbx');
[~, dbyInd] = intersect(trials(1).balldataParams, 'dby');
[~, dLInd] = intersect(trials(1).glassWallsPars, 'distLeftWall');
[~, dRInd] = intersect(trials(1).glassWallsPars, 'distRightWall');
[~, stagePosInd] = intersect(trials(1).glassWallsPars, 'stagePosition');
[~, stageVInd] = intersect(trials(1).glassWallsPars, 'stageVoltageSignal');



%%
for iTrial = 1:nTrials
    nSamples = trials(iTrial).info.epoch;
    % this is time relative to the beginning of inter trial interval
    trialData(iTrial).t = trials(iTrial).time(2:nSamples) - trials(iTrial).time(2);
    % these are related to the position of the mouse in the VR maze
    trialData(iTrial).vr.x = trials(iTrial).posdata(2:nSamples, xInd);
    trialData(iTrial).vr.z = -trials(iTrial).posdata(2:nSamples, zInd);
    trialData(iTrial).vr.theta = trials(iTrial).posdata(2:nSamples, thInd) * 180 / pi;
    
    % these are related to the mouse movement on the ball
    trialData(iTrial).ballRaw.dax = trials(iTrial).balldata(2:nSamples, daxInd);
    trialData(iTrial).ballRaw.day = trials(iTrial).balldata(2:nSamples, dayInd);
    trialData(iTrial).ballRaw.dbx = trials(iTrial).balldata(2:nSamples, dbxInd);
    trialData(iTrial).ballRaw.dby = trials(iTrial).balldata(2:nSamples, dbyInd);
    
    trialData(iTrial).walls.dL = trials(iTrial).glassWallsData(2:nSamples, dLInd);
    trialData(iTrial).walls.dR = trials(iTrial).glassWallsData(2:nSamples, dRInd);
    trialData(iTrial).walls.stagePos = trials(iTrial).glassWallsData(2:nSamples, stagePosInd);
    trialData(iTrial).walls.stageV = trials(iTrial).glassWallsData(2:nSamples, stageVInd);
    
    trialData(iTrial).meta.trialOn = trials(iTrial).trialActive;
    trialData(iTrial).meta.closedLoop = trials(iTrial).freezeOver;
end

trialData = estMouseRunning(trialData);

end

function dataOut = estMouseRunning(dataIn)
    
    nTrials = length(dataIn);
    for iTrial = 1:nTrials
        tr = dataIn(iTrial);
        % times when the mouse was controlling the VR
        idxCL = tr.meta.closedLoop;
        % positions in the main corridor
        idxZ = tr.vr.z < (obj.EXP.roomLength - obj.EXP.corridorWidth - obj.EXP.minWallsDistance);
        % positions within the valid theta range
        idxTh = abs(tr.vr.theta) < (obj.EXP.restrictionAngle*180/pi - 0.1);
        % not 'hugging' the side wall
        idxX = abs(tr.vr.x) < (obj.EXP.corridorWidth/2 - obj.EXP.minWallsDistance - 0.1);
        
        validIdx = find(idxCL & idxZ & idxTh & idxX);
        
        
    end
end

TRIAL.posdata(count,T) = TRIAL.posdata(count-1,T) + dby;
if(abs(TRIAL.posdata(count,T))>(pi))
    TRIAL.posdata(count,T) = -1*((2*pi)-abs(TRIAL.posdata(count,T)))*sign(TRIAL.posdata(count,T));
end
TRIAL.posdata(count,X) = TRIAL.posdata(count-1,X) + ...
    dbx*sin(TRIAL.posdata(count,T)) + dax*cos(TRIAL.posdata(count,T));
TRIAL.posdata(count,Z) = TRIAL.posdata(count-1,Z) - ...
    dbx*cos(TRIAL.posdata(count,T)) + dax*sin(TRIAL.posdata(count,T));
            