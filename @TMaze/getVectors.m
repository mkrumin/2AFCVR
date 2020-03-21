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

trialData = estMouseRunning(trialData, obj.EXP);
obj.trialData = trialData(:);

end

function dataOut = estMouseRunning(dataIn, EXP)
    
    dataOut = dataIn;
    [BALL_TO_DEGREE, BALL_TO_ROOM] = getScalingFactors(dataIn, EXP);
    nTrials = length(dataIn);
    for iTrial = 1:nTrials
        tr = dataIn(iTrial);

        % mimicking whatever the VR was doing during the behavior

        % raw data as received from the ball
        dax = tr.ballRaw.dax;
        day = tr.ballRaw.day;
        dbx = tr.ballRaw.dbx;
        dby = tr.ballRaw.dby;
        
        % replace NaNs with zeros
        dax(isnan(dax)) = 0;
        day(isnan(day)) = 0;
        dbx(isnan(dbx)) = 0;
        dby(isnan(dby)) = 0;
        
        % translate from pixels to cm and degrees
        dax_orig = dax*BALL_TO_ROOM;
        dbx_orig = dbx*BALL_TO_ROOM;
        day_orig = day*BALL_TO_DEGREE; %unused, because dby encodes the same information
        dby_orig = dby*BALL_TO_DEGREE;

        % mulitply by gain factors used in the VR
        dax = dax_orig*EXP.xGain;
        dbx = dbx_orig*EXP.zGain;
        day = day_orig*pi/180*EXP.aGain; %unused, because dby encodes the same information
        dby = dby_orig*pi/180*EXP.aGain;
        
        if isfield(EXP, 'ballBias')
            dby = dby + dbx/100 * EXP.ballBias * pi/180;
        end
        
        z0 = EXP.minWallsDistance;
        theta0 = 0;
        x0 = 0;
        theta = theta0 + cumsum(dby.*tr.meta.closedLoop);
        z = z0 + cumsum((dbx.*cos(theta) + dax.*sin(theta)).*tr.meta.closedLoop);
        x = x0 + cumsum((dbx.*sin(theta) + dax.*cos(theta)).*tr.meta.closedLoop);
        
        dataOut(iTrial).mouse = struct;
        % mouse position in the maze 'without the walls' (not restricted by VR rules)
        dataOut(iTrial).mouse.x = x; 
        dataOut(iTrial).mouse.z = z;
        dataOut(iTrial).mouse.theta = theta * 180/pi;
        % running increments of the mouse, after multiplication of VR gains
        % and after using VR corrections (e.g. ballBias)
        dataOut(iTrial).mouse.dRollVR = dax;
        dataOut(iTrial).mouse.dPitchVR = dbx;
        dataOut(iTrial).mouse.dYawVR = dby;
        % raw running increments of the mouse (in real world units)
        dataOut(iTrial).mouse.dRollRaw = dax_orig;
        dataOut(iTrial).mouse.dPitchRaw = dbx_orig;
        dataOut(iTrial).mouse.dYawRaw = dby_orig;
        
    end
end

function [BALL_TO_DEGREE, BALL_TO_ROOM] = getScalingFactors(data, EXP)

        % these are scaling factors from run.m for ZAMBONI rig
        BALL_TO_DEGREE = 1/12;
        BALL_TO_ROOM = 1/65;

        return;
        
        % this code is prep for future use, to estimate the scaling
        % factors from actual VR data (if unknown)
        
        for iTrial = 1:nTrials
            tr = data(iTrial);
            % times when the mouse was controlling the VR
            idxCL = tr.meta.closedLoop;
            % positions in the main corridor
            idxZ = tr.vr.z < (EXP.roomLength - EXP.corridorWidth - EXP.minWallsDistance);
            % positions within the valid theta range
            idxTh = abs(tr.vr.theta) < (EXP.restrictionAngle*180/pi - 0.1);
            % not 'hugging' the side wall
            idxX = abs(tr.vr.x) < (EXP.corridorWidth/2 - EXP.minWallsDistance - 0.1);
            
            validIdx = find(idxCL & idxZ & idxTh & idxX);
        end
end
