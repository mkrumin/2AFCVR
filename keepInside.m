function keepInside(tol)

global TRIAL
global EXP

epsilon=0;

if nargin<1
  tol=3; % minimum allowed distance to walls
end
X=1;
Z=3;

zMax=EXP.roomLength-tol;
zMin=tol;
% gray region Zs
z1=EXP.roomLength-EXP.corridorWidth-tol+epsilon;
z2=EXP.roomLength-EXP.corridorWidth+tol;

xMax=EXP.roomWidth/2-tol-epsilon;
% gray region Xs
x1=EXP.corridorWidth/2-tol;
x2=min(x1+2*tol-epsilon, xMax);

x=TRIAL.posdata(TRIAL.info.epoch,X);
z=TRIAL.posdata(TRIAL.info.epoch,Z);
z=-z; % it is more comfortable to use positive z values

xLast=TRIAL.posdata(TRIAL.info.epoch-1,X);
zLast=TRIAL.posdata(TRIAL.info.epoch-1,Z);
zLast=-zLast; % it is more comfortable to use positive z values


z=max(min(z, zMax), zMin);
x=max(min(x, xMax), -xMax);
TRIAL.posdata(TRIAL.info.epoch,X)=x;
TRIAL.posdata(TRIAL.info.epoch,Z)=-z;

if ~isOutOfMaze(tol)
  return;
end

% this code implements only if still outside the maze
if zLast<=z1
  if z<=z1
    if x>x1
      x=x1;
    end
    if x<-x1
      x=-x1;
    end
  else
    if x>x1
      % len = how far to go along the diagonal segment
      len=sum([x-x1, z-z1].*[1/sqrt(2), 1/sqrt(2)]);
      x=x1+len/sqrt(2);
      z=z1+len/sqrt(2);
    end
    if x<-x1
      % len = how far to go along the diagonal segment
      len=sum([x+x1, z-z1].*[-1/sqrt(2), 1/sqrt(2)]);
      x=-x1-len/sqrt(2);
      z=z1+len/sqrt(2);
    end
  end
else%if zLast<=z2
  if x<-x1
    % distance to the diagonal segment
    d(1)=sum([x+x1, z-z1].*[-1, -1]/sqrt(2));
    % distance to the vertical wall
    d(2)=-x1-x;
    % distance to the horizontal wall
    d(3)=z2-z;
    [m ind]=min(d);
    switch ind
      case 1
        len=sum([x+x1, z-z1].*[-1/sqrt(2), 1/sqrt(2)]);
        x=-x1-len/sqrt(2);
        z=z1+len/sqrt(2);
      case 2
        x=-x1;
      case 3
        z=z2;
    end
  elseif x>x1
    % distance to the diagonal segment
    d(1)=sum([x-x1, z-z1].*[1, -1]/sqrt(2));
    % distance to the vertical wall
    d(2)=x-x1;
    % distance to the horizontal wall
    d(3)=z2-z;
    [m ind]=min(d);
    switch ind
      case 1
        len=sum([x-x1, z-z1].*[1/sqrt(2), 1/sqrt(2)]);
        x=x1+len/sqrt(2);
        z=z1+len/sqrt(2);
      case 2
        x=x1;
      case 3
        z=z2;
    end
  end
end

TRIAL.posdata(TRIAL.info.epoch,X)=x;
TRIAL.posdata(TRIAL.info.epoch,Z)=-z;
