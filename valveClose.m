function valveClose

% global AO
% global daqSession
% global optiStimChanInd; % LED/laser stim AO channel index
% global valveChanInd; % reward valve AO channel index
% global TRIAL
% global OFFLINE
% global EXP

[~, RIGNAME]=system('hostname');

if ~isempty(strfind(RIGNAME, 'ZILLION'))
    aoID='Dev2';
    dioID='Dev2';
    dioCh=1;
    dioPort=0;
    optiStimChanInd=1;
    valveChanInd=2;
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

ValveClosed = 5;
ValveOpen = 0;
daqSession = daq.createSession(daqVendorName);
daqSession.addAnalogOutputChannel(aoDeviceID, aoValveChannel, 'Voltage');
daqSession.outputSingleScan(ValveClosed);

stop(daqSession);
delete(daqSession);