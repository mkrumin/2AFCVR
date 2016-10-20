function DrawScene(count, alphaValue)

global ROOM
global GL
global EXP
global TRIAL
global SESSION

X=1; %x coordinate
Y=2; %y coordinate
Z=3; %z coordinate
T=4; %T: theta (viewangle)
S=5; %S: speed

glPushMatrix;
% glRotated (0,1,0,0); % to look a little bit downward

glRotated(TRIAL.posdata(count,T)/pi*180,0,1,0);

glTranslated(-TRIAL.posdata(count,X),0,-TRIAL.posdata(count,Z));

% glTranslated (-dax,0,dbx);
% implement drawscene
% DrawScene()

% glDisable(GL.LIGHTING);
glEnable(GL.BLEND);
% glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

if nargin<2
    mazeStartCount = find(TRIAL.trialActive, 1, 'first');
    dCount = count-mazeStartCount+1;
    if ~isfield(EXP, 'fadeInFrames')
        EXP.fadeInFrames = 30;
    end
    if dCount<=EXP.fadeInFrames
        alphaValue = (-cos(dCount/(EXP.fadeInFrames*2)*2*pi)+1)/2;
    else
        alphaValue = 1;
    end
end

glBlendColor(0, 0, 0, alphaValue);
glBlendFunc(GL.CONSTANT_ALPHA, GL.ONE_MINUS_CONSTANT_ALPHA);
glMaterialfv(GL.FRONT_AND_BACK, GL.AMBIENT, [1 1 1 1]);

for k=1:ROOM.nOfWalls
  texInd = getTextureIndex(GL.wallTextures{k}, SESSION.textures);
  wallface(ROOM.v, ROOM.order(k,:),ROOM.normals(k,:), GL.texname(texInd), ROOM.wrap{k});
end

% glMaterialfv(GL.FRONT_AND_BACK, GL.AMBIENT, [1 0 1 1]);
% for k=1:ROOM.nOfWalls
%   texInd = getTextureIndex(GL.wallTextures{k}, SESSION.textures);
%   texInd = 7;
%   wallface(ROOM.v, ROOM.order(k,:),ROOM.normals(k,:), GL.texname(texInd), ROOM.wrap{k});
% end

glDisable(GL.BLEND);



% glEnable(GL.LIGHTING);

glPopMatrix;
