function stopAllDaq

% this function is closing all the daq
% currently is dumb, and assumes there is only one channle, which is the
% valve

global daqSession

if daqSession.IsRunning
    daqSession.stop();
    daqSession.wait();
end

ValveClosed = 5;
daqSession.outputSingleScan(ValveClosed);
