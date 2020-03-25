function plotXThDistributions(TM)

nTrials = TM.nTrials;

idxWalls = TM.SESSION.useWhiskerControl(1:nTrials);
idxVis = TM.SESSION.showWalls(1:nTrials);
fullTrials = find(idxWalls & idxVis);
visTrials = find(~idxWalls & idxVis);
wallsTrials = find(idxWalls & ~idxVis);
blankTrials = find(~idxWalls & ~idxVis);

% let's plot some basic histograms

tmpVR = ([TM.trialData.vr]');
tmpMeta = ([TM.trialData.meta]');
tmpMouse = ([TM.trialData.mouse]');

allVrX = cell2mat({tmpVR.x}');
allVrZ = cell2mat({tmpVR.z}');
allVrTheta = cell2mat({tmpVR.theta}');
allCL = cell2mat({tmpMeta.closedLoop}');
allMouseX = cell2mat({tmpMouse.x}');
allMouseZ = cell2mat({tmpMouse.z}');
allMouseTheta = cell2mat({tmpMouse.theta}');

xThresh = 1;
zThresh = 85;
validIdx = (abs(allVrX) > xThresh) & (allVrZ < zThresh);
xLims = prctile(allMouseX(allCL & validIdx), [1 99]);
% xLims = prctile(allMouseX(allCL), [1 99]);
thLims = prctile(allMouseTheta(allCL & validIdx), [1 99]);
%%

nBins = 100;
figure;
idx = fullTrials;
cl = cell2mat({tmpMeta(idx).closedLoop}');
xx = cell2mat({tmpMouse(idx).x}');
theta = cell2mat({tmpMouse(idx).theta}');
vrX = cell2mat({tmpVR(idx).x}');
vrZ = cell2mat({tmpVR(idx).z}');
validIdx = (abs(vrX) > xThresh) & (vrZ < zThresh);
ax1 = subplot(2, 2, 1);
histogram(xx(cl & validIdx), linspace(xLims(1), xLims(2), nBins), 'Normalization', 'cdf', 'DisplayStyle', 'stairs');
hold on;
ax3 = subplot(2, 2, 3);
histogram(theta(cl & validIdx), linspace(thLims(1), thLims(2), nBins), 'Normalization', 'cdf', 'DisplayStyle', 'stairs');
hold on;

idx = visTrials;
cl = cell2mat({tmpMeta(idx).closedLoop}');
xx = cell2mat({tmpMouse(idx).x}');
theta = cell2mat({tmpMouse(idx).theta}');
vrX = cell2mat({tmpVR(idx).x}');
vrZ = cell2mat({tmpVR(idx).z}');
validIdx = (abs(vrX) > xThresh) & (vrZ < zThresh);
axes(ax1);
histogram(xx(cl & validIdx), linspace(xLims(1), xLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');
axes(ax3);
histogram(theta(cl & validIdx), linspace(thLims(1), thLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');

idx = wallsTrials;
cl = cell2mat({tmpMeta(idx).closedLoop}');
xx = cell2mat({tmpMouse(idx).x}');
theta = cell2mat({tmpMouse(idx).theta}');
vrX = cell2mat({tmpVR(idx).x}');
vrZ = cell2mat({tmpVR(idx).z}');
validIdx = (abs(vrX) > xThresh) & (vrZ < zThresh);
ax2 = subplot(2, 2, 2);
histogram(xx(cl & validIdx), linspace(xLims(1), xLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');
hold on;
ax4 = subplot(2, 2, 4);
histogram(theta(cl & validIdx), linspace(thLims(1), thLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');
hold on;

idx = blankTrials;
cl = cell2mat({tmpMeta(idx).closedLoop}');
xx = cell2mat({tmpMouse(idx).x}');
theta = cell2mat({tmpMouse(idx).theta}');
vrX = cell2mat({tmpVR(idx).x}');
vrZ = cell2mat({tmpVR(idx).z}');
validIdx = (abs(vrX) > xThresh) & (vrZ < zThresh);
axes(ax2);
histogram(xx(cl & validIdx), linspace(xLims(1), xLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');
axes(ax4);
histogram(theta(cl & validIdx), linspace(thLims(1), thLims(2), nBins), ...
    'Normalization', 'cdf', 'DisplayStyle', 'stairs');

title(ax1, 'VIS ON')
xlabel(ax1, 'x [cm]');
xlabel(ax2, 'x [cm]');

title(ax2, 'VIS OFF')
xlabel(ax3, '\theta [deg]');
xlabel(ax4, '\theta [deg]');

linkaxes([ax1 ax2], 'xy');
linkaxes([ax3 ax4], 'xy');
xlim(ax1, xLims);
ylim(ax1, [0 1]);
xlim(ax3, thLims);
ylim(ax3, [0 1]);

plot(ax1, xlim(ax1), [0.5 0.5], 'k:');
plot(ax1, [0 0], ylim(ax1), 'k:');
plot(ax2, xlim(ax2), [0.5 0.5], 'k:');
plot(ax2, [0 0], ylim(ax1), 'k:');
plot(ax3, xlim(ax3), [0.5 0.5], 'k:');
plot(ax3, [0 0], ylim(ax1), 'k:');
plot(ax4, xlim(ax4), [0.5 0.5], 'k:');
plot(ax4, [0 0], ylim(ax1), 'k:');

legend(ax1, 'walls ON', 'walls OFF', 'Location', 'NorthWest', 'box', 'off');
