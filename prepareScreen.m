function [myscreen, syncSquare] = prepareScreen(whichScreen)
% initializes screen: ltScreenInitialize [Screen('OpenWindow',...)]
% loads calibration: ltLoadCalibration
% asks for screen distance

global OFFLINE;
global EXP

try
    if nargin<1
        myscreen = initializeScreen;
    else
        myscreen = initializeScreen(whichScreen); % will override the default from RigInfoGet
    end
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    return
end

% when monitor is calibrated
% load new gamma table, which linearizes monitor luminance
if ~OFFLINE %|| OFFLINE
    ltLoadCalibration(myscreen);
end

% define synchronization square read by photodiode
syncSquare = struct('rect', [], 'colorOn', [1 1 1], 'colorOff', [0 0 0]);
if isfield(myscreen.SyncSquare, 'Position')
    syncPosition = myscreen.SyncSquare.Position;
else
    syncPosition = 'SouthEast'; % default position bottom right corner
end

switch syncPosition
    case 'SouthEast'  % bottom right
        syncSquare.rect = [myscreen.Xmax-EXP.syncSquareSizeX+1, myscreen.Ymax-EXP.syncSquareSizeY+1, myscreen.Xmax, myscreen.Ymax];
    case 'SouthWest'  % bottom left
        syncSquare.rect = [0, myscreen.Ymax-EXP.syncSquareSizeY+1, EXP.syncSquareSizeX-1, myscreen.Ymax];
    otherwise
        warning('Unrecognized position for the Sync square, putting it at SouthEast');
        syncSquare.rect = [myscreen.Xmax-EXP.syncSquareSizeX+1, myscreen.Ymax-EXP.syncSquareSizeY+1, myscreen.Xmax, myscreen.Ymax];
end

fprintf('done\n');