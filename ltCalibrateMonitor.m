function ltCalibrateMonitor(whichScreen)% Creates a calibration file% % ltCalibrateMonitor computes an inverse gamma table which linearizes% display luminance%% ltCalibrateMonitor(display) lets you specify the display ([DEFAULT]: the% largest number, ie if you have 3 displays, it will be display 3.% % To figure out what monitor your computer uses, it calls% ltScreenInitialize. Check to be sure that your computer is known to that% function.%% see also ltScreenInitialize, ltCheckCalibration% 1999 FH & MC% 2000-03 MC cleaned it up, made it independent of zmac% 2004-09 VB commented Calibration.typed_check% 2006-11 JBB upgraded to Windows PTB 3.x% 2007-12 LB inserted the creation of Calibration directory in case it does%               not exist% 2008-01 MC+LB streamlined the code% 2009-09 MC added suggested value (useful when doing a fake calibration)% 2010-01 MC turned it into a function% 2010-03 MC allowed hitting return for lazy people who are doing a fakeif nargin<1    screens=Screen('Screens');    whichScreen=max(screens);end    % whichScreen = 1;%% Measure Gamma -----------------------------------------% choose step value (something that goes into 256 evenly)stepsize = 32; % usually 16; %32;steps = [0, stepsize-1:stepsize:255];nsteps = length(steps);guns = {'red', 'green', 'blue'};try	scr = ltScreenInitialize(whichScreen);% 	scr = initializeScreen(whichScreen);	numEntries = 2^scr.PixelDepth;	typed = zeros(3, nsteps);	for igun = 1:3 % 1,2,3 for r,g,b		for istep = 1:nsteps			testColor = [0 0 0];			testColor(igun) = steps(istep);			Screen('FillRect', scr.windowPtr, testColor);             Screen('Flip', scr.windowPtr);			str = sprintf('Gun %i/3 (%s) Step %i/%i [%d]. value = ', ...                igun, guns{igun}, istep, nsteps, steps(istep) );            TheAnswer = input(str);            if isempty(TheAnswer), TheAnswer = steps(istep) ; end 			typed(igun, istep) = TheAnswer;		end	end	% Close the screen	Screen(scr.windowPtr, 'Close'); catch	Screen('CloseAll');	err = psychlasterror;	disp(err.stack);end% save typed typed%% massage the datar = typed(1,:);g = typed(2,:);b = typed(3,:);% Normalize to the max **and min** for r g and b (JBB and MC 2006-11)r = (r - min(r)) / (max(r) - min(r));g = (g - min(g)) / (max(g) - min(g));b = (b - min(b)) / (max(b) - min(b));% Set up matrix to hold interpolated Gamma tablemonitorGam=zeros(256,3);monitorGam(:,1)=interp1(steps,r,0:255)';monitorGam(:,2)=interp1(steps,g,0:255)';monitorGam(:,3)=interp1(steps,b,0:255)';%% calculate inverse gamma tablenguns = size(monitorGam,2);monitorGamInv = zeros(numEntries,nguns);%  Check for monotonicity, and fix if not monotone%for igun=1:nguns		thisTable = monitorGam(:,igun);		% Find the locations where this table is not monotonic	%	list = find(diff(thisTable) <= 0, 1);		if ~isempty(list)		announce = sprintf('Gamma table %d NOT MONOTONIC.  We are adjusting.',igun);		disp(announce)				% We assume that the non-monotonic points only differ due to noise		% and so we can resort them without any consequences		%		thisTable = sort(thisTable);				% Find the sorted locations that are actually increasing.		% In a sequence of [ 1 1 2 ] the diff operation returns the location 2		%		% posLocs is positions of values with positive derivative		posLocs = find(diff(thisTable) > 0);				% We now shift these up and add in the first location		%		posLocs = [1; (posLocs + 1)];		% monTable is values in original vector with positive derivatives		monTable = thisTable(posLocs,:);			else		% If we were monotonic, then yea!		monTable = thisTable;		posLocs = 1:size(thisTable,1);	end	nrow = size(monTable,1);		% Interpolate the monotone table out to the proper size	% 092697 jbd added a ' before the ;	monitorGamInv(:,igun) = ...	interp1(monTable,posLocs-1,(0:(numEntries-1))/(numEntries-1))'; 	endif any(isnan(monitorGamInv)),	msgbox('Warning: NaNs in inverse gamma table -- may need to recalibrate.');end%% Plot datafigure; clfsubplot(1,2,1)plot(steps,r,'ro')hold onplot(steps,g,'go')plot(steps,b,'bo')% plot interpolated functions plot(0:255,monitorGam(:,1),'r')plot(0:255,monitorGam(:,2),'g')plot(0:255,monitorGam(:,3),'b')hold offset(gca,'XLim',[0 255])set(gca,'YLim',[0 1])xlabel('gun values')ylabel('normalized luminance')title('Data and fits')% plot inverse gamma table --------------------------------------subplot(1,2,2)plot(0:255,monitorGamInv(:,2),'g')hold onplot(0:255,monitorGamInv(:,1),'r')plot(0:255,monitorGamInv(:,3),'b')hold offset(gca,'XLim',[0 255])set(gca,'YLim',[0 255])xlabel('Desired relative output')ylabel('Required relative voltage')title('Inverse gamma')%% buuild the calibration structuretoday = datestr(now);today = today(1:11);Calibration.date        = today;Calibration.ScreenInfo  = scr;Calibration.typed       = typed;Calibration.monitorGam  = monitorGam;Calibration.monitorGamInv = monitorGamInv;%% save the calibration structurefilename = [scr.MonitorType , '_', today , '.mat'];filename(findstr(filename,' ')) = '_';filePathname = fullfile(scr.CalibrationDir, filename);if ~exist(scr.CalibrationDir, 'dir')    mkdir(scr.CalibrationDir);endif ~exist(filePathname, 'file'),	save(filePathname, 'Calibration');else 	prompt = sprintf('Filename %s exists already, please give different name or confirm', filename);	answer = inputdlg(prompt, '', 1, {filename});	if isempty(answer),		fprintf('Calibration cancelled!  Data stored in workspace variable "Calibration".\n');	else		filePathname = fullfile(scr.CalibrationDir, answer{1});		save(filePathname, 'Calibration');	endend