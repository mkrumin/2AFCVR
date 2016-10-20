function getNonBallDeltas
% note:     In the standard position of the device mouse A is on the east side, mouse B on the north side
%
%       According to the MouseBall Tracker application:
%       ax goes positive if the ball turns away from mouse A, and negative if the ball turns towards Mouse A
%       bx goes positive if the ball moves away from mouse B and negative if the ball moves towards mouse B
%
%       ay goes positive for counterclockwise and negative for clockwise rotation
%       by behaves in the same way
%
%       mouse walks north: bx goes positive
%       mouse walks south: bx goes negative
%       mouse walks east:  ax goes positive
%       mouse walks west:  ax goes negative

global MOUSEXY


MOUSEXY.dbx = 0;
MOUSEXY.dax = 0;
MOUSEXY.day = 0;
MOUSEXY.dby = 0;

[keyIsDown, secs, keyCode] = KbCheck; % Psychophysics toolbox

trStep=100;
rotStep=100;

if keyIsDown
    
    if keyCode(38)
        %up
        MOUSEXY.dbx = -trStep;
    end
    if keyCode(40) %Down
        MOUSEXY.dbx = trStep;
    end
    if keyCode(37) % left
        MOUSEXY.dax = trStep;
    end
    if keyCode(39) % right
        MOUSEXY.dax = -trStep;
    end
    if keyCode(49) % 1
        MOUSEXY.day = rotStep;
        MOUSEXY.dby = rotStep;
    end
    if keyCode(50) % 2
        MOUSEXY.day = -rotStep;
        MOUSEXY.dby = -rotStep;
    end
    
end


end

% [x, y, buttons] = GetMouse(4);
% if mousex ~= x./5000
%     MOUSEXY.dbx = mousex - x/5000;
%     mousex = x/5000;
% end
% if mousey ~= y/900
%     MOUSEXY.dby = mousey - y/900;
%     mousey = y/900;
% end
