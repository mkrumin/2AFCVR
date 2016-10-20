function [direction distance]=whereIsItGoing(currentPos, baseIndex)

global EXP;
global TRIAL;


xMov=currentPos(1)-TRIAL.bases(baseIndex).stopPosition(1);
zMov=currentPos(3)-TRIAL.bases(baseIndex).stopPosition(3);

distance = sqrt(xMov^2+zMov^2);

moveAngle = findAngle(xMov,zMov);

baseCenterAngle = findAngle((TRIAL.bases(baseIndex).center(1)-TRIAL.bases(baseIndex).stopPosition(1)),...
    (TRIAL.bases(baseIndex).center(3)-TRIAL.bases(baseIndex).stopPosition(3)));

mirrorBaseAngle = findAngle((TRIAL.bases(baseIndex).mirrorCenter(1)-TRIAL.bases(baseIndex).stopPosition(1)),...
    (TRIAL.bases(baseIndex).mirrorCenter(3)-TRIAL.bases(baseIndex).stopPosition(3)));

direction = 'NO CHOICE';
correctTolerance =EXP.correctTolerance;

if(abs(moveAngle-baseCenterAngle)>EXP.directionTolerance) %EXP.minOffsetAngle)
    direction = 'TIME OUT';
    
elseif abs(moveAngle-baseCenterAngle)<= correctTolerance
    direction = 'CORRECT';
elseif abs(moveAngle-baseCenterAngle)> correctTolerance
    direction = 'WRONG';
end
    
end
    
function angle = findAngle (xMov,zMov)   
    
angle = atan(abs(xMov/zMov))/pi*180;

if (xMov<0 && zMov<=0)
   angle = -angle;
elseif (xMov>=0 && zMov<0)
    angle = angle;
elseif (xMov >0 && zMov>=0) 
    angle = 180 - angle;
elseif (xMov<=0 && zMov>0)
    angle = -1*(180 - angle);
end

end

