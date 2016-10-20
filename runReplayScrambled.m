%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%trialEnd
%enOfExperiment
%=========================================================================%

function fhandle = runReplayScrambled

global GL;
global EXP;
global TRIAL;
global SESSION;
global SESSION2REPLAY;
global MYSCREEN;
global SYNC;
% global ROOM;
global SNAPSHOT

global BallUDPPort;
global MOUSEXY;
global OFFLINE;
global RIGNAME;

ListenChar(2);

%% initializing OpenGL - edit this function to change illumination model etc.
% texname = openGLInit;
openGLInit;

%% Initiating the T-Maze

if OFFLINE
    MOUSEXY.dax = 0;
    MOUSEXY.day = 0;
    MOUSEXY.dbx = 0;
    MOUSEXY.dby = 0;
end

TRIAL.info.start = clock;

%% Starting the trial here
nCounts = size(TRIAL.posdata, 1);
nChars = 0;
try
    for count = 1:nCounts
        fprintf(repmat('\b', 1, nChars));
        nChars = fprintf('Frame %d/%d', count, nCounts);
        TRIAL.info.epoch = count;
        %     for numScreens = 1:2
        %         % Set projection matrix: This defines a perspective projection,
        %         % corresponding to the model of a pin-hole camera - which is a good
        %         % approximation of the human eye and of standard real world cameras --
        %         % well, the best aproximation one can do with 3 lines of code ;-)
        %         if numScreens == 1
        %             glViewport(0, 0, 200,200)%MYSCREEN.screenRect(3)/3, MYSCREEN.screenRect(4))
        %         elseif numScreens == 2
        %             glViewport(201,201,200,200)%1+MYSCREEN.screenRect(3)/3, 0, MYSCREEN.screenRect(3)/3, MYSCREEN.screenRect(4))
        %         end
        glMatrixMode(GL.PROJECTION);
        glLoadIdentity;
        % Field of view is 50 degrees from line of sight. Objects closer than
        % 0.1 distance units or farther away than 100 distance units get clipped
        % away, aspect ratio is adapted to the monitors aspect ratio:
        yFOVangle = atan(MYSCREEN.MonitorHeight/2/MYSCREEN.Dist)*2*180/pi;
        aspectRatio = MYSCREEN.MonitorSize/MYSCREEN.MonitorHeight;
        gluPerspective(yFOVangle, aspectRatio, 0.1, 3*EXP.roomLength);

        % Setup modelview matrix: This defines the position, orientation and
        % looking direction of the virtual camera:
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;

        % Set background color to 'gray' (actually, cyan)
        glClearColor(0.5,0.5,0.5,0);
        
        glShadeModel(GL.SMOOTH);
        
        glClear;
        
        % Defining which textures to use
        GL.wallTextures = getSceneScrambled(count);

        alphaValue = TRIAL.alpha(count);
        DrawScene(count, alphaValue);
        
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', MYSCREEN.windowPtr(1));

        % Show the sync square
        % alternate between black and white with every frame
        Screen('FillRect', MYSCREEN.windowPtr(1), TRIAL.syncState(count)*255, SYNC.rect);
        

        % Show rendered image at next vertical retrace:
        Screen('Flip', MYSCREEN.windowPtr(1));
        TRIAL.time(count) = GetSecs;

        % snapshot works, but is too slow for real time
        % can be done offline to replay the experiment later
        % SNAPSHOT=Screen('GetImage', MYSCREEN.windowPtr(1), [0 0 1920 1200]);
        
        % glFlush;

        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', MYSCREEN.windowPtr(1));
        
        %% get new coordinates and update the position

        if ~OFFLINE
            [ballTime, dax, dbx, day, dby] = getBallDeltas(BallUDPPort);
        else
            getNonBallDeltas;
            ballTime = TRIAL.time(count);
            dax = MOUSEXY.dax;
            day = MOUSEXY.day;
            dbx = MOUSEXY.dbx;
            dby = MOUSEXY.dby;
        end
        
        balldata=[ballTime, dax, dbx, day, dby];
        %         TRIAL.balldata = [TRIAL.balldata; balldata];
        TRIAL.balldata(count, :) = balldata';
        
        %% checking user abort

        if checkKeyboard
            fhandle = @trialEnd;
            TRIAL.info.outcome='USER ABORT';
            disp([num2str(count), ' USER ABORT']);
            break;
        end
        
        
    end
    
catch ME
    fprintf('\n');
    fprintf(['exception : ' ME.message '\n']);
    fprintf(['line #: ' num2str(ME.stack(1,1).line)]);
    
    %           glDeleteTextures(length(texname),texname);
    
    %           Screen('EndOpenGL', MYSCREEN.windowPtr);
    Screen('CloseAll');
    ListenChar(0);
    psychrethrow(psychlasterror);
    
end %try..catch..

fprintf('\n');

fhandle = @trialEnd;

ListenChar(0);
Priority(0);

% Delete all allocated OpenGL textures:
glDeleteTextures(length(GL.texname), GL.texname);

Screen('EndOpenGL', MYSCREEN.windowPtr(1));

heapTotalMemory = java.lang.Runtime.getRuntime.totalMemory;
heapFreeMemory = java.lang.Runtime.getRuntime.freeMemory;

if(heapFreeMemory < (heapTotalMemory*0.1))
    java.lang.Runtime.getRuntime.gc;
    fprintf('\n garbage collection \n');
end

end