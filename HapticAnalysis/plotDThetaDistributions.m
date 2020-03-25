function plotDThetaDistributions(TM)

idxWalls = TM.SESSION.useWhiskerControl(1:TM.nTrials);
idxVis = TM.SESSION.showWalls(1:TM.nTrials);
fullTrials = find(idxWalls & idxVis);
visTrials = find(~idxWalls & idxVis);
wallsTrials = find(idxWalls & ~idxVis);
blankTrials = find(~idxWalls & ~idxVis);

% let's create some shorter names for variables
tmpVR = ([TM.trialData.vr]');
tmpMeta = ([TM.trialData.meta]');
tmpMouse = ([TM.trialData.mouse]');

hFig = figure;
hFig.Color = [1 1 1];
fontSize = 12;

% do the four plots on four separate subplots
ax1 = subplot(2, 2, 1);
plotDistributions(ax1, fullTrials)

ax2 = subplot(2, 2, 2);
plotDistributions(ax2, wallsTrials)

ax3 = subplot(2, 2, 3);
plotDistributions(ax3, visTrials)

ax4 = subplot(2, 2, 4);
plotDistributions(ax4, blankTrials)

% add some labels/titles/legends
hLegend = legend(ax1, 'Left Wall Contact', 'Right Wall Contact', ...
    'Box', 'off', 'Location', 'Northwest');
title(ax1, 'VIS ON')
ylabel(ax1, 'Whiskers ON', 'FontSize', fontSize);
title(ax2, 'VIS OFF');
ylabel(ax3, 'Whiskers OFF', 'FontSize', fontSize);
xlabel(ax3, '\Delta\theta [deg/sec]', 'FontSize', fontSize);
xlabel(ax4, '\Delta\theta [deg/sec]', 'FontSize', fontSize);

% make sure the x-axis is scaled the same across the four plots
linkaxes([ax1, ax2, ax3, ax4], 'x');
xlim(ax1, [-100 100]);


% this is a nested function, so it has access to the variables in the main
% function 

    function plotDistributions(hAxes, idx)

        nPoints = 30; % at approx. 30 fps this is one second
        nTrials = length(idx);
        dThetaLeft = [];
        dThetaRight = [];
        for iTrial = 1:nTrials
            cl = cell2mat({tmpMeta(idx(iTrial)).closedLoop}');
            xx = cell2mat({tmpMouse(idx(iTrial)).x}');
            theta = cell2mat({tmpMouse(idx(iTrial)).theta}');
            vrX = cell2mat({tmpVR(idx(iTrial)).x}');
            vrZ = cell2mat({tmpVR(idx(iTrial)).z}');
            nSamples = length(cl); % total number of samples in this trial
            % only use times when touching the left wall and in the main corridor
            leftWallIdx = find((vrX == -5) & (vrZ < 85));
            % avoid some potential errors towards the end of the trial
            leftWallIdx = leftWallIdx(leftWallIdx < nSamples - nPoints); 
            % only use times when touching the right wall and in the main corridor
            rightWallIdx = find((vrX == 5) & (vrZ < 85));
            % avoid some potential errors towards the end of the trial
            rightWallIdx = rightWallIdx(rightWallIdx < nSamples - nPoints);
            
            dThetaLeft = cat(1, dThetaLeft, theta(leftWallIdx + nPoints) - theta(leftWallIdx));
            dThetaRight = cat(1, dThetaRight, theta(rightWallIdx + nPoints) - theta(rightWallIdx));
        end
        
        histogram(hAxes, dThetaLeft)
        hold on;
        histogram(hAxes, dThetaRight)
        box off;        
        
    end % plotDistributions()

end % the main function