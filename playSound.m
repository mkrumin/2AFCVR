% playSound ---------------------------------------------------------------
function playSound(whichSound)

global oBeepWrong;
global oBeepNoise;
global oBeepBase;
global oBeepStop;


switch whichSound
    
    case 'WRONG'
        play(oBeepWrong);
    case 'TIME OUT'
        play(oBeepNoise);
    case 'BASE'
        play(oBeepBase);
    case 'STOP'
        play(oBeepStop);
    otherwise
        error('Error: No Such sound!!!')
end
        
        
end
