function plotSampleTrajectories(TM)

% a couple of flags what to do
pauseEveryTrial = true; % if 'true' press spacebar to continue plotting trials one by one
clearPlotEveryTrial = true;

nTrials = TM.nTrials;

% get indices of trials of different conditions
idxWalls = TM.SESSION.useWhiskerControl(1:nTrials);
idxVis = TM.SESSION.showWalls(1:nTrials);
fullTrials = find(idxWalls & idxVis);
visTrials = find(~idxWalls & idxVis);
wallsTrials = find(idxWalls & ~idxVis);
blankTrials = find(~idxWalls & ~idxVis);

% choose which trials to plot
validTrials = fullTrials;

% open a figure and start plotting trial by trial
% (is getting a bit slow for large number of trials, but we are not after
% speed here, just inspecting the data)
hF = figure;
hF.Color = [1 1 1];
for i = 1:length(validTrials)
    
    iTrial = validTrials(i);
    tr = TM.trialData(iTrial);
    ax1 = subplot(1, 2, 1);
    if clearPlotEveryTrial
        cla;
    end
    plot(tr.vr.theta, tr.vr.z, 'b', 'LineWidth', 2);
    hold on;
    xlabel('\theta [deg]');
    ylabel('z [cm]');
    grid on;
    %         axis equal
    ax2 = subplot(1, 2, 2);
    if clearPlotEveryTrial
        cla;
    end
    plot(tr.vr.x, tr.vr.z, 'b', 'LineWidth', 2);
    hold on;
    xlabel('x [cm]');
    grid on;
    %         axis equal
    if pauseEveryTrial
        pause;
    end
    plot(ax1, tr.mouse.theta, tr.mouse.z, 'r--', 'LineWidth', 2);
    plot(ax2, tr.mouse.x, tr.mouse.z, 'r--', 'LineWidth', 2);
    axis tight
    %         ylim([0 100]);
    % make sure the axis z limits are the same for both plots
    linkaxes([ax1, ax2], 'y')
    if pauseEveryTrial
        pause;
    end
end
