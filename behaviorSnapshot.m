function behaviorSnapshot(figH, ExpRef)

nRows = 1;
nColumns = 3;
nRecentTrials = 20;

[folders, ~] = dat.expFilePath(ExpRef, 'tmaze', 'master');
try
    load(folders{1})
catch
    try
        load(folders{2})
    catch
        load(folders)
    end
end

fprintf('Summary of session %s:\n', ExpRef);
nSmallRewards = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE', 'USER'}));
nIntermediateRewards = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE'}));
nUserRewards = sum(ismember({SESSION.Log(2:end).Event}, {'USER'}));
nLargeRewards = sum(ismember({SESSION.Log(2:end).Event}, {'CORRECT'}));
nTrials = SESSION.Log(end).iTrial;
waterAmount = nSmallRewards*EXP.smallRewardAmount + ...
    nLargeRewards*EXP.largeRewardAmount;

contrast = [];
outcome = '';
behavior = '';
finished = [];
random = [];

for iTrial = 1:nTrials
    contrast(iTrial) = SESSION.allTrials(iTrial).info.contrast;
    side = -1+2*isequal(SESSION.allTrials(iTrial).info.stimulus, 'RIGHT');
    contrast(iTrial) = contrast(iTrial) * side;
    outcome(iTrial) = SESSION.allTrials(iTrial).info.outcome(1);
    behavior(iTrial) = outcome(iTrial);
    if outcome(iTrial) == 'C'
        behavior(iTrial) = SESSION.allTrials(iTrial).info.stimulus(1);
    elseif outcome(iTrial) == 'W'
        behavior(iTrial) = char('R'+'L'-SESSION.allTrials(iTrial).info.stimulus(1));
    end
    finished(iTrial) = ismember(behavior(iTrial), {'R', 'L'});
    if isequal(EXP.stimType, 'BAITED')
        random(iTrial) = iTrial == 1 || outcome(iTrial-1)=='C';
    else
        random(iTrial) = true; %assuming 'RANDOM'
    end
end

pValue = 2*(1-cdf('bino', sum(outcome=='C' & random), sum(finished & random), 0.5));
fprintf('nTrials = %d, nSmallRewards = %d, nLargeRewards = %d\n', ...
    nTrials, nSmallRewards, nLargeRewards);
fprintf('nTrialsFinished = %d, of them random = %d, of them correct = %d, pValue = %5.4f\n', ...
    sum(finished), sum(finished & random), sum(outcome=='C' & random), pValue);
fprintf('Water received = %05.3f ml\n\n', waterAmount);

cc = unique(contrast);
pp = nan(size(cc));
nn = nan(size(cc));
for iCC=1:length(cc)
    indices = (contrast == cc(iCC)) & finished & random;
    nn(iCC) = sum(indices);
    pp(iCC) = sum(behavior(indices)=='R')/sum(indices);
end

% get confidence intervals of the binomial distribution
alpha = 0.05;

[prob, pci] = binofit(round(pp.*nn), nn, alpha);

%% plotting 
figure(figH);
subplot(nRows, nColumns, 1);
cla;
errorbar(cc, pp, pp-pci(:,1)', pp-pci(:,2)', 'o')
%     plot(cc, pp, 'o');

titStr{1} = strrep(ExpRef, '_', '\_');
titStr{2} = sprintf('nTotalTrials = %d, nRandomTrials = %d',...
    nTrials, sum(random));
if pValue>5e-4
    titStr{3} = sprintf('pVal = %5.3f, water = %5.3f [ml]', pValue, waterAmount);
else
    titStr{3} = sprintf('pVal = %3.1d, water = %5.3f [ml]', pValue, waterAmount);
end
title(titStr);
xlabel('Contrast [%]');
ylabel('Prob R');
set(gca, 'XTick', cc)
ylim([0 1]);
hold on;
plot(xlim, [0.5, 0.5], 'k:');
plot([0 0], ylim, 'k:');
axis square
box off

% fit a psychometric curve (asymmetric lapse rate)
nfits = 10;
parstart = [ mean(cc), 3, 0.05, 0.05 ];
parmin = [min(cc) 0 0 0];
parmax = [max(cc) 10 0.40 0.4];
[ pars, L ] = mle_fit_psycho([cc; nn; pp],'erf_psycho_2gammas', parstart, parmin, parmax, nfits);
c = -50:50;
plot(c, erf_psycho_2gammas(pars, c), 'k', 'LineWidth', 2)

% this is a psychometric function with symmetric lapse rate
% [ pars, L ] = mle_fit_psycho([cc; nn; pp],'erf_psycho');
% plot(c, erf_psycho(pars, c), 'r', 'LineWidth', 2)

subplot(nRows, nColumns, 2);
cla;
iRC = find(behavior=='R' & contrast>0);
iLC = find(behavior=='L' & contrast<0);
iRW = find(behavior=='R' & contrast<0);
iLW = find(behavior=='L' & contrast>0);
iR0 = find(behavior=='R' & contrast==0);
iL0 = find(behavior=='L' & contrast==0);
stem(iRC, ones(size(iRC)), 'g', 'Marker', '.');
hold on;
stem(iLC, -ones(size(iLC)), 'g', 'Marker', '.');
stem(iRW, ones(size(iRW)), 'r', 'Marker', '.');
stem(iLW, -ones(size(iLW)), 'r', 'Marker', '.');
stem(iR0, ones(size(iR0)), 'k', 'Marker', '.');
stem(iL0, -ones(size(iL0)), 'k', 'Marker', '.');

xlabel('iTrial')
ylabel('behavior')
set(gca, 'YTick', [-0.5 0.5], 'YTickLabel', {'L', 'R'});
xlim([0 length(outcome)]);
view(90, -90)

%% plot trajectories of last nRecentTrials trials

iRecent = max(nTrials - nRecentTrials + 1, 1):nTrials;
iW = union(iRW, iLW);
iC = union(iRC, iLC);
i0 = union(iR0, iL0);
iT = find(behavior=='T');

tStart = SESSION.allTrials(iRecent(1)).info.start;
tEnd = SESSION.allTrials(iRecent(end)).info.start;
trPerMin = 60/etime(tEnd, tStart)*(iRecent(end)-iRecent(1));

subplot(nRows, nColumns, 3)
cla;
zInd = find(ismember(SESSION.allTrials(1).pospars, 'Z'));
thInd = find(ismember(SESSION.allTrials(1).pospars, 'theta'));
for iTrial = intersect(iRecent, iW)
    zz = - SESSION.allTrials(iTrial).posdata(:, zInd);
    theta = SESSION.allTrials(iTrial).posdata(:, thInd) * 180/pi;
    p = plot(theta, zz, 'r');
    p.LineWidth = max(0.25, 3 + iTrial - nTrials);
    hold on;
end
for iTrial = intersect(iRecent, iC)
    zz = - SESSION.allTrials(iTrial).posdata(:, zInd);
    theta = SESSION.allTrials(iTrial).posdata(:, thInd) * 180/pi;
    p = plot(theta, zz, 'g');
    p.LineWidth = max(0.25, 3 + iTrial - nTrials);
    hold on;
end
for iTrial = intersect(iRecent, i0)
    zz = - SESSION.allTrials(iTrial).posdata(:, zInd);
    theta = SESSION.allTrials(iTrial).posdata(:, thInd) * 180/pi;
    p = plot(theta, zz, 'k');
    p.LineWidth = max(0.25, 3 + iTrial - nTrials);
    hold on;
end

axis tight
xlabel('\theta [deg]');
ylabel('z [cm]');
title({sprintf('Last %1.0f trials', min(nRecentTrials, nTrials)); ...
    sprintf('Current pace: %4.2f [trials/min]', trPerMin)});


% fprintf('Total for the day:\n')
% fprintf('nTrials = %d, nSmallRewards = %d, nLargeRewards = %d\n', ...
%     sum(nTrials), sum(nSmallRewards), sum(nLargeRewards));
% fprintf('Water received = %05.3f ml\n', sum(waterAmount));

