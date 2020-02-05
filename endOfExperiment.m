%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

function fhandle = endOfExperiment

global daqSession
global BallUDPPort
global ScanImageUDP;
global EyeCameraUDP;
global TimelineUDP;
global OptiStimUDP;
global EXPREF;
global OFFLINE;
global SESSION;
global EXP;
% animalName = regexp(EXPREF, '_([A-Za-z]*\d+)$', 'tokens', 'once');

% cleans up and exits state system

fprintf('<stateSystem> endOfExperiment\n'); % debug
Priority(0);

Screen('CloseAll');

SESSION.Log;

if ~isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    nSmallRewards = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE', 'USER'}));
    nLargeRewards = sum(ismember({SESSION.Log(2:end).Event}, {'CORRECT'}));
    
    fprintf('\nnTrials = %d, nSmallRewards = %d, nLargeRewards = %d\n\n', ...
        length(SESSION.allTrials), nSmallRewards, nLargeRewards);
    
    waterAmount = nSmallRewards*EXP.smallRewardAmount + ...
        nLargeRewards*EXP.largeRewardAmount;
    fprintf('Water received = %05.3f ml\n', waterAmount);
end

if ~OFFLINE
    stopAllDaq;
    delete(daqSession);
    
    [animalID, iseries, iexp] = dat.expRefToMpep(EXPREF);
    msgString = sprintf('ExpEnd %s %d %d', animalID, iseries, iexp);
    
    pnet(ScanImageUDP, 'write', msgString);
    pnet(ScanImageUDP, 'writePacket');
    
    pnet(EyeCameraUDP, 'write', msgString);
    pnet(EyeCameraUDP, 'writePacket');
    
    pnet(TimelineUDP, 'write', msgString);
    pnet(TimelineUDP, 'writePacket');
    
    if EXP.optiStim
        msgStruct = struct('instruction', 'ExpEnd', 'ExpRef', EXPREF);
        msgJson = savejson('msg', msgStruct);
        
        pnet(OptiStimUDP, 'write', msgJson);
        pnet(OptiStimUDP, 'writePacket');
    end

end

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

%closing all the UDP ports
pnet(BallUDPPort, 'close');
pnet(ScanImageUDP, 'close');
pnet(EyeCameraUDP, 'close');
pnet(TimelineUDP, 'close');
if EXP.optiStim
    pnet(OptiStimUDP, 'close');
end

clear mex;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end

fhandle = []; % exit state system

% return; %skip the Alyx thing for now

if strfind(upper(animalID), 'FAKE')
    % do nothing
else
    fprintf('Saving to Alyx..\n')
%     if exist('C:\Users\Experiment\Documents\MATLAB\Alyx', 'dir')
%         addpath(genpath('C:\Users\Experiment\Documents\MATLAB\Alyx'));
%     else
%         addpath(genpath('C:\Users\Experiment\Documents\GitHub\alyx-matlab'));
%     end
%     onLoad;
    
    %     alyxData.user = 'julie';
    myAlyx = Alyx;
    
    newWater = myAlyx.postWater(animalID, waterAmount, now, 'Water 10% Sucrose');
    
    fprintf('%05.3f ml water administered\n%s\n', waterAmount, newWater.url)
end
