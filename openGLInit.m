function texname = openGLInit

global MYSCREEN
global GL
global SESSION

% Is the script running in OpenGL Psychtoolbox?
AssertOpenGL;

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL;

tic
Screen('BeginOpenGL', MYSCREEN.windowPtr(1));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(2));
% Screen('BeginOpenGL', MYSCREEN.windowPtr(3));

% Get the aspect ratio of the screen:
% ar=MYSCREEN.screenRect(1,4)/(MYSCREEN.screenRect(1,3));

% Turn on OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.
glEnable(GL.LIGHTING);

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources.
% glEnable(GL.LIGHT0);

% Enable two-sided lighting - Back sides of polygons are lit as well.
% glLightModelfv(GL.LIGHT_MODEL_TWO_SIDE,GL.TRUE);
LInt=1;
glLightModelfv(GL.LIGHT_MODEL_AMBIENT,[LInt LInt LInt 1]);

% Enable proper occlusion handling via depth tests:
glEnable(GL.DEPTH_TEST);

% Define the walls light reflection properties by setting up reflection
% coefficients for ambient, diffuse and specular reflection:
% glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [ 0 LInt LInt 1 ]);
% glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [ 1 1 1 1 ]);


% 10-03 AS: This loads a texture from file, rather than creating locally.

% 10-06 AA: textureFile contains 2 variables 'textures' and 'tx'
% textures: is an array of structures representing different textures.
%           each item has a 'name' and a 'matrix'(64x64) field
%           (e.g. textures(1,1).name='gray', textures(1,1).matrix)
% tx:    is a structure of indices of different textures (i.e. tx.GRAY = 1,
%        tx.WHITENOISE = 2; tx.COSGRATING =3; )
% both of these structures will be extended as needed

% load(EXP.textureFile);
textures=SESSION.textures;

% Enable 2D texture mapping,
glEnable(GL.TEXTURE_2D);

% Generate textures and store their handles in vector 'texname'
texname=glGenTextures(length(textures));

% glTexSubImage2D(GL_TEXTURE_2D, 0, 0, w, h, GL_RGB, GL_UNSIGNED, texname)

% Setup textures for all six sides of cube:
for i=1:length(textures),
    % Enable i'th texture by binding it:
    glBindTexture(GL.TEXTURE_2D,texname(i));
    
    f=max(min(255*(textures(i).matrix),255),0);
    %     tx=repmat(flipdim(f,1),[ 1 1 3 ]);
    %     tx=permute(flipdim(uint8(tx),1),[ 3 2 1 ]);
    tx=repmat(f,[ 1 1 3 ]);
    tx=permute(uint8(tx),[ 3 2 1 ]);
    
    % Assign image in matrix 'tx' to i'th texture:
    glTexImage2D(GL.TEXTURE_2D,0,GL.RGB,size(f,2),size(f,1),0,GL.RGB,GL.UNSIGNED_BYTE,tx);
    %    glTexImage2D(GL.TEXTURE_2D,0,GL.ALPHA,256,256,1,GL.ALPHA,GL.UNSIGNED_BYTE,noisematrix);
    
    % Setup texture wrapping behaviour:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_S,GL.REPEAT);%GL.CLAMP_TO_EDGE);%GL.REPEAT);%
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_WRAP_T,GL.REPEAT);%GL.CLAMP_TO_EDGE);
    % Setup filtering for the textures:
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MAG_FILTER,GL.LINEAR);
    glTexParameterfv(GL.TEXTURE_2D,GL.TEXTURE_MIN_FILTER,GL.LINEAR);
    
    % Choose texture application function: It shall modulate the light
    % reflection properties of the the cubes face:
    glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);
end

GL.texname = texname;
