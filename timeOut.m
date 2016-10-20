%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

function timeOut

global MYSCREEN;
% global TRIAL;
global oBeepTIMEOUT;

% fprintf(' TimeOut\n');

% if TRIAL.info.no > 0
%     s = sprintf('%s_trial%03d', SESSION_NAME, TRIAL.info.no);
%     save(s, 'TRIAL', 'EXP');
% end

% tic;
playblocking(oBeepTIMEOUT);
% playSound('TIME OUT');
% clear screen
% Finish OpenGL rendering into PTB window and check for OpenGL errors.
Screen('EndOpenGL', MYSCREEN.windowPtr(1));
% Screen('FillRect', MYSCREEN.windowPtr(1), MYSCREEN.grayIndex);	
% Screen('Flip', MYSCREEN.windowPtr(1));
% Switch to OpenGL rendering again for drawing of next frame:
Screen('BeginOpenGL', MYSCREEN.windowPtr(1));

% while toc<EXP.timeOut
%     if(nargin>0)
%         getBallDeltas(myport);
%     end
% end



return;

% fhandle = @trialEnd;
% end