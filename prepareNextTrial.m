%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

% prepareNextTrial
% initializes trial specific information such us initializing base
% information


function fhandle = prepareNextTrial

global TRIAL; % save trial specific info here
global TRIAL_COUNT; % necessary to keep track of TRIAL count and set it for next trial;
global EXP;
global OFFLINE
global ScanImageUDP;
global EyeCameraUDP;
global TimelineUDP;
global OptiStimUDP;
global EXPREF;

TRIAL_COUNT = TRIAL_COUNT +1;

info = [];

info.no = TRIAL_COUNT;
info.epoch = 0; %number of steps within a run loop
info.abort = 0;
info.start = -1; % it will be set to 1 at the beginning of run.m

if EXP.optiStim
    nOptions = length(EXP.optiStimList);
    optInd = ceil(rand*nOptions);
    info.optiStim = EXP.optiStimList(optInd);
end
TRIAL.info = info;

% fprintf('PrepareNextTrial\n'); % debug
fprintf('*** trial %4d of %4d ***\n', TRIAL.info.no, EXP.maxNTrials); % debug

if isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    nCounts = length(TRIAL.syncState);
    TRIAL.pospars = {'X','Y','Z','theta','speed','inRoom'};
    TRIAL.time = nan(nCounts,1,'double');
    TRIAL.balldata = nan(nCounts,5,'double');
    TRIAL.balldataParams = {'ballTime', 'dax', 'dbx', 'day', 'dby'};
else
    TRIAL.posdata = zeros(3000,6,'double'); % x,y,z,theta,speed,inRoom
    TRIAL.pospars = {'X','Y','Z','theta','speed','inRoom'};
    TRIAL.time = zeros(3000,1,'double');
    TRIAL.balldata = []; %zeros(3000,5,'double');
    TRIAL.balldataParams = {'ballTime', 'dax', 'dbx', 'day', 'dby'};
    TRIAL.syncState=[0;0];
    TRIAL.trialActive=[false; false];
    TRIAL.freezeOver=[false; false];
end

%% now send UDPs to all the data hosts
if ~OFFLINE
    [animalID, iseries, iexp] = dat.expRefToMpep(EXPREF);
    istim=TRIAL.info.no;
    irepeat=1;
    StimDurSeconds=EXP.grayScreenDur+EXP.maxTrialDuration;
    StimDur=ceil(StimDurSeconds*10); % to be consistent with mpep units
    
    msgString = sprintf('StimStart %s %d %d %d %d %d', animalID, iseries, iexp, irepeat, istim, StimDur);
    
    pnet(ScanImageUDP, 'write', msgString);
    pnet(ScanImageUDP, 'writePacket');
    
    pnet(EyeCameraUDP, 'write', msgString);
    pnet(EyeCameraUDP, 'writePacket');
    
    pnet(TimelineUDP, 'write', msgString);
    pnet(TimelineUDP, 'writePacket');
    
    msgStruct = struct('instruction', 'ZapPrepare',...
        'ExpRef', EXPREF,...
        'iTrial', TRIAL.info.no,...
        'maxDuration', EXP.maxTrialDuration,...
        'ML', info.optiStim.ML,...
        'AP', info.optiStim.AP,...
        'power', info.optiStim.laserPower);
    msgJson = savejson('msg', msgStruct);

    pnet(OptiStimUDP, 'write', msgJson);
    pnet(OptiStimUDP, 'writePacket');

end

if isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    fhandle = @runReplayScrambled;
else
    fhandle = @run;
end
return
end
