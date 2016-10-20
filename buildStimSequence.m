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

% then build the contrast and the optiStim sequence

SESSION.contrastSequence=nan(EXP.maxNTrials, 1);
SESSION.optiStimAmplitude=nan(EXP.maxNTrials, 1);
SESSION.optiStimAmplitude2=nan(EXP.maxNTrials, 1);

% build the table with all the possible options
% the first column will be the contrast
% the second is the LED1 intensity
% the third will be the LED2 intensity

% EXP=setExperimentPars; % this line for debugging only, comment otherwise

nContrastsVis=length(EXP.contrasts);
nContrastsLED=length(EXP.optiStimContrasts)*(EXP.optiStim>0);
nIntensitiesLED1=length(EXP.optiStimIntensities)*(EXP.optiStim>=1);
nIntensitiesLED2=length(EXP.optiStimIntensities2)*(EXP.optiStim>=2);

nOptions=nContrastsVis+nContrastsLED*(nIntensitiesLED1+nIntensitiesLED2+1*(EXP.optiStim==2));

subTableVis=zeros(nContrastsVis, 3);
subTableVis(:,1)=EXP.contrasts(:);

subTableLED1=zeros(nContrastsLED*nIntensitiesLED1, 3);
if EXP.optiStim>=1
    subTableLED1(:,1)=repmat(EXP.optiStimContrasts(:), nIntensitiesLED1, 1);
    subTableLED1(:,2)=reshape(repmat(EXP.optiStimIntensities(:)', nContrastsLED, 1), [], 1);
end


subTableLED2=zeros(nContrastsLED*nIntensitiesLED2, 3);
if EXP.optiStim==2
    subTableLED2(:,1)=repmat(EXP.optiStimContrasts(:), nIntensitiesLED2, 1);
    subTableLED2(:,3)=reshape(repmat(EXP.optiStimIntensities2(:)', nContrastsLED, 1), [], 1);
end

subTableLEDBoth=zeros(nContrastsLED*(EXP.optiStim==2), 3);
if EXP.optiStim==2
    subTableLEDBoth(:,1)=EXP.optiStimContrasts(:);
    subTableLEDBoth(:,2)=repmat(max(EXP.optiStimIntensities), nContrastsLED, 1);
    subTableLEDBoth(:,3)=repmat(max(EXP.optiStimIntensities2), nContrastsLED, 1);
end

fullTable=[subTableVis; subTableLED1; subTableLED2; subTableLEDBoth];

switch EXP.stimType
    case {'RANDOM', 'INTERLIEVED', 'BAITED'}
        switch EXP.optiStimSequence
            case 'ON'
                SESSION.optiStimAmplitude=ones(EXP.maxNTrials, 1)*max(EXP.optiStimIntensities);
                SESSION.optiStimAmplitude2=ones(EXP.maxNTrials, 1)*max(EXP.optiStimIntensities);
                nContrasts=length(EXP.contrasts);
                cIdx=round(rand(EXP.maxNTrials, 1)*nContrasts+0.5);
                SESSION.contrastSequence=reshape(EXP.contrasts(cIdx), [], 1);
                
            case 'RANDOM'
                % simply random sequence
                cIdx=round(rand(EXP.maxNTrials, 1)*nOptions+0.5);
                SESSION.contrastSequence=fullTable(cIdx, 1);
                SESSION.optiStimAmplitude=fullTable(cIdx, 2);
                SESSION.optiStimAmplitude2=fullTable(cIdx, 3);
            case 'PSEUDORANDOM'
                % going (randomly) through ALL the options once
                % and then looping until EXP.maxNTrials
                cIdx=[];
                while length(cIdx)<EXP.maxNTrials
                    cIdx=[cIdx; randperm(nOptions)'];
                end
                cIdx=cIdx(1:EXP.maxNTrials);
                    
                SESSION.contrastSequence=fullTable(cIdx, 1);
                SESSION.optiStimAmplitude=fullTable(cIdx, 2);
                SESSION.optiStimAmplitude2=fullTable(cIdx, 3);
            otherwise
                SESSION.optiStimAmplitude=zeroes(EXP.maxNTrials, 1);
                SESSION.optiStimAmplitude2=zeroes(EXP.maxNTrials, 1);
                warning('Sorry, this optiStimSequence not implemented yet');
                warning('Light intensity will be set to zero');
        end
    case {'ALTERNATING', 'BOTH'}
        % in this case setting the optical stimulation to zero
        % and purely randomizing the contrast

        nContrasts=length(EXP.contrasts);
        cIdx=round(rand(EXP.maxNTrials, 1)*nContrasts+0.5);
        SESSION.contrastSequence=reshape(EXP.contrasts(cIdx), [], 1);
        
        SESSION.optiStimAmplitude=zeros(EXP.maxNTrials, 1);
        SESSION.optiStimAmplitude2=zeros(EXP.maxNTrials, 1);
        warning('Light intensity will be set to zero');
        
    case 'REPLAY'
        SESSION.contrastSequence=SESSION2REPLAY.contrastSequence;
        SESSION.optiStimAmplitude=SESSION2REPLAY.optiStimAmplitude;
        SESSION.optiStimAmplitude2=SESSION2REPLAY.optiStimAmplitude2;
        
    otherwise
        SESSION.optiStimAmplitude=zeros(EXP.maxNTrials, 1);
        SESSION.optiStimAmplitude2=zeros(EXP.maxNTrials, 1);
        warning('Sorry, not implemented yet for this sequence type of the visual stimulus');
        warning('Light intensity will be set to zero');
end


