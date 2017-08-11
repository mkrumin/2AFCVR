
function out = getDaySummary(animalName, dateString, trials)

addpath('\\zserver.cortexlab.net\Code\Psychofit');

if nargin<1
    error('You must provide the animal name');
end

if nargin<2
    % this is today's date
    dateString = datestr(date, 'yyyy-mm-dd');
end

if nargin<3
    trials = [];
end

% for debugging purposes
% animalName = 'MK012';
% dateString = '2014-07-14';

[expRefs, expDates, expSessions] = dat.listExps(animalName);

idx = find(expDates == datenum(dateString));

nSessions = length(idx);

fprintf('\nAnimal %s, found %d session(s) for %s\n\n', animalName, nSessions, dateString);

if nSessions>0
    figureHandle = figure('Name', sprintf('%s %s', animalName, dateString));
end

while true
    try
        singleRun(figureHandle, expRefs(idx), expSessions(idx), trials);
    catch e
        warning(e.message)
    end
    pause(10);
end
end

%================================================
function singleRun(figureHandle, expRefs, expSessions, trials)

nSessions = length(expRefs);

if nSessions>1
    nRows = floor(sqrt(nSessions+1));
    nColumns = ceil((nSessions+1)/nRows);
else
    nRows = 1;
    nColumns = 1;
end

for iSession = 1:nSessions
    [folders, filename] = dat.expFilePath(expRefs{iSession}, 'tmaze', 'master');
    try
        load(folders{1})
    catch
        try
            load(folders{2})
        catch
            load(folders)
        end 
    end
    if ~isempty(trials)
        SESSION.allTrials = SESSION.allTrials(trials);
    end
    
    fprintf('Summary of session %d:\n', expSessions(iSession));
    nSmallRewards(iSession) = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE', 'USER'}));
    nIntermediateRewards(iSession) = sum(ismember({SESSION.Log(2:end).Event}, {'INTERMEDIATE'}));
    nUserRewards(iSession) = sum(ismember({SESSION.Log(2:end).Event}, {'USER'}));
    nLargeRewards(iSession) = sum(ismember({SESSION.Log(2:end).Event}, {'CORRECT'}));
    nTrials(iSession) = SESSION.Log(end).iTrial;
    waterAmount(iSession) = nSmallRewards(iSession)*0.002 + nLargeRewards(iSession)*0.004;
    
    contrast = [];
    outcome = '';
    behavior = '';
    finished = [];
    random = [];
    
    for iTrial = 1:nTrials(iSession)
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
        nTrials(iSession), nSmallRewards(iSession), nLargeRewards(iSession));
    fprintf('nTrialsFinished = %d, of them random = %d, of them correct = %d, pValue = %5.4f\n', ...
        sum(finished), sum(finished & random), sum(outcome=='C' & random), pValue);
    fprintf('Water received = %05.3f ml\n\n', waterAmount(iSession));
    
    cc = unique(contrast);
    pp = nan(size(cc));
    nn = nan(size(cc));
    for iCC=1:length(cc)
        indices = (contrast == cc(iCC)) & finished & random;
        nn(iCC) = sum(indices);
        pp(iCC) = sum(behavior(indices)=='R')/sum(indices);
    end
    
    % get confidence intervals of the binomial distribution
    alpha = 0.1;
    [prob, pci] = binofit(round(pp.*nn), nn, alpha);
    figure(figureHandle);
    subplot(nRows, nColumns, iSession);
    cla;
    errorbar(cc, pp, pp-pci(:,1)', pp-pci(:,2)', 'o')
%     plot(cc, pp, 'o');
    
    titStr{1} = sprintf('Session %d, nTotalTrials = %d, nRandomTrials = %d',...
        expSessions(iSession), nTrials(iSession), sum(random));
    if pValue>0.00005
        titStr{2} = sprintf('pVal = %6.4f, water = %5.3f [ml]', pValue, waterAmount(iSession));
    else
        titStr{2} = sprintf('pVal = %d, water = %5.3f [ml]', pValue, waterAmount(iSession));
    end
    title(titStr);
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
    [ pars, L ] = mle_fit_psycho([cc; nn; pp],'erf_psycho');
    plot(c, erf_psycho(pars, c), 'r', 'LineWidth', 2)
    
    if iSession==1
        allContrast = contrast;
        allOutcome = outcome;
        allBehavior = behavior;
        allFinished = finished;
    else
        allContrast = [allContrast, contrast];
        allOutcome = [allOutcome, outcome];
        allBehavior = [allBehavior, behavior];
        allFinished = [allFinished, finished];
    end
end

if nSessions>0
    fprintf('Total for the day:\n')
    fprintf('nTrials = %d, nSmallRewards = %d, nLargeRewards = %d\n', ...
        sum(nTrials), sum(nSmallRewards), sum(nLargeRewards));
    fprintf('Water received = %05.3f ml\n', sum(waterAmount));
end

if nSessions>1
    cc = unique(allContrast);
    pp = nan(size(cc));
    for iCC=1:length(cc)
        indices = (allContrast == cc(iCC)) & allFinished;
        pp(iCC) = sum(allBehavior(indices)=='R')/sum(indices);
    end
    subplot(nRows, nColumns, nSessions+1);
    cla;
    plot(cc, pp, 'o');
    title(sprintf('All Sessions, nTrials = %d', sum(nTrials)));
    set(gca, 'XTick', cc)
    ylim([0 1]);
    hold on;
    plot(xlim, [0.5, 0.5], 'k:');
    plot([0 0], ylim, 'k:');
end

end


