function valveOpen

% global AO
% global daqSession
% global optiStimChanInd; % LED/laser stim AO channel index
% global valveChanInd; % reward valve AO channel index
% global TRIAL
% global OFFLINE
% global EXP

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
daqSession.addAnalogOutputChannel(aoDeviceID, aoValveChannel, 'Voltage');
daqSession.outputSingleScan(valveOpenVoltage);

stop(daqSession);
delete(daqSession);