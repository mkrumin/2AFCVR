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
global EXPREF;
global OFFLINE;
global SESSION;
global EXP;

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
    
    waterAmount = nSmallRewards*0.002 + nLargeRewards*0.004;
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
end

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

%closing all the UDP ports
pnet(BallUDPPort, 'close');
pnet(ScanImageUDP, 'close');
pnet(EyeCameraUDP, 'close');
pnet(TimelineUDP, 'close');

clear mex;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end

fhandle = []; % exit state system
