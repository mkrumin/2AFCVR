function doOptiStim

% here the optical stimulation is implemented.
% currently not supported in the 2p version of the code, so:
return;

if  ~optiStimON
    optiStimON=true;
    sampleRate=get(AO, 'SampleRate');
    nSamples=EXP.optiStimDuration*sampleRate;
    %                     valveData=5*ones(nSamples+1, 1);
    switch EXP.optiStimShape
        case 'RAMP'
            LEDData(:, 1)=5*(1:nSamples)'/nSamples*TRIAL.info.optiStim;
            LEDData(:, 2)=5*(1:nSamples)'/nSamples*TRIAL.info.optiStim2;
        case 'STEP'
            LEDData(:, 1)=5*ones(nSamples, 1)*TRIAL.info.optiStim;
            LEDData(:, 2)=5*ones(nSamples, 1)*TRIAL.info.optiStim2;
        case 'PULSES'
            nSamplesPerPulse=round(sampleRate*EXP.optiStimPulseDur/1000);
            pulseTrain=zeros(nSamples, 1);
            pulseIdx=(0:1/EXP.optiStimPulseFreq:EXP.optiStimDuration)*sampleRate;
            pulseIdx=round(pulseIdx)+5; %giving a few empty samples before the first pulse
            pulseIdx=pulseIdx(pulseIdx<nSamples);
            pulseTrain(pulseIdx)=1;
            switch EXP.optiStimPulseShape
                case 'SQUARE'
                    singlePulse=ones(nSamplesPerPulse, 1);
                case 'RAMP'
                    singlePulse=(1:nSamplesPerPulse)'/nSamplesPerPulse;
                case 'SINE'
                    tTemp=(1:nSamplesPerPulse)'/nSamplesPerPulse*pi;
                    singlePulse=sin(tTemp);
                otherwise
                    warning('Unrecognized optiStimPulseShape, making SQUARE pulses');
                    singlePulse=ones(nSamplesPerPulse, 1);
            end
            LEDData(:, 1)=conv(singlePulse, pulseTrain)*5*TRIAL.info.optiStim;
            LEDData(:, 2)=conv(singlePulse, pulseTrain)*5*TRIAL.info.optiStim2;
            LEDData=LEDData(1:nSamples, :);
        otherwise
            warning('Unrecognized optiStimShape, setting stim to zero intensity');
            LEDData=zeroes(nSamples, 2);
    end
    LEDData=[LEDData; 0, 0]; % to make sure the stim is off at the end
    %                     data=nan(length(valveData), 2);
    %                     data(:, valveChanInd)=valveData;
    %                     data(:, optiStimChanInd)=LEDData;
    putdata(AO, LEDData);
    start(AO);
    trigger(AO);
else
    isRunning=get(AO,'Running');
    if isequal(isRunning, 'Off')
        optiStimON=false;
    end
end
