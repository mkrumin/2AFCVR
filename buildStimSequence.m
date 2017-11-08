function buildStimSequence

global EXP
global SESSION
global SESSION2REPLAY


rand('seed', sum(100*clock));

% first build the R/L sequence, which is independent of the contrast

switch EXP.stimType
    case {'RANDOM', 'INTERLIEVED'}
        seq=nan(EXP.maxNTrials, 1);
        for iTrial=1:min(3, EXP.maxNTrials)
            seq(iTrial)=round(rand+EXP.probRight-0.5);
        end
        for iTrial=4:EXP.maxNTrials
            % we want to prevent more than three consecutive 'same-sides'
            if sum(seq(iTrial-3:iTrial-1))==3
                seq(iTrial)=0;
            elseif sum(seq(iTrial-3:iTrial-1))==0
                seq(iTrial)=1;
            else
                seq(iTrial)=round(rand);
            end
        end
        sides={'LEFT', 'RIGHT'};
        SESSION.stimSequence=sides(seq+1);
    case {'ALTERNATING', 'BAITED'}
        SESSION.stimSequence={};
    case 'BOTH'
        SESSION.stimSequence={};
    case 'REPLAY'
        SESSION.stimSequence=SESSION2REPLAY.stimSequence;
    case 'REPLAY_SCRAMBLED'
        SESSION.stimSequence=NaN;
    otherwise
        SESSION.stimSequence={};
        SESSION.contrastSequence=[];
        disp('stimulus type not recognized');
end

% then build the contrast sequence

SESSION.contrastSequence=nan(EXP.maxNTrials, 1);

switch EXP.stimType
    case {'RANDOM', 'INTERLIEVED', 'BAITED', 'ALTERNATING', 'BOTH'}
        % the contrast sequence here is random
        nContrasts=length(EXP.contrasts);
        cIdx=round(rand(EXP.maxNTrials, 1)*nContrasts+0.5);
        SESSION.contrastSequence=reshape(EXP.contrasts(cIdx), [], 1);

    case 'REPLAY'
        % we just replay exactly what was there
        SESSION.contrastSequence=SESSION2REPLAY.contrastSequence;

    otherwise
        warning('Sorry, not implemented yet for this sequence type of the visual stimulus');
end


