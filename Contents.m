%% Contents of MouseRoom toolbox

% MouseBallExp.m            : main program to run

%% Initializing & finalizing programs
% setExperimentPars.m       : Set the general parameters for the VR and
% deg2rad.m                 : convert deg to rad
% endOfExperiment.m         : Ends the expt by closing and clearing buffers
% getRoomData.m             : Sets up the room info
% sessionStart.m            : Sets up each session of the expt
% prepareNextTrial.m        : Starts new base

%% Screen related programs
% initialize3Screen.m       : Initialses the screens (as 3) for psychophys
% initializeScreen.m        : Initialses the screens (as 1) for psychophys
% prepareScreen.m           : -similar-
% prepare3Screen.m          : -similar-

%% Ball related
% getBallDeltas.m           : Get the movement data from the ball
% getNonBallDeltas.m        : Get the movement data from the keyboard 
% whereIsItGoing.m          :

%% Texture related
% getTextureIndex.m         : 
% wallface.m                : Assign textures to walls
% textures.mat              : Contain the textures

%% Reward/feedback related
% giveReward.m              : Give reward
% giveWater.m               : give water reward
% playSound.m               : plays a sound
% timeOut.m                 : plays white noise and add a delay period

%% Misc
% checkKeyboard.m           :
% drawbase.m                : draws the base in VR world
% trialEnd.m                :
% isOnBase.m                : check if current position is around the base
% readme.txt                : version description
% reward.m                  : 
% run.m                     : draws the room and main function
