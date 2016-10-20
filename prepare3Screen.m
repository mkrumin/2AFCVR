function myscreen = prepare3Screen(whichScreen)
% initializes screen: ltScreenInitialize [Screen('OpenWindow',...)]
% loads calibration: ltLoadCalibration
% asks for screen distance 
global OFFLINE;

try
	myscreen = initialize3Screen(whichScreen);
catch
	Screen('CloseAll');
	psychrethrow(psychlasterror);
	return
end

% when monitor is calibrated
% load new gamma table, which linearizes monitor luminance
if ~OFFLINE
    loadCalibration(myscreen);
end
% screen distance
myscreen.Dist = 15;
Dist = input('---------------> Screen distance in cm [15] : ');
if ~isnumeric(Dist) || isempty(Dist)
    fprintf('<prepareScreen> Using default screen distance\n');
else
    myscreen.Dist = Dist;
end
fprintf('done\n');