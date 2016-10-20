function TRIAL = makeScrambled(data)

global EXP SESSION

nTrials = length(data.SESSION.allTrials);
nFramesPerSnippet = EXP.replaySnippetDuration;
snippets = struct('posdata', [], 'trialIndex', [], 'countsRange', []);
contrasts = [];
stimuli = '';
for iTrial = 1:nTrials
    if ismember(data.SESSION.allTrials(iTrial).info.outcome, {'TIMEOUT', 'USER ABORT'})
        fprintf('Skipping trial %d\n', iTrial);
        continue;
    end
    trial = data.SESSION.allTrials(iTrial);
    startInd = find(trial.freezeOver, 1, 'first');
    endInd = size(trial.posdata, 1);
    startFrames = endInd-nFramesPerSnippet+1:-nFramesPerSnippet:startInd;
    endFrames = startFrames+nFramesPerSnippet-1;
    for iSnippet = 1:length(startFrames)
        snippets(end+1).posdata = trial.posdata(startFrames(iSnippet):endFrames(iSnippet), :);
        snippets(end).trialIndex = iTrial;
        snippets(end).countsRange = [startFrames(iSnippet), endFrames(iSnippet)];
        contrasts = cat(1, contrasts, repmat(trial.info.contrast, nFramesPerSnippet, 1));
        stimuli = cat(2, stimuli, repmat(trial.info.stimulus(1), 1, nFramesPerSnippet));
    end
end
snippets = snippets(2:end);
nSnippets = length(snippets);

% 'seeding' the random number generator
rand('seed', 1);

randSeq = randperm(nSnippets);
snippets = snippets(randSeq);
contrasts = reshape(contrasts, nFramesPerSnippet, []);
contrasts = reshape(contrasts(:, randSeq), [], 1);
stimuli = reshape(stimuli, nFramesPerSnippet, []);
stimuli = reshape(stimuli(:, randSeq), 1, []);

posdata = [];
for iSnippet = 1:nSnippets
    posdata = cat(1, posdata, snippets(iSnippet).posdata);
end
[nFrames, nPars] = size(posdata);

alpha = (1-cos([1:nFrames]'*2*pi/nFramesPerSnippet))/2;
syncState = ones(nFrames, 1);
syncState(2:2:end) = 0;
nBlankFrames = round(EXP.grayScreenDur*60);

TRIAL.posdata = cat(1, zeros(nBlankFrames, nPars), posdata);
TRIAL.trialActive = cat(1, zeros(nBlankFrames, 1), ones(nFrames, 1));
TRIAL.freezeOver = TRIAL.trialActive;
TRIAL.alpha = cat(1, zeros(nBlankFrames, 1), alpha);
TRIAL.contrast = cat(1, zeros(nBlankFrames, 1), contrasts);
TRIAL.stimulus = cat(2, repmat('B', 1, nBlankFrames), stimuli);
TRIAL.syncState = cat(1, zeros(nBlankFrames, 1), syncState);

SESSION.replaySnippets = snippets;

return;

%% this plotting is for debugging only 

figure
plot(snippets(1).posdata(:, 4), -snippets(1).posdata(:, 3))
xlim([-pi/2, pi/2]);
ylim([0, 110]);
title(sprintf('%d/%d', 1, nSnippets))
axis off;
hold on;
drawnow;
for iSnippet = 2:nSnippets
    plot(snippets(iSnippet).posdata(:, 4), -snippets(iSnippet).posdata(:, 3))
    title(sprintf('%d/%d', iSnippet, nSnippets))
    %     hold on;
    drawnow;
    pause(0.01);
end
pause

