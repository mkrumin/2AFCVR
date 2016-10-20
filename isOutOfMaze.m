function isOut=isOutOfMaze(tol)

global TRIAL
global EXP

if nargin<1
    tol=3; % minimum allowed distance to walls
end

isOut=false;
X=1;
Z=3;

x=TRIAL.posdata(TRIAL.info.epoch,X);
z=TRIAL.posdata(TRIAL.info.epoch,Z);
z=-z; % it is more comfortable to use positive z values

% defining the vertices of the inside-the-room polygon
% the inside corners ('shoulders') are cut at 45 degrees.
x1=EXP.corridorWidth/2-tol;
x2=min(x1+2*tol, EXP.roomWidth/2-tol);
x3=EXP.roomWidth-tol;
z1=EXP.roomLength-EXP.corridorWidth-tol;
z2=z1+2*tol;
z3=EXP.roomLength-tol;
xv=[-x1, -x1, -x2, -x3, -x3, x3, x3, x2, x1, x1];
zv=[tol, z1, z2, z2, z3, z3, z2, z2, z1, tol];

isOut=~inpolygon(x, z, xv, zv);

% if (z<tol || z>EXP.roomLength-tol)
%     isOut=true;
% elseif (z<EXP.roomLength-EXP.corridorWidth+tol)
%     % we are in the main corridor
%     if (x>EXP.corridorWidth/2-tol || x<-EXP.corridorWidth/2+tol)
%         isOut=true;
%     end
% else
%     % we are in the horizontal corridor
%     if (x>EXP.roomWidth/2-tol || x<-EXP.roomWidth/2+tol)
%         isOut=true;
%     end
% end
    