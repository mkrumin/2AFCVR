function stopAllDaq

% this function is closing all the daq
% currently is dumb, and assumes there is only one channel, which is the
% valve

global daqSession servoDaqSession

if daqSession.IsRunning
    daqSession.stop();
    daqSession.wait();
end

daqSession.outputSingleScan(valveClosedVoltage);
servoDaqSession.outputSingleScan(parkServoVoltage);