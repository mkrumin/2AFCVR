% Script for Data Club on March 23 2020

ExpRef = '2020-03-17_1724_MK041';
TM = TMaze(ExpRef);
TM.getPCData;
TM.fitPC;
TM.showPC;

TM.getVectors;

nTrials = TM.nTrials;
idxWalls = TM.SESSION.useWhiskerControl(1:nTrials);
idxVis = TM.SESSION.showWalls(1:nTrials);
        %%
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

xLims = prctile(allMouseX(allCL), [1 99]);
thLims = prctile(allMouseTheta(allCL), [1 99]);




validTrials = wallsTrials;
figure('Name', 'Walls trials');
for i = 1:length(validTrials)
        
    iTrial = validTrials(i);
        tr = TM.trialData(iTrial);
%         figure('Name', sprintf('iTrial = %g', iTrial));
        ax1 = subplot(1, 2, 1);
        plot(tr.vr.theta, tr.vr.z, 'b', 'LineWidth', 2);
        hold on;
        plot(tr.mouse.theta, tr.mouse.z, 'r--', 'LineWidth', 2);
        xlabel('Theta [deg]');
        ylabel('z [cm]');
        grid on;
%         axis equal
        ax2 = subplot(1, 2, 2);
        plot(tr.vr.x, tr.vr.z, 'b', 'LineWidth', 2);
        hold on;
        plot(tr.mouse.x, tr.mouse.z, 'r--', 'LineWidth', 2);
        xlabel('x [cm]');
        grid on;
%         axis equal
        linkaxes([ax1, ax2], 'y')
%         ylim([0 100]);
end
        %%
