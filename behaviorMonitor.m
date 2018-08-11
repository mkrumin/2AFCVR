function out = behaviorMonitor(animalName, dateString)

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
else
    % or picking a specific date
    idx = find(expDates == datenum(dateString));
end

% picking the latest session of that day
[~, ind] = max(expSessions(idx));
idx = idx(ind);
ExpRef = upper(expRefs{idx});
% fprintf('\nAnimal %s, found %d session(s) for %s\n\n', animalName, nSessions, dateString);

figureHandle = figure('Name', sprintf('%s %s', animalName, dateString));

while true
    try
        behaviorSnapshot(figureHandle, ExpRef);
    catch e
        warning(e.message)
    end
    pause(10);
end
end

%================================================
