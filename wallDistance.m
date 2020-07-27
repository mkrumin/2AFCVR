function [dL, dR, dF] = wallDistance(pos)

global EXP;

X=1; %x coordinate
Y=2; %y coordinate
Z=3; %z coordinate
T=4; %T: theta (viewangle)
S=5; %S: speed

x = pos(X);
z = - pos(Z);
th = pos(T);

%% 
% EXP = loadMK031;
x1=EXP.corridorWidth/2; % (abs) coordinate of the main corridor wall
x2=EXP.roomWidth/2; % (abs) coordinate of the end of the side corridors
z0 = 0; % beginning
z1=EXP.roomLength-EXP.corridorWidth; % coordinate of the near wall of the side corridor
z2=EXP.roomLength; % coordinate of the end wall

xx = [-x1, -x1, -x2, -x2, x2, x2, x1, x1, -x1];
zz = [z0, z1, z1, z2, z2, z1, z1, z0, z0];

scalingFactor = 5;
padding = 10;

xx = xx * scalingFactor; % transform to millimeters
zz = zz * scalingFactor; % transform to millimeters

minX = min(xx);
minZ = min(zz);

xx = xx - minX + padding;
zz = zz - minZ + padding;
nX = max(xx) + padding;
nZ = max(zz) + padding;

%%
% x = (rand - 0.5)*EXP.corridorWidth;
% z = rand*EXP.roomLength;
% th = (rand - 0.5) *  pi;
% th = 2*pi/6;

xPix = x * scalingFactor - minX +padding;
zPix = z * scalingFactor - minZ + padding;

% this is the vector of mouse heading
nVector = [cos(-th + pi/2), sin(-th + pi/2)];

bw = poly2mask(xx,zz,nZ,nX);
% cla;
% imshow(bw)
% axis xy
% hold on
% plot(xx,zz,'b','LineWidth',2)
% plot(xPix, zPix, 'ro')
u = nVector(1);
v = nVector(2);
% quiver(xPix, zPix, u, v, scalingFactor*15, 'MaxHeadSize', 1, 'LineWidth', 2);
% hold off;

angleRange = 45:5:120;
t = 0:0.5:10*scalingFactor;
dL = Inf;
% Left whisker pad
for rotAngle = -angleRange
    phi = -rotAngle * pi / 180; % counter clockwise rotation is defined positive
    nNew = [cos(phi),  - sin(phi); sin(phi), cos(phi)] * [u, v]';
    uNew = nNew(1);
    vNew = nNew(2);
%     quiver(xPix, zPix, uNew, vNew, scalingFactor*10, 'MaxHeadSize', 0, 'Color', 'r');
    xLine = xPix + t*uNew;
    zLine = zPix + t*vNew;
    profile = interp2(1:nX, 1:nZ, single(bw), xLine, zLine, 'linear');
    delta = [0, abs(diff(profile > 0.5))];
    tCrossing = t(find(delta, 1, 'first'));
    if ~isempty(tCrossing)
%         plot(xPix + uNew*tCrossing, zPix + vNew*tCrossing, 'c.', 'MarkerSize', 16);
        if dL > tCrossing 
            % keep the record of the shortest distance and direction
            dL = tCrossing;
            uLeft = uNew;
            vLeft = vNew;
        end
    end
end
% Right whisker pad
dR = Inf;
for rotAngle = angleRange
    phi = -rotAngle * pi / 180; % counter clockwise rotation is defined positive
    nNew = [cos(phi),  - sin(phi); sin(phi), cos(phi)] * [u, v]';
    uNew = nNew(1);
    vNew = nNew(2);
%     quiver(xPix, zPix, uNew, vNew, scalingFactor*10, 'MaxHeadSize', 0, 'Color', 'g');
    xLine = xPix + t*uNew;
    zLine = zPix + t*vNew;
    profile = interp2(1:nX, 1:nZ, single(bw), xLine, zLine, 'linear');
    delta = [0, abs(diff(profile > 0.5))];
    tCrossing = t(find(delta, 1, 'first'));
    if ~isempty(tCrossing)
%         plot(xPix + uNew*tCrossing, zPix + vNew*tCrossing, 'c.', 'MarkerSize', 16);
        if dR > tCrossing 
            % keep the record of the shortest distance and direction
            dR = tCrossing;
            uRight = uNew;
            vRight = vNew;
        end
    end
end
% Distance to a wall in front of the mouse
dF = Inf;
for rotAngle = -20:10:20
    phi = -rotAngle * pi / 180; % counter clockwise rotation is defined positive
    nNew = [cos(phi),  - sin(phi); sin(phi), cos(phi)] * [u, v]';
    uNew = nNew(1);
    vNew = nNew(2);
%     quiver(xPix, zPix, uNew, vNew, scalingFactor*10, 'MaxHeadSize', 0, 'Color', 'g');
    xLine = xPix + t*uNew;
    zLine = zPix + t*vNew;
    profile = interp2(1:nX, 1:nZ, single(bw), xLine, zLine, 'linear');
    delta = [0, abs(diff(profile > 0.5))];
    tCrossing = t(find(delta, 1, 'first'));
    if ~isempty(tCrossing)
%         plot(xPix + uNew*tCrossing, zPix + vNew*tCrossing, 'c.', 'MarkerSize', 16);
        if dF > tCrossing 
            % keep the record of the shortest distance and direction
            dF = tCrossing;
            uFront = uNew;
            vFront = vNew;
        end
    end
end

% if dL < dR
%     plot(xPix + uLeft*dL, zPix + vLeft*dL, 'm.', 'MarkerSize', 30);
% elseif dL > dR
%     plot(xPix + uRight*dR, zPix + vRight*dR, 'm.', 'MarkerSize', 30);
% else
%     ; % do nothing
% end

dL = dL/scalingFactor;
dR = dR/scalingFactor;
dF = dF/scalingFactor;

% title({sprintf('X = %4.2f [cm], Z = %4.2f [cm], \\theta = %2.0f [deg]', x, z, th*180/pi); ...
%     sprintf('dLeft = %4.2f [cm], dRight = %4.2f [cm]', dL, dR)});

return;
%%
% the equation of line along the "whiskers' axis" - the line running
% through the mouse position and perpendicular to its heading

% findind the limits of t to cover the whole maze image
tLims = [-x, z*v/u, nX - x, (z-nZ)*v/u];
tMin = max(tLims(tLims<0)); % a negative t closest to 0
tMax = min(tLims(tLims>0)); % a positive t closest to 0

t = floor(tMin):0.1:ceil(tMax);
xLine = t + x;
zLine = -t*u/v+z;

% plot(xLine, zLine, '.')

profile = interp2(1:nX, 1:nZ, single(bw), xLine, zLine, 'linear');
delta = [0, abs(diff(profile > 0.5))];
% find first negative t and frst positive t, whith delta == 1
tCrosses = t(delta~=0);
tNegative = max(tCrosses(tCrosses < 0));
tPositive = min(tCrosses(tCrosses > 0));

xNeg = tNegative + x;
zNeg = -tNegative*u/v + z;
xPos = tPositive + x;
zPos = -tPositive*u/v + z;

% checking which one is on the left of the mouse, and whic one is on the
% right of the mouse
% The third component of the cross-product will be positive for the left
% side, and negative for the right side
crPos = cross([u, v, 0], [xPos - x, zPos - z, 0]);
crNeg = cross([u, v, 0], [xNeg - x, zNeg - z, 0]);

if crPos(3) > 0
    % [xPox, zPos] is the left side
    dL = sqrt(sum([xPos - x, zPos - z].^2));
    dR = sqrt(sum([xNeg - x, zNeg - z].^2));
%     plot(xPos, zPos, '.g', 'MarkerSize', 20)
%     plot(xNeg, zNeg, '.m', 'MarkerSize', 20)
else
    % which means crPos(3)<0 and crNeg(3) >0
    dR = sqrt(sum([xPos - x, zPos - z].^2));
    dL = sqrt(sum([xNeg - x, zNeg - z].^2));
%     plot(xPos, zPos, '.m', 'MarkerSize', 20)
%     plot(xNeg, zNeg, '.g', 'MarkerSize', 20)
end
dL = dL/scalingFactor;
dR = dR/scalingFactor;

% hold off
% axis xy
