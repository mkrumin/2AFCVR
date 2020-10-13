% Script for Data Club on March 23 2020

clear TM EXP

% select which animal and what dates to include in the analysis

% animalName = 'MK040';
% dates = datenum('2020-03-17'):datenum('2020-07-04');
% excludeDates = datenum('2020-03-12');
% animalName = 'MK041';
% dates = datenum('2020-03-06'):datenum('2020-07-04');
% excludeDates = datenum('2020-03-12');
% animalName = 'MK042';
% dates = datenum('2020-03-17'):datenum('2020-07-04');
% excludeDates = datenum('2020-03-12');
% animalName = 'MK043';
% dates = datenum('2020-03-06'):datenum('2020-07-04');
% excludeDates = datenum('2020-03-11');

animalName = 'MK044';
dates = datenum('2020-06-05'):datenum('2020-07-04');
excludeDates = datenum('2020-03-11');

dates = setdiff(dates, excludeDates);
[allExpRefs, allDateNums, iExp] = dat.listExps(animalName);
[validDates, expIdx] = ismember(allDateNums, dates);
validDates = allDateNums(validDates);
expIdx = find(expIdx);
nExps = length(expIdx);
nRows = floor(sqrt(nExps));
nColumns = ceil(nExps/nRows);
figure;
for iExp = 1:nExps
    TM(iExp) = TMaze(allExpRefs{expIdx(iExp)});
    try
        TM(iExp).getPCData;
%         TM(iExp).fitPC;
        TM(iExp).showPC(subplot(nRows, nColumns, iExp));
    end
    EXP(iExp) = TM(iExp).EXP;
end

% let's see what parameters had changed between the different experiments
% then decide if we really want to merge these experiments together
activeFieldNames = structCompare(EXP);
printTable(EXP, activeFieldNames);

% merge all the sessions
for iExp = 2:nExps
    TM(1) = TM(1).Merge(TM(iExp));
end
TM = TM(1);
% ExpRef = '2020-03-17_1724_MK041';
% TM = TMaze(ExpRef);
TM.getPCData;
% TM.fitPC;
axH = TM.showPC;
% TM.isHaptic = ~TM.isHaptic;
% TM.getPCData;
% TM.showPC(axH, 'm');
% TM.isHaptic = ~TM.isHaptic;
% 
% TM.isVisual = ~TM.isVisual;
% TM.getPCData;
% axH = TM.showPC;
% TM.isHaptic = ~TM.isHaptic;
% TM.getPCData;
% TM.showPC(axH, 'm');
% TM.isHaptic = ~TM.isHaptic;
% TM.isVisual = ~TM.isVisual;
% 
% nSessions = numel(unique(validDates))

%% Extract all the data into an easy to work with format

TM.getVectors;


%% Comparison of Path lengths for different conditions

idx = ismember(TM.report, 'LR')';
idx = idx & TM.isRandom;
idx = idx & TM.isVisual;
idxHaptic = find(idx & TM.isHaptic);
idxNonHaptic = find(idx & ~TM.isHaptic);

nTrialsHaptic = numel(idxHaptic);
pathLenHaptic = zeros(nTrialsHaptic, 1);
for iTrial = 1:nTrialsHaptic
    data = TM.trialData(idxHaptic(iTrial)).mouse;
    pathLenHaptic(iTrial) = sum(sqrt((diff(data.x)).^2 + (diff(data.z)).^2));
end

nTrialsNonHaptic = numel(idxNonHaptic);
pathLenNonHaptic = zeros(nTrialsNonHaptic, 1);
for iTrial = 1:nTrialsNonHaptic
    data = TM.trialData(idxNonHaptic(iTrial)).mouse;
    pathLenNonHaptic(iTrial) = sum(sqrt((diff(data.x)).^2 + (diff(data.z)).^2));
end

prc = prctile([pathLenHaptic; pathLenNonHaptic], [0.01, 99]);
edges = linspace(prc(1), prc(2), 50);
figure;
histogram(pathLenHaptic, edges, 'Normalization', 'pdf');
hold on;
histogram(pathLenNonHaptic, edges, 'Normalization', 'pdf');
legend('Haptic ON', 'Haptic OFF');
title(animalName)
xlabel('Path Length [cm]');
ylabel('Probability Density');
axis tight

% comparison of finalZ positions (@ endOfTrial)

idx = ismember(TM.report, 'LR')';
idx = idx & TM.isRandom;
idx = idx & TM.isVisual;
idxHaptic = find(idx & TM.isHaptic);
idxNonHaptic = find(idx & ~TM.isHaptic);

nTrialsHaptic = numel(idxHaptic);
finalZHaptic = zeros(nTrialsHaptic, 1);
for iTrial = 1:nTrialsHaptic
%     data = TM.trialData(idxHaptic(iTrial)).mouse;
    finalZHaptic(iTrial) = max(TM.trialData(idxHaptic(iTrial)).vr.z);
end

nTrialsNonHaptic = numel(idxNonHaptic);
finalZNonHaptic = zeros(nTrialsNonHaptic, 1);
for iTrial = 1:nTrialsNonHaptic
%     data = TM.trialData(idxNonHaptic(iTrial)).mouse;
    finalZNonHaptic(iTrial) = max(TM.trialData(idxNonHaptic(iTrial)).vr.z);
end

prc = prctile([finalZHaptic; finalZNonHaptic], [0.01, 99.99]);
edges = linspace(prc(1), prc(2), 30);
figure;
histogram(finalZHaptic, edges, 'Normalization', 'pdf');
hold on;
histogram(finalZNonHaptic, edges, 'Normalization', 'pdf');
legend('Haptic ON', 'Haptic OFF');
title(animalName)
xlabel('Z @ endOfTrial [cm]');
ylabel('Probability Density');
axis tight

%% Estimating mouse responces to wall contact

tauAxis = -3:0.1:5;
idxHaptic = TM.isHaptic & TM.isVisual & TM.isRandom;
idxNonHaptic = ~TM.isHaptic & TM.isVisual & TM.isRandom;

lwEventTimes = getEventTimes(TM, 'LeftWallContact');
lwHaptic = lwEventTimes;
lwHaptic(~idxHaptic) = {[]};
lwNonHaptic = lwEventTimes;
lwNonHaptic(~idxNonHaptic) = {[]};

etaLwHaptic = getETA(TM, lwHaptic, [], tauAxis);
etaLwNonHaptic = getETA(TM, lwNonHaptic, [], tauAxis);

rwEventTimes = getEventTimes(TM, 'RightWallContact');
rwHaptic = rwEventTimes;
rwHaptic(~idxHaptic) = {[]};
rwNonHaptic = rwEventTimes;
rwNonHaptic(~idxNonHaptic) = {[]};

etaRwHaptic = getETA(TM, rwHaptic, [], tauAxis);
etaRwNonHaptic = getETA(TM, rwNonHaptic, [], tauAxis);

figure;
set(gcf, 'Position', [100 230 900 760])

ax1 = subplot(2, 2, 1);
plot(tauAxis, etaLwNonHaptic.mean, 'k', 'LineWidth', 3);
hold on;
plot(tauAxis, etaLwHaptic.mean, 'm',  'LineWidth', 3);

plot(tauAxis, etaLwNonHaptic.mean + etaLwNonHaptic.sem, 'k--', 'LineWidth', 1);
plot(tauAxis, etaLwNonHaptic.mean - etaLwNonHaptic.sem, 'k--', 'LineWidth', 1);

plot(tauAxis, etaLwHaptic.mean + etaLwHaptic.sem, 'm--', 'LineWidth', 1);
plot(tauAxis, etaLwHaptic.mean - etaLwHaptic.sem, 'm--', 'LineWidth', 1);

xlim(tauAxis([1, end]))

title('Left Wall Contact');
ylabel('dYaw/dt [deg/sec]');
% xlabel('\tau [sec]');
ax1.XTickLabel = [];
set(gca, 'FontSize', 14)
% axis square
box off

ax2 = subplot(2, 2, 2);
plot(tauAxis, etaRwNonHaptic.mean, 'k', 'LineWidth', 3);
hold on;
plot(tauAxis, etaRwHaptic.mean, 'm',  'LineWidth', 3);

plot(tauAxis, etaRwNonHaptic.mean + etaRwNonHaptic.sem, 'k--', 'LineWidth', 1);
plot(tauAxis, etaRwNonHaptic.mean - etaRwNonHaptic.sem, 'k--', 'LineWidth', 1);

plot(tauAxis, etaRwHaptic.mean + etaRwHaptic.sem, 'm--', 'LineWidth', 1);
plot(tauAxis, etaRwHaptic.mean - etaRwHaptic.sem, 'm--', 'LineWidth', 1);

% legend('Haptic OFF', 'Haptic ON');
title('Right Wall Contact');
% ylabel('dYaw/dt [deg/sec]');
% xlabel('\tau [sec]');
ax2.YTickLabel = [];
ax2.XTickLabel = [];
xlim(tauAxis([1, end]))

% axis square
box off
set(gca, 'FontSize', 14)

idxHaptic = TM.isHaptic & ~TM.isVisual & TM.isRandom;
idxNonHaptic = ~TM.isHaptic & ~TM.isVisual & TM.isRandom;

lwEventTimes = getEventTimes(TM, 'LeftWallContact');
lwHaptic = lwEventTimes;
lwHaptic(~idxHaptic) = {[]};
lwNonHaptic = lwEventTimes;
lwNonHaptic(~idxNonHaptic) = {[]};

etaLwHaptic = getETA(TM, lwHaptic, [], tauAxis);
etaLwNonHaptic = getETA(TM, lwNonHaptic, [], tauAxis);

rwEventTimes = getEventTimes(TM, 'RightWallContact');
rwHaptic = rwEventTimes;
rwHaptic(~idxHaptic) = {[]};
rwNonHaptic = rwEventTimes;
rwNonHaptic(~idxNonHaptic) = {[]};

etaRwHaptic = getETA(TM, rwHaptic, [], tauAxis);
etaRwNonHaptic = getETA(TM, rwNonHaptic, [], tauAxis);

ax3 = subplot(2, 2, 3);
plot(tauAxis, etaLwNonHaptic.mean, 'k', 'LineWidth', 3);
hold on;
plot(tauAxis, etaLwHaptic.mean, 'm',  'LineWidth', 3);

plot(tauAxis, etaLwNonHaptic.mean + etaLwNonHaptic.sem, 'k--', 'LineWidth', 1);
plot(tauAxis, etaLwNonHaptic.mean - etaLwNonHaptic.sem, 'k--', 'LineWidth', 1);

plot(tauAxis, etaLwHaptic.mean + etaLwHaptic.sem, 'm--', 'LineWidth', 1);
plot(tauAxis, etaLwHaptic.mean - etaLwHaptic.sem, 'm--', 'LineWidth', 1);

xlim(tauAxis([1, end]))

% title('Left Wall Contact');
ylabel('dYaw/dt [deg/sec]');
xlabel('\tau [sec]');
set(gca, 'FontSize', 14)
% axis square
box off

ax4 = subplot(2, 2, 4);
plot(tauAxis, etaRwNonHaptic.mean, 'k', 'LineWidth', 3);
hold on;
plot(tauAxis, etaRwHaptic.mean, 'm',  'LineWidth', 3);

plot(tauAxis, etaRwNonHaptic.mean + etaRwNonHaptic.sem, 'k--', 'LineWidth', 1);
plot(tauAxis, etaRwNonHaptic.mean - etaRwNonHaptic.sem, 'k--', 'LineWidth', 1);

plot(tauAxis, etaRwHaptic.mean + etaRwHaptic.sem, 'm--', 'LineWidth', 1);
plot(tauAxis, etaRwHaptic.mean - etaRwHaptic.sem, 'm--', 'LineWidth', 1);

% legend('Haptic OFF', 'Haptic ON');
% title('Right Wall Contact');
% ylabel('dYaw/dt [deg/sec]');
xlabel('\tau [sec]');
ax4.YTickLabel = [];
xlim(tauAxis([1, end]))

% axis square
box off
set(gca, 'FontSize', 14)


linkaxes([ax1, ax2, ax3, ax4], 'y')

plot(ax1, xlim, [0 0], 'k:');
plot(ax1, [0 0], ylim, 'k:');
plot(ax2, xlim, [0 0], 'k:');
plot(ax2, [0 0], ylim, 'k:');
plot(ax3, xlim, [0 0], 'k:');
plot(ax3, [0 0], ylim, 'k:');
plot(ax4, xlim, [0 0], 'k:');
plot(ax4, [0 0], ylim, 'k:');

legH = legend(ax1, 'Haptic OFF', 'Haptic ON');
legH.Box = 'off';
legH.Location = 'NorthWest';

sgtitle(animalName, 'FontSize', 20, 'FontWeight', 'Bold')

%% plot x and theta distributions for different conditions

plotXThDistributions(TM);

%% let's see some trajectories (closed- and open-loop)
% some extra settings/parameters inside the function

plotSampleTrajectories(TM);

%% plot distributions of derivatives of the heading angle (Theta)

plotDThetaDistributions(TM);

