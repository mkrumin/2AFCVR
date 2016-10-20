function Exp = setExperimentPars

%% frequently changed parameters go here
smallRewardValveTime = 0.04; % should be calibrated to give ~2ul reward
largeRewardValveTime = 0.05; % should be calibrated to give ~4ul reward
rewardDistance = 550;%48; % give intermediate rewards every 'rewardDistance' cm of travel
stimType = 'BAITED'; % 'BAITED', 'RANDOM', 'ALTERNATING', 'BOTH', 'REPLAY', 'INTERLIEVED', 'REPLAY_SCRAMBLED' 
contrasts = [0 6 12 25 50]; % contrast levels of the gratings [0 6 12 25 50]
aGain = -0.2;   % gain of rotation angle
restrict = 1; % 1 if we want to restrict the range of the head direction. 
% if set to be less than pi/2 it will not allow the animal to FAIL the task
restrictAngle = pi/6; % pi/4=+-45 degrees, pi/6 = +-30 degrees
fadeInFrames = 15;

%% definition of the whole structure
Exp = struct('date', date,...                   %date of the experiment
             'maxNTrials', 500,...              %max number of trials within a session
             'maxTrialDuration', 45,...         % max trial duration in secs
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
             'smallRewardTime', smallRewardValveTime,...         % should be calibrated to give ~2ul reward
             'largeRewardTime', largeRewardValveTime,...         % should be calibrated to give ~4ul reward
             'rewardDistance', rewardDistance,...          % give intermediate rewards every 'rewardDistance' cm of travel
... visual stimulus sequence related parameters
             'stimType', stimType, ...          % 'RANDOM', 'ALTERNATING', 'BOTH', 'REPLAY', 'INTERLIEVED'
             'replayMode', 'ALL', ...           % 'ALL', 'notTIMEOUT'
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
             'optiStim', 0, ...                 % No of (blue) LEDs to incorporate for light stimulation (0 for none)
             'optiStimContrasts', [0 6 50], ...   % for which contrasts to apply LED/laser stimulation
             'optiStimType', 'TIME', ...        % 'TRIAL', 'TIME', to be implemented also: 'FRAME', 'EVENT'
             'optiStimOnsetTime', -0.5, ...     % the onset time of the optiStim, relative to the onset of the visual stimulus
             'optiStimDuration', 5, ...         % the duration of the optical stimulation
             'optiStimShape', 'PULSES', ...     % 'STEP', 'RAMP', 'PULSES'
             'optiStimPulseDur', 20, ...        % a single pulse duration (in ms)
             'optiStimPulseFreq', 10, ...       % frequency of pulses
             'optiStimPulseShape', 'SQUARE', ... % 'SQUARE', 'RAMP', 'SINE' (for half-sine)
             'optiStimSequence', 'PSEUDORANDOM', ...  % 'ON', 'RANDOM', 'PSEUDORANDOM', not implemented yet 'ALTERNATING', 'PSEUDOALTERNATING'
             'optiStimIntensities', [0.45], ...    % relative max intensities to roll through randomly(?)
             'optiStimIntensities2', [0.8], ...    % relative max intensities to roll through randomly(?) for LED2
             'optiStimLutFile', 'optiStimLut', ... % file where the LUT is saved
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
         
   
         
