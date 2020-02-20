function Exp = loadJL037()


%% frequently changed parameters go here
smallRewardAmount = 0.002;
largeRewardAmount = 0.002;
timeOut = 60; % [sec] trial times out after this number of seconds
smallRewardValveTime = getValveTime(smallRewardAmount); % should be calibrated to give ~2ul reward; set by MK 2017
largeRewardValveTime = getValveTime(largeRewardAmount); % should be calibrated to give ~4ul reward; set by MK 2017
rewardDistance = Inf;%48; % give intermediate rewards every 'rewardDistance' cm of travel

stimType = 'BAITED'; % 'BAITED', 'RANDOM', 'ALTERNATING', 'BOTH', 'REPLAY', 'INTERLIEVED', 'REPLAY_SCRAMBLED' 
contrasts = [0 6 12 25 50]; % contrast levels of the gratings [0 6 12 25 50]
aGain = -0.1;   % gain of rotation angle
restrict = 1; % 1 if we want to restrict the range of the head direction. 
% if set to be less than pi/2 it will not allow the animal to FAIL the task
restrictAngle = pi/6; % pi/4=+-45 degrees, pi/6 = +-30 degrees
fadeInFrames = 15;

optiStim = 0;
if optiStim
    listOfPoints = getOptiStimList;
else
    listOfPoints = [];
end
%% definition of the whole structure
Exp = struct('date', date,...                   %date of the experiment
             'maxNTrials', 500,...              %max number of trials within a session
             'maxTrialDuration', timeOut,...         % max trial duration in secs
             'timeOutSoundDuration', 3, ...     % time out sound duration
             'restrictInRoom', 1,...
             'minWallsDistance', 5,...          % minimum allowed distance to the walls
             'restrictDirection', restrict,...         % whether to restrict the animal's head direction
             'restrictionAngle', restrictAngle,...       % pi/4 means +-45 degrees from heading forward
             'grayScreenDur', 2.0,...           % STOP time (the duration of the gray screen)
 ... imaging related parameters
             'syncSquareSizeY', 100,...          % Y size of synchroniztation square read by photodiode
             'syncSquareSizeX', 400,...          % X size of synchroniztation square read by photodiode
             'flipSides', 0, ...                % whether to flip right and left sides (useful for undistortion)
             'doUndistortion', 1, ...           % whether to apply semicylindrical undistortion
 ... reward related parameters
             'maxNRewards', 2,...               % max number of rewards on a single base
             'rewardGap', 0.7, ...              % time in between two rewards on a single base
             'rewardDelay', 0.7, ...            % delay for the first reward
             'smallRewardAmount', smallRewardAmount,...
             'largeRewardAmount', largeRewardAmount ,...
             'smallRewardTime', smallRewardValveTime,...         % should be calibrated to give ~2ul reward
             'largeRewardTime', largeRewardValveTime,...         % should be calibrated to give ~4ul reward
             'rewardDistance', rewardDistance,...          % give intermediate rewards every 'rewardDistance' cm of travel
... visual stimulus sequence related parameters
             'stimType', stimType, ...          % 'RANDOM', 'ALTERNATING', 'BOTH', 'REPLAY', 'INTERLIEVED'
             'replayMode', 'notTIMEOUT', ...           % 'ALL', 'notTIMEOUT'
             'replaySnippetDuration', 30, ...   % duration of a single snippet (in frames) for 'REPLAY_SCRAMBLED'
             'probRight', 0.5, ...              % probability of the stimulus to be on the right (affects 'RANDOM' & 'INTERLIEVED' only)
             'contrasts', contrasts, ...        % contrast levels of the gratings [0 6 12 25 50]
             'noiseContrast', 20, ...
             'floorContrast', 40, ...
             'sfMultiplier', 14, ...            % spatial frequency multiplier (cycles per patch)
             'texturePatchSize', 256, ...       % size of a single texture patch
             'freezeDuration', 0.2, ...         % for how long to show the first frame of the maze before allowing to move
             'fadeInFrames', fadeInFrames, ...
... optical stimulation related parameters
             'optiStim', optiStim, ...                 % Do we do inactivation/stimulation?
             'optiStimList', listOfPoints, ...  % a structure with the list of stimulation locations 
... room related parameters 
             'mazeType', 'TMaze', ...
             'roomWidth', 20*3, ...
             'roomHeight', 10, ...
             'roomLength', 110, ...
             'corridorWidth', 20, ...
             'roomType', '', ...                % options:  NOWALLS, default withwalls 
             'zGain',-1,...                     % gain in the direction into(or out of) the room
             'xGain',-1*0,...                     % gain of sideway movement
             'aGain', aGain,...                   % gain of rotation angle
... texture related
             'textureFile', 'textures',...      % WHITENOISE, COSGRATING, GRAY      
             'leftWallText','WHITENOISE',...
             'rightWallText','WHITENOISE',...
             'floorText','WHITENOISE',...
             'farWallText','WHITENOISE',...
             'ceilingText','WHITENOISE',...
             'nearWallText','WHITENOISE');            
         
   
         
