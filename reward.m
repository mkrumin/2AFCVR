function  reward(command)

global daqSession
global EXP;
global OFFLINE;

if OFFLINE
    return;
end

%% A simple valve-only 64bit DAQ Analog Output based version
% here we assume that there is only one active analog output channel in the
% daqSession. We also assume that ValveClosed = 5, and ValveOpen = 0;

sr=daqSession.Rate;
ValveClosed = 5;
ValveOpen = 0;
padding = ValveClosed*ones(3, 1);

switch command
    case 'SMALL'
        nSamplesOpen=round(EXP.smallRewardTime*sr);
    case 'CORRECT'
        nSamplesOpen=round(EXP.largeRewardTime*sr);
    otherwise
        disp('reward command ''', command,''' not recognized');
end

if ~daqSession.IsDone
    % if not done yet with the previous reward
    % this test/action should be more complicated if using LED stimulation
    % as well (for example daqSession.stop() to stop LED stimulation even
    % before it finished)
    
    daqSession.wait();
end
valveData=[padding; ValveOpen*ones(nSamplesOpen, 1); padding];
% padding with 5s to get to the minimum required (by DAQ) 6 samples
daqSession.queueOutputData(valveData);
daqSession.startBackground;

%% here is the old 32bit version based on AO for both optiStim and the reward valve

% sr=get(AO, 'SampleRate');
% if isequal(EXP.optiStimType, 'TRIAL')
%     optiStimValue=TRIAL.info.optiStim*5;
% else
%     optiStimValue=0;
% end
%
% switch command
%     case 'STOP'
%         isRunning=get(AO,'Running');
%         if isequal(isRunning, 'On')
%             stop(AO);
%         end
%         nSamplesOpen=round(EXP.STOPvalveTime*sr);
%         valveData=[5; 5; 5; zeros(nSamplesOpen, 1); 5; 5; 5];
%         % padding with 5s to get to the minimum required 6 samples
%         optiStimData=ones(length(valveData), 1)*optiStimValue;
%         data2put=nan(length(valveData), 2);
%         data2put(:, valveChanInd)=valveData;
%         data2put(:, optiStimChanInd)=optiStimData;
%         putdata(AO, data2put);
%         start(AO);
%         trigger(AO);
%     case 'CORRECT'
%         isRunning=get(AO,'Running');
%         if isequal(isRunning, 'On')
%             stop(AO);
%         end
%         nSamplesOpen=round(EXP.BASEvalveTime*sr);
%         valveData=[5; 5; 5; zeros(nSamplesOpen, 1); 5; 5; 5];
%         optiStimData=ones(length(valveData), 1)*optiStimValue;
%         data2put=nan(length(valveData), 2);
%         data2put(:, valveChanInd)=valveData;
%         data2put(:, optiStimChanInd)=optiStimData;
%         putdata(AO, data2put);
%         start(AO);
%         trigger(AO);
%     otherwise
%         disp('reward command ''', command,''' not recognized');
% end

%% this is the digital output version of the valve controller - currenlty disabled for the B-Scope setup

% switch command
%     case 'CORRECT'
%          putvalue(DIO.Line(1), 0); % open the valve
%          t=tic;
%          t1=toc(t);
%          % now, wait the appropriate amount of time
%          while(t1<EXP.BASEvalveTime)
%              t1=toc(t);
%          end
%          putvalue(DIO.Line(1), 1); % close the valve
%
%     case 'SMALL'
%          putvalue(DIO.Line(1), 0); % open the valve
%          t=tic;
%          t1=toc(t);
%          % now, wait the appropriate amount of time
%          while(t1<EXP.STOPvalveTime)
%              t1=toc(t);
%          end
%          putvalue(DIO.Line(1), 1); % close the valve
%
%     otherwise
%         disp('reward command ''', command,''' not recognized');
% end


%%
% the old version is here - DIO based
% if(command == solOn)
% %     fprintf(' startReward\n'); % debug
%
%     if ~OFFLINE
% %         if getvalue(DIO.Line(myLine)) == solOn
% %             fprintf('<giveReward> WARNING: Valve not closed before reward!\n');
% %             putvalue(DIO.Line(myLine), solOff);
% %         end
%         %    playSound('correctResponse');
%         putvalue(DIO.Line(myLine), solOn);
%         fprintf('SolOn\n');
%     end
% end
%
% if (command == solOff)
% %     fprintf(' stopReward\n'); % debug
%     if ~OFFLINE
%         putvalue(DIO.Line(myLine), solOff);
%         fprintf('SolOff\n');
%
% %         if getvalue(DIO.Line(myLine)) == solOn
% %             fprintf('<giveReward> WARNING: Valve not closed after reward!\n');
% %             putvalue(DIO.Line(myLine), solOff);
% %         end
%     end
% end

end