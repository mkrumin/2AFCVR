%% AA 2009-12: virtual reality for training mice
% MK 2011-12: adapting the code for a T-maze task
% MK 2014-03: thorough rewrite and cleanup + adapting for the two-photon rig

function MouseBallExp(offline_in)
%---------------------------------------
% Usage:    MouseBallExp
%           MouseBallExp(1): To run/debug on computers that not connected
%           to the mouse ball or calibrated

[~, rig] = system('hostname'); rig = rig((rig ~= 10)); % to remove the CR at the end

if strfind(rig, 'ZAMBONI')
    clear all;
end

global daqSession;     % analog output for valve triggering & light stimulation(instead of DIO)
global BallUDPPort;    % the UDP port
global ScanImageUDP;  % the UDP port
global EyeCameraUDP;  % the UDP port
global TimelineUDP;  % the UDP port
global OptiStimUDP; 
global SYNC;        % synchronization square
global MYSCREEN;    % screen info
global OFFLINE;
global RIGNAME;
global EXP;
global SAVE2SERVER;

SAVE2SERVER = true;

if nargin<1
    OFFLINE = 0;
else
    
    OFFLINE = offline_in;
end

clear mex

EXP = setExperimentPars; %is this needed?  


%% Initialize IP addresses and UDP communication
Screen('Preference', 'SkipSyncTests', 1);
[~, RIGNAME] = system('hostname'); 
RIGNAME = RIGNAME((RIGNAME ~= 10)); % to remoove the CR at the end

if strfind(RIGNAME, 'ZMAZE')
    ScanImageIP='zscope';
    TimelineIP='zcamp3';
    EyeCameraIP='zquad';
    OptiStimIP = 'zcamp3';
    daqVendorName = 'ni'; % this name is used for 64-bit interface
    aoDeviceID='Dev1';
    aoValveChannel = 'ao0';
    dioID='Dev1';
    dioCh=1;
    dioPort=0;
%     valveChanInd = aoValveChannel+1;
%     optiStimChanInd = aoValveChannel+2;
else
    ScanImageIP='1.1.1.1';
    TimelineIP='1.1.1.1';
    IntrinsicCameraIP='1.1.1.1';
    EyeCameraIP='1.1.1.1';
    daqVendorName = 'ni'; % this name is used for 64-bit interface
    aoDeviceID='Dev1';
    aoValveChannel = 'ao0';  
    dioDeviceID='Dev1';
    dioCh=1;
    dioPort=0;
    optiStimChanInd=1;
    valveChanInd=2;
end

if ~OFFLINE

    % if not in OFFLINE mode define the UDP ports
    % this port is used to listen to the ball data
    
    BallUDPPort = pnet('udpsocket', 9999);
    
    % open all the required udp ports
    % this port is used to communicate with the 2p scope
    ScanImageUDP  = pnet('udpsocket', 1001);
    pnet(ScanImageUDP, 'udpconnect', ScanImageIP, 1001);
    
    % this port is for Timeline
    TimelineUDP  = pnet('udpsocket', 1001);
    pnet(TimelineUDP, 'udpconnect', TimelineIP, 1001);

    % this port is for eye-tracking camera
    EyeCameraUDP  = pnet('udpsocket', 1001);
    pnet(EyeCameraUDP, 'udpconnect', EyeCameraIP, 1001);

    % this port is for optical stimulation set up
    OptiStimUDP  = pnet('udpsocket', 1001);
    pnet(OptiStimUDP, 'udpconnect', OptiStimIP, 1002);

end

% initialize DAQ-----------------------------------------------------------
if ~OFFLINE
    
    daqSession = daq.createSession(daqVendorName);
    daqSession.Rate = 10e3;
    % defining the Analog Output object for the valve (for precise timing)
    daqSession.addAnalogOutputChannel(aoDeviceID, aoValveChannel, 'Voltage');
    daqSession.outputSingleScan(valveClosedVoltage);
end

% prepare screen-----------------------------------------------------------

% AA: implement calibration and initialization of the screen

fprintf('preparing the screen\n');
[MYSCREEN, SYNC] = prepareScreen; 
%Screen('BlendFunction', MYSCREEN.windowPtr, GL.SRC_ALPHA, GL.ONE);
HideCursor; % usually done in ltScreenInitialize

%
%=========================================================================%
%                                   main loop                             %
%=========================================================================%
fhandle = @sessionStart;

while ~isempty(fhandle) % main loop, active during experiment
    
    fhandle = feval(fhandle);
    
end

% clearing all the global variables, can cause problems if not done
clear global;

end
