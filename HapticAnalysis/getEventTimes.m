function eventTimes = getEventTimes(obj, eventType)

% eventTimes = getEventTimes(obj, eventType) calculates times of
% certain events, which can consequently be used in Event-Triggered-Average
% or kernel analysis
% 
% obj - object of TMaze class
% eventType - type of event (as a string), times of which should be extracted. 
%             For example 'LeftWallContact', 'RightWallContact', can be
%             expanded as necessary for new event types
% eventTimes - an nTrials x 1 cell array with timestamps of events (each
%              trial might have a different number of such events, hence 
%              it should be a cell array and not just a matrix)

eventTimes = cell(obj.nTrials, 1);

switch eventType
    case 'LeftWallContact'
        thr = -3;
        for iTrial = 1:obj.nTrials
            data = obj.trialData(iTrial).vr.x;
            t = obj.trialData(iTrial).t;
            % For now will only take the first event of the trial
            indThr = find(data<thr, 1, 'first');
            if ~isempty(indThr) && obj.trialData(iTrial).vr.z(indThr)<85
                eventTimes{iTrial} = t(indThr);
            end
        end
    case 'RightWallContact'
        thr = 3;
        for iTrial = 1:obj.nTrials
            data = obj.trialData(iTrial).vr.x;
            t = obj.trialData(iTrial).t;
            % For now will only take the first event of the trial
            indThr = find(data>thr, 1, 'first');
            if ~isempty(indThr) && obj.trialData(iTrial).vr.z(indThr)<85
                eventTimes{iTrial} = t(indThr);
            end
        end
    otherwise
end
    



