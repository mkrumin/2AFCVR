function out = behaviorData(ExpRef)

[fullFileName, ~] = dat.expFilePath(ExpRef, 'tmaze', 'master');
load(fullFileName)

% fprintf('Summary of session %s:\n', ExpRef);
nIntermediateRewards = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE'}));
nUserRewards = sum(ismember({SESSION.Log(2:end).Event}, {'USER'}));
nSmallRewards = nIntermediateRewards + nUserRewards;
nLargeRewards = sum(ismember({SESSION.Log(2:end).Event}, {'CORRECT'}));
nTrials = SESSION.Log(end).iTrial;
waterAmount = nSmallRewards*EXP.smallRewardAmount + ...
    nLargeRewards*EXP.largeRewardAmount;

contrast = nan(nTrials, 1);
outcome = '';
behavior = '';
finished = nan(nTrials, 1);
random = nan(nTrials, 1);
z = cell(nTrials, 1);
theta = cell(nTrials, 1);

zInd = find(ismember(SESSION.allTrials(1).pospars, 'Z'));
thInd = find(ismember(SESSION.allTrials(1).pospars, 'theta'));

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
    elseif isequal(EXP.stimType, 'RANDOM')
        random(iTrial) = true; 
    else
        random(iTrial) = false; % probably 'BOTH'
    end
    z{iTrial} = SESSION.allTrials(iTrial).posdata(:, zInd);
    theta{iTrial} = SESSION.allTrials(iTrial).posdata(:, thInd);
end

out.sessionType = EXP.stimType;
out.nRewards.intermediate = nIntermediateRewards;
out.nRewards.user = nUserRewards;
out.nRewards.small = nSmallRewards;
out.nRewards.large = nLargeRewards;
out.waterAmount = waterAmount;
out.contrast = contrast;
out.outcome = outcome(:);
out.behavior = behavior(:);
out.finished = finished;
out.random = random;
out.z = z;
out.theta = theta;

return;

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

