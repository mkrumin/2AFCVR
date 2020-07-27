function [stagePos, Vout, ballBlocked] = moveStage(dLeft, dRight, dFront)

% dLeft - distance of the wall to the left whiskers
% dRight - distance of the wall to the right whiskers
global servoDaqSession;
global ballDaqSession;
Vzero = parkServoVoltage; % [V] - Voltage value for 'neutral position'
V2mmGain = 12; % [mm/V] 5V is equivalent to 60mm movement

if nargin<2
    % move to 'neutral position' if only one number provided
    Vout = Vzero;
    ballBlocked = false;
    Vball = ballFloatingVoltage;
else
    
    stagePos = maze2stageTF(dLeft, dRight);
    
    Vout = Vzero + stagePos/V2mmGain;
    if dFront < 6
        ballBlocked = true;
        Vball = ballBlockedVoltage;
    else
        ballBlocked = false;
        Vball = ballFloatingVoltage;
    end
    
end

servoDaqSession.outputSingleScan(Vout);
ballDaqSession.outputSingleScan(Vball);

end

function pos = maze2stageTF(dL, dR)

% find distance to the closest wall
d = min(dL, dR);

pos = interp1([0 5 10 15], [15 15 0 0], d, 'linear', 'extrap');
if dL < dR
    % return negative result if the left wall is closer than right
    pos = - pos;
end
end