function valveCalibrate(nClicks, rewardType)

global daqSession
global OFFLINE
global EXP

if nargin<1
    nClicks=100;
end

if nargin<2
    rewardType='CORRECT';
end

OFFLINE=false;
EXP=setExperimentPars;

[~, RIGNAME]=system('hostname');

if ~isempty(strfind(RIGNAME, 'ZAMBONI'))
    daqVendorName = 'ni'; % this name is used for 64-bit interface
    aoDeviceID='Dev1';
    aoValveChannel = 'ao0';
    dioID='Dev1';
    dioCh=1;
    dioPort=0;
    optiStimChanInd=2;
    valveChanInd=1;
elseif ~isempty(strfind(RIGNAME, 'ZMAZE'))
    daqVendorName = 'ni'; % this name is used for 64-bit interface
    aoDeviceID='Dev1';
    aoValveChannel = 'ao0';
    dioID='Dev1';
    dioCh=1;
    dioPort=0;
    optiStimChanInd=2;
    valveChanInd=1;
else
    aoID='Dev1';
    dioID='Dev1';
    dioCh=1;
    dioPort=0;
    optiStimChanInd=1;
    valveChanInd=2;
end

daqSession = daq.createSession(daqVendorName);
daqSession.Rate = 10e3;
% defining the Analog Output object for the valve (for precise timing)
daqSession.addAnalogOutputChannel(aoDeviceID, aoValveChannel, 'Voltage');
daqSession.outputSingleScan(valveClosedVoltage);

% 
% TRIAL.info.optiStim=0; % just a patch to prevent the reward() function from crashing

% DIO = digitalio('nidaq', dioID);
% addline(DIO, dioCh, dioPort, 'Out', {'SOL1'});
% start(DIO);
% putvalue(DIO.Line(1), 1); % high value -  closing the valve

large = EXP.largeRewardTime
small = EXP.smallRewardTime
for iClick=1:nClicks
    reward(rewardType)
    pause(0.3);
end

stop(daqSession);
delete(daqSession);