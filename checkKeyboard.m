function userAbort = checkKeyboard

userAbort = 0;
[keyIsDown, secs, keyCode] = KbCheck; % Psychophysics toolbox

if keyIsDown
    
    if keyCode(32) % space
        %fprintf('keyIsDown \n')
        giveReward(0,'USER');
    elseif keyCode(27) || keyCode(81) % q/Q QUIT or Esc
        %                 TRIAL.outcome = 'UserAbort';
        
        %endOfExperiment;
        userAbort =1;
        
        
        %             case {112, 80} % p/P PAUSE
        %                 TRIAL.outcome = 'UserAbort';
        %                 fhandle = @pauseExperiment;
    end
end


end