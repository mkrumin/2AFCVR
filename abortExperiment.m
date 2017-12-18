
function abortExperiment

% aborts experiment before it even started 

global daqSession
global BallUDPPort
global ScanImageUDP;
global EyeCameraUDP;
global TimelineUDP;
global OptiStimUDP;
global OFFLINE;
global EXP;

% cleans up and exits state system

Priority(0);

Screen('CloseAll');

if ~OFFLINE
    stopAllDaq;
    delete(daqSession);
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
