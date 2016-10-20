function startOptiStim(stimIntensity)

global AO;
global optiStimChanInd; % LED/laser stim AO channel index
global valveChanInd; % reward valve AO channel index

% starting the optical stimulation while keeping the valve closed
% stimIntesity = [0 1] * 5V

% data2put=nan(1, 2);
% data2put(:, optiStimChanInd)=5*stimIntensity;
% data2put(:, valveChanInd)=5; % high value to keep the valve closed
putsample(AO, stimIntensity(:)'); 

