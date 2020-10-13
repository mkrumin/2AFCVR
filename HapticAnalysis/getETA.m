function eta = getETA(obj, eventTimes, averageType, timeSpan)

% eta = getETA(obj, eventTimes, averageType) calulates an event triggered
%       average of a certain type based on eventTimes

% obj - TMaze object
% eventTimes - nTrials x 1 cell array calculated using getEventTimes()
% averageType - a string defining a type of average to calculate (e.g.
%               'dTurn/dt', 'dTheta/dt')
% timeSpan - a vector of required times to calcultae the ETA for, for example
%         times == -1:0.1:2 will result in ETA calculated for times from 
%         one second before the event up until 2 seconds after with 
%         resolution of 0.1 seconds

% only use trials with non-empty event times
validTrials = find(~cellfun(@isempty, eventTimes));
nTrials = length(validTrials);
nT = length(timeSpan);
allSnippets = nan(nTrials, nT);

for iTrial = 1:nTrials
    ind = validTrials(iTrial);
    tAxis = obj.trialData(ind).t;
    % for now only consider dYaw
    data = obj.trialData(ind).mouse.dYawVR;
    data(2:end) = data(2:end)./diff(tAxis); % converting to rad/sec (instead of just rad)
    data(1) = 0; %deleting all the accumulation during Inter-Trial-Interval
    % on the next line assume only single event per trial (for now)
    allSnippets(iTrial, :) = interp1(tAxis, data, eventTimes{ind} + timeSpan, 'linear');
end

% calculating mean and sem and converting to deg/sec
eta.mean = nanmean(allSnippets)*180/pi;
eta.sem = nanstd(allSnippets)./sqrt(nTrials-sum(isnan(allSnippets)))*180/pi;
