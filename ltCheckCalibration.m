% Script that checks calibration to ensure linearity 
%
% 2001-03 MC
% 2006-11 JBB upgraded to Windows PTB 3.x
% 2007-12 LB replaced whichScreen = 1 by whichScreen=max(screens) (line 8&9)

screens=Screen('Screens');
whichScreen = max(screens);
% whichScreen = 1;

scr = ltScreenInitialize(whichScreen);
ltLoadCalibration(scr);

% choose step value (something that goes into 256 evenly)
stepsize=32; %usually 16;
steps=[0,stepsize-1:stepsize:255];
nsteps = length(steps);
	
fprintf('Check for Linearity, please type in the readings from the photometer.\n');

testColor = [0 0 0];
Screen('FillRect', scr.windowPtr, testColor); Screen('Flip', scr.windowPtr);

MeasuredValues = repmat(NaN, 1, nsteps);
for istep = 1:nsteps
	testColor = repmat(steps(istep), 1, 3);
	Screen('FillRect', scr.windowPtr, testColor); Screen('Flip', scr.windowPtr);
	MeasuredValues(istep) = input(sprintf('value %d/%d = ', istep, nsteps));
end

fprintf('All done.');

Screen('CloseAll');

%% Graphics

figure;
plot(steps,MeasuredValues,'ko')
Y1 = interp1(steps,MeasuredValues,0:255,'linear');
hold on;
plot(0:255,Y1,'k-');
set(gca,'XLim',[0 255])
xlabel('gun values')
ylabel('measured grayscale luminance')
title('Linearity check')
