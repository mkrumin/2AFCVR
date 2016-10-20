function wallTextures = getScene()

global EXP
global TRIAL
global SESSION

switch EXP.stimType
    case {'RANDOM', 'REPLAY'}
        stimulus=SESSION.stimSequence{TRIAL.info.no};
        contrast=SESSION.contrastSequence(TRIAL.info.no);
        optiStim=SESSION.optiStimAmplitude(TRIAL.info.no);
        optiStim2=SESSION.optiStimAmplitude2(TRIAL.info.no);
    case 'BAITED'
        iTrial=TRIAL.info.no;
        optiStim=SESSION.optiStimAmplitude(iTrial);
        optiStim2=SESSION.optiStimAmplitude2(iTrial);
        sides={'LEFT', 'RIGHT'};
        nContrasts=length(SESSION.options.gratingContrasts);
        SESSION.contrastSequence(iTrial) = ...
            SESSION.options.gratingContrasts(round(rand*nContrasts+0.5));
        if iTrial==1
            SESSION.stimSequence(1)=sides(ceil(rand+0.5));
        else
            LASTTRIAL=SESSION.allTrials(iTrial-1);
            if isequal(LASTTRIAL.info.outcome, 'CORRECT')
                % then this trial is the random one
                SESSION.stimSequence(iTrial)=sides(ceil(rand+0.5));
            else
                % then this trial is as the previous one (not contrast)
                SESSION.stimSequence(iTrial)=SESSION.stimSequence(iTrial-1);
            end
        end
        stimulus=SESSION.stimSequence{iTrial};
        contrast=SESSION.contrastSequence(iTrial);
        
    case 'INTERLIEVED'
        iTrial=TRIAL.info.no;
        optiStim=SESSION.optiStimAmplitude(iTrial);
        optiStim2=SESSION.optiStimAmplitude2(iTrial);
        if iTrial==1
            stimulus=SESSION.stimSequence{iTrial};
            contrast=SESSION.contrastSequence(iTrial);
            TRIAL.info.ClosedLoop=true;
        else
            LASTTRIAL=SESSION.allTrials(iTrial-1);
            lastTrialFinished=any(ismember(LASTTRIAL.info.outcome, {'CORRECT', 'WRONG'}));
            if ~LASTTRIAL.info.ClosedLoop || ~lastTrialFinished
                % then this trial is the real one
                stimulus=SESSION.stimSequence{iTrial};
                contrast=SESSION.contrastSequence(iTrial);
                TRIAL.info.ClosedLoop=true;
            else
                % then this trial is the replay of the previous one
                stimulus=SESSION.stimSequence{iTrial-1};
                contrast=SESSION.contrastSequence(iTrial-1);
                TRIAL.info.ClosedLoop=false;
                % and also pushing all the precalculated sequence forward
                ind=[1:iTrial-1, iTrial-1, iTrial:EXP.maxNTrials-1];
                SESSION.stimSequence=SESSION.stimSequence(ind);
                SESSION.contrastSequence=SESSION.contrastSequence(ind);
            end
        end
        
    case 'BOTH'
        SESSION.stimSequence{TRIAL.info.no}='BOTH';
        stimulus=SESSION.stimSequence{TRIAL.info.no};
        contrast=SESSION.contrastSequence(TRIAL.info.no);
        optiStim=SESSION.optiStimAmplitude(TRIAL.info.no);
        optiStim2=SESSION.optiStimAmplitude2(TRIAL.info.no);
        
    case 'ALTERNATING'
        sides={'LEFT', 'RIGHT'};
        nContrasts=length(SESSION.options.gratingContrasts);
        SESSION.contrastSequence(TRIAL.info.no)=SESSION.options.gratingContrasts(round(rand*nContrasts+0.5));
        if TRIAL.info.no==1
            SESSION.stimSequence(1)=sides(ceil(rand+0.5));
        else
            if ~isequal(SESSION.allTrials(TRIAL.info.no-1).info.outcome, 'CORRECT')
                SESSION.stimSequence(TRIAL.info.no)=SESSION.stimSequence(TRIAL.info.no-1);
            else
                if isequal(SESSION.stimSequence{TRIAL.info.no-1}, 'RIGHT')
                    SESSION.stimSequence{TRIAL.info.no}='LEFT';
                else
                    SESSION.stimSequence{TRIAL.info.no}='RIGHT';
                end
            end
        end
        stimulus=SESSION.stimSequence{TRIAL.info.no};
        contrast=SESSION.contrastSequence(TRIAL.info.no);
        optiStim=SESSION.optiStimAmplitude(TRIAL.info.no);
        optiStim2=SESSION.optiStimAmplitude2(TRIAL.info.no);
    otherwise
        disp('stimulus type unrecognized');
end

TRIAL.info.stimulus=stimulus;
TRIAL.info.contrast=contrast;
TRIAL.info.optiStim=optiStim;
TRIAL.info.optiStim2=optiStim2;

contrastIndex=find(SESSION.options.gratingContrasts==contrast);
gratingName=['COSGRATING', num2str(contrastIndex)];

stim2code=stimulus;
% if EXP.flipSides
%     if isequal(stim2code, 'RIGHT')
%         stim2code='LEFT';
%     elseif isequal(stim2code, 'LEFT')
%         stim2code='RIGHT';
%     end
% end
fprintf('%s %d%% contrast\n', stimulus, contrast);
switch stim2code
    case 'RIGHT'
        wallTextures={...
            'GRAY';...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            'WNWEAK';...
            gratingName;...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
    case 'LEFT'
        wallTextures={...
            'GRAY';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            'WNWEAK';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
    case 'BOTH'
        wallTextures={...
            'GRAY';...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
end
