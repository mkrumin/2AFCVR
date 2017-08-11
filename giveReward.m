function giveReward(count, tag)

global oBeepSTART;
global oBeepCORRECT;
global oBeepWRONG;
global SESSION
global TRIAL

display([int2str(count) ' ' tag]);

iEvent = length(SESSION.Log)+1;
SESSION.Log(iEvent).iTrial = TRIAL.info.no;
SESSION.Log(iEvent).iFrame = count;
SESSION.Log(iEvent).Event = tag;

switch tag
    case 'START'
        play(oBeepSTART); % no water reward, only sound
    case 'CORRECT'
        playblocking(oBeepCORRECT);
%         reward('CORRECT');
        reward('SMALL'); %!!!
    case 'WRONG'
        playblocking(oBeepWRONG);
    case 'USER'
        play(oBeepCORRECT);
        reward('SMALL'); % a smaller manual reward
    case 'INTERMEDIATE'
        play(oBeepCORRECT);
        reward('SMALL'); % a smaller intermediate reward
    otherwise
        display('!!!!!!!!!!!No such sound!!!!!!!!!!!!!')
end
