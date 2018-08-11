function out = behaviorSummary(animalName, dateString)

addpath('\\zserver.cortexlab.net\Code\Psychofit');

if nargin<1
    error('You must provide the animal name');
end

if nargin<2
    % by default will use latest available dataset
    dateString = [];
end

% for debugging purposes
% animalName = 'MK012';
% dateString = '2014-07-14';

[expRefs, expDates, expSessions] = dat.listExps(animalName);

if isempty(dateString)
    % using the latest experiment date
    idx = find(expDates == max(expDates));
    dateString = datestr(max(expDates), 'yyyy-mm-dd');
else
    % or picking a specific date
    idx = find(expDates == datenum(dateString));
end

expRefs = expRefs(idx);

idx = false(length(expRefs), 1);
for iExp = 1:length(expRefs)
    % check the actual existence of data files
    % sometimes only an empty folder exists
    ExpRef = upper(expRefs{iExp});
    [fullFileName, ~] = dat.expFilePath(ExpRef, 'tmaze', 'master');
    if exist(fullFileName, 'file')
        idx(iExp) = true;
    end
end
expRefs = expRefs(idx);
nSessions = length(expRefs);
% now we are sure we only have valid expRefs in the list

sesType = cell(nSessions+1, 1);
nTrials = nan(nSessions + 1, 1);
nFinished = nan(nSessions + 1, 1);
nRandom = nan(nSessions + 1, 1);
nCorrect = nan(nSessions + 1, 1);
waterAmount = nan(nSessions + 1, 1);
intRewards = nan(nSessions + 1, 1);
userRewards = nan(nSessions + 1, 1);
largeRewards = nan(nSessions + 1, 1);
pValue = nan(nSessions + 1, 1);

for iSession = 1:nSessions
    ExpRef = upper(expRefs{iSession});
% fprintf('\nAnimal %s, found %d session(s) for %s\n\n', animalName, nSessions, dateString);
    data(iSession) = behaviorData(ExpRef);
    sesType{iSession} = data(iSession).sessionType;
    nTrials(iSession) = length(data(iSession).contrast);
    nFinished(iSession) = sum(data(iSession).finished);
    nRandom(iSession) = sum(data(iSession).finished & data(iSession).random);
    nCorrect(iSession) = sum(data(iSession).outcome == 'C' & ...
        data(iSession).finished & data(iSession).random);
    waterAmount(iSession) = data(iSession).waterAmount;
    intRewards(iSession) = data(iSession).nRewards.intermediate;
    userRewards(iSession) = data(iSession).nRewards.user;
    largeRewards(iSession) = data(iSession).nRewards.large;
    pValue(iSession) = 2*(1-cdf('bino', nCorrect(iSession), nRandom(iSession), 0.5));
end
rowNames = [expRefs(:); {'TOTAL'}];
nTrials(end) = sum(nTrials(1:end-1));
nRandom(end) = sum(nRandom(1:end-1));
nFinished(end) = sum(nFinished(1:end-1));
nCorrect(end) = sum(nCorrect(1:end-1));
pValue(end) = 2*(1-cdf('bino', nCorrect(end), nRandom(end), 0.5));
waterAmount(end) = sum(waterAmount(1:end-1));
intRewards(end) = sum(intRewards(1:end-1));
userRewards(end) = sum(userRewards(1:end-1));
largeRewards(end) = sum(largeRewards(1:end-1));
summary = table(sesType, nTrials, nFinished, nRandom, intRewards, userRewards, largeRewards, waterAmount, pValue, 'RowNames', rowNames)

shortSummary = table(sesType, nTrials, nFinished, nRandom, nCorrect, waterAmount, pValue, 'RowNames', rowNames)

% figureHandle = figure('Name', sprintf('%s %s', animalName, dateString));
%================================================
