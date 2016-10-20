function stopOptiStim()

global AO;
global optiStimChanInd; % LED/laser stim AO channel index
global valveChanInd; % reward valve AO channel index

% stopping the optical stimulation and keeping the valve closed
% stimIntesity = 0 [V]

% data2put=nan(1, 2);
% data2put(:, optiStimChanInd)=0;
% data2put(:, valveChanInd)=5; % high value to keep the valve closed
putsample(AO, [0, 0]); 