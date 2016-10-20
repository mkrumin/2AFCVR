%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%trialEnd
%enOfExperiment
%=========================================================================%

function fhandle = run

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

% MK - ball_to_degree and ball_to_room are manually calibrated constants
% now, units in  the getRoomData() are actual centimeters on the ball (if
% using unity gain in the setExperimentPars()).
% these parameters should be calibrated from time to time on every rig
if ~isempty(strfind(RIGNAME, 'ZILLION'))
    BALL_TO_DEGREE =1/7.7;%1/20000*360;
    BALL_TO_ROOM = 1/50;
    PI_OVER_180 = pi/180;
elseif ~isempty(strfind(RIGNAME, 'ZMAZE'))
    BALL_TO_DEGREE =1/8.3;%1/20000*360;
    BALL_TO_ROOM = 1/53;
    PI_OVER_180 = pi/180;
else
    BALL_TO_DEGREE =1/7.7;%1/20000*360;
    BALL_TO_ROOM = 1/50;
    PI_OVER_180 = pi/180;
end
affinityMultiplier=1; % between 0 and 1, 1 - no affinity, 0 - sticking to the center of the corridors
% if affinity multiplier <1, then the mouse will be 'dragged' towards the
% centre of the corridor every time-tick

X=1; %x coordinate
Y=2; %y coordinate
Z=3; %z coordinate
T=4; %T: theta (viewangle)
S=5; %S: speed

%% initializing OpenGL - edit this function to change illumination model etc.
% texname = openGLInit;
openGLInit;

%% Initiating the T-Maze

% starting position at the very beginning of the corridor
TRIAL.posdata(1,Z) = -EXP.minWallsDistance;
nextInterReward=TRIAL.posdata(1,Z)-EXP.rewardDistance;

% isLazy = 0;
% lazyStart = [];
% lazyDur = 0;

count = 1;

if OFFLINE
    MOUSEXY.dax = 0;
    MOUSEXY.day = 0;
    MOUSEXY.dbx = 0;
    MOUSEXY.dby = 0;
end

timeIsUp =0;
trialActive=false; % will be set to 'true' once the animal performs a stop
freezeOver=false;
optiStimON=false;
TRIAL.info.start = clock;

%% Defining and building the visual stimulus

GL.wallTextures = getScene;

%% Starting optogenetic stimulation, if needed
if EXP.optiStim && isequal(EXP.optiStimType, 'TRIAL')
    startOptiStim([TRIAL.info.optiStim, TRIAL.info.optiStim2]);
    optiStimON=true;
end

%% Starting the trial here
trialStartTic=tic;

try
    while (~timeIsUp && ~TRIAL.info.abort)
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
        % gluPerspective(25,1/ar,0.1,100);
        % gluPerspective(50,1/ar,0.1,1.5*EXP.roomLength);
        % gluPerspective(50, 1/ar, 0.1, 10*EXP.roomLength);
        yFOVangle = atan(MYSCREEN.MonitorHeight/2/MYSCREEN.Dist)*2*180/pi;
        aspectRatio = MYSCREEN.MonitorSize/MYSCREEN.MonitorHeight;
        gluPerspective(yFOVangle, aspectRatio, 0.1, 3*EXP.roomLength);

        % Setup modelview matrix: This defines the position, orientation and
        % looking direction of the virtual camera:
        glMatrixMode(GL.MODELVIEW);
        glLoadIdentity;

        % Set background color to 'gray':
        glClearColor(0.5,0.5,0.5,0);
        % % Point lightsource at (1,roomHeight-1,-25)...
        %         glLightfv(GL.LIGHT0,GL.POSITION,[ 1 EXP.roomHeight-1 -EXP.roomLength/2 0 ]);
        
        % Emits white (1,1,1,1) diffuse light:
%         glLightfv(GL.LIGHT0,GL.DIFFUSE, [ 1 1 1 1 ]);
        
        % There's also some white, but weak (R,G,B) = (0.1, 0.1, 0.1)
        % ambient light present:
%         glLightfv(GL.LIGHT0, GL.AMBIENT, [ 0.5 0.5 0.5 1]);
%         glLightfv(GL.LIGHT0, GL.AMBIENT, [1 1 1 1]);
        
        glShadeModel(GL.SMOOTH);
        
        glClear;
        
        if isequal(EXP.stimType, 'REPLAY')
            trialActive=SESSION2REPLAY.allTrials(TRIAL.info.no).trialActive(count);
            freezeOver=SESSION2REPLAY.allTrials(TRIAL.info.no).freezeOver(count);
        elseif (isequal(EXP.stimType, 'INTERLIEVED') && ~TRIAL.info.ClosedLoop)
            trialActive=SESSION.allTrials(TRIAL.info.no-1).trialActive(count);
            freezeOver=SESSION.allTrials(TRIAL.info.no-1).freezeOver(count);
        end
        
        if trialActive
            TRIAL.trialActive(count)=trialActive;
            DrawScene(count);
        end
        
        % Finish OpenGL rendering into PTB window and check for OpenGL errors.
        Screen('EndOpenGL', MYSCREEN.windowPtr(1));

        % Show the sync square
        % alternate between black and white with every frame
        if trialActive
            if freezeOver
                if isequal(EXP.stimType, 'REPLAY')
                    syncState=SESSION2REPLAY.allTrials(TRIAL.info.no).syncState(count);
                elseif (isequal(EXP.stimType, 'INTERLIEVED') && ~TRIAL.info.ClosedLoop)
                    syncState=SESSION.allTrials(TRIAL.info.no-1).syncState(count);
                else
                    syncState=1-syncState;
                end
                Screen('FillRect', MYSCREEN.windowPtr(1), syncState*255, SYNC.rect);
            else
                Screen('FillRect', MYSCREEN.windowPtr(1), 255, SYNC.rect);
                syncState=1;
            end
        else
            Screen('FillRect', MYSCREEN.windowPtr(1), 0, SYNC.rect);
            syncState=0;
        end
        
        TRIAL.syncState(count)=syncState;
        TRIAL.trialActive(count)=trialActive;
        TRIAL.freezeOver(count)=freezeOver;
        TRIAL.optiStimON(count)=optiStimON;
        % snapshot works, but is too slow for real time
        % can be done offline to replay the experiment later
        % SNAPSHOT=Screen('GetImage', MYSCREEN.windowPtr(1), [0 0 1920 1200]);
        
        % glFlush;

        % Show rendered image at next vertical retrace:
        Screen('Flip', MYSCREEN.windowPtr(1));
        
        % Switch to OpenGL rendering again for drawing of next frame:
        Screen('BeginOpenGL', MYSCREEN.windowPtr(1));
        
        %% get new coordinates and update the position
        count = count+1;
        TRIAL.time(count) = GetSecs;
        TRIAL.info.epoch = count;
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
        
        dax = freezeOver*nansum([dax 0]).*BALL_TO_ROOM.*EXP.xGain;
        dbx = freezeOver*nansum([dbx 0]).*BALL_TO_ROOM.*EXP.zGain;
        day = freezeOver*nansum([day 0]).*BALL_TO_DEGREE*PI_OVER_180*EXP.aGain; %unused, because dby encodes the same information
        dby = freezeOver*nansum([dby 0]).*BALL_TO_DEGREE*PI_OVER_180*EXP.aGain;
        
        if isequal(EXP.stimType, 'REPLAY')
            TRIAL.posdata(count,T)=SESSION2REPLAY.allTrials(TRIAL.info.no).posdata(count,T);
            TRIAL.posdata(count,X)=SESSION2REPLAY.allTrials(TRIAL.info.no).posdata(count,X);
            TRIAL.posdata(count,Z)=SESSION2REPLAY.allTrials(TRIAL.info.no).posdata(count,Z);
            TRIAL.posdata(count,S)=SESSION2REPLAY.allTrials(TRIAL.info.no).posdata(count,S);
        elseif (isequal(EXP.stimType, 'INTERLIEVED') && TRIAL.info.ClosedLoop==false)
            TRIAL.posdata(count,T)=SESSION.allTrials(TRIAL.info.no-1).posdata(count,T);
            TRIAL.posdata(count,X)=SESSION.allTrials(TRIAL.info.no-1).posdata(count,X);
            TRIAL.posdata(count,Z)=SESSION.allTrials(TRIAL.info.no-1).posdata(count,Z);
            TRIAL.posdata(count,S)=SESSION.allTrials(TRIAL.info.no-1).posdata(count,S);
        else
            % update x, z positions and viewangle
            TRIAL.posdata(count,T) = TRIAL.posdata(count-1,T) + dby;
            if(abs(TRIAL.posdata(count,T))>(pi))
                TRIAL.posdata(count,T) = -1*((2*pi)-abs(TRIAL.posdata(count,T)))*sign(TRIAL.posdata(count,T));
            end
            TRIAL.posdata(count,X) = TRIAL.posdata(count-1,X) + ...
                dbx*sin(TRIAL.posdata(count,T)) + dax*cos(TRIAL.posdata(count,T));
            TRIAL.posdata(count,Z) = TRIAL.posdata(count-1,Z) - ...
                dbx*cos(TRIAL.posdata(count,T)) + dax*sin(TRIAL.posdata(count,T));
            TRIAL.posdata(count,S) = norm([dax, dbx])/(TRIAL.time(count)-TRIAL.time(count-1));
            % MK - implementing "affinity" to the center of the corridor
            zMiddle=-(EXP.roomLength-EXP.corridorWidth/2); % z-coordinate of the middle of the horizontal corridor
            if abs(TRIAL.posdata(count,Z)-zMiddle)<abs(TRIAL.posdata(count, X)) || (TRIAL.posdata(count,Z)-zMiddle)<=0
                % if is in horiz corridor stick to horiz corridor center
                TRIAL.posdata(count,Z)=(TRIAL.posdata(count,Z)-zMiddle)*affinityMultiplier+zMiddle;
            else
                % if in the main corridor stick to the middle of it
                TRIAL.posdata(count,X)=TRIAL.posdata(count,X)*affinityMultiplier;
            end
        end
        
%         fprintf('X = %d\t Z = %d\t T = %d\n', TRIAL.posdata(count,X), TRIAL.posdata(count,Z), TRIAL.posdata(count,T))
        
        %% check if out of the room and apply corrections (if needed)
        % MK these are T-maze specific functions. We can introduce more
        % cases inside these routines if needed
        if ~isequal(EXP.stimType, 'REPLAY') && trialActive && EXP.restrictInRoom && isOutOfMaze(EXP.minWallsDistance) && ...
                ~(isequal(EXP.stimType, 'INTERLIEVED') && TRIAL.info.ClosedLoop==false)
            keepInside(EXP.minWallsDistance);
        end
        
        %% check if the head direction should be restricted and apply the restriction
        % MK these are T-maze specific functions. We can introduce more
        % cases inside these routines if needed
        if ~isequal(EXP.stimType, 'REPLAY') && trialActive && EXP.restrictDirection ...
                && ~(isequal(EXP.stimType, 'INTERLIEVED') && TRIAL.info.ClosedLoop==false)
            if abs(TRIAL.posdata(count, T))>EXP.restrictionAngle
                TRIAL.posdata(count, T)=sign(TRIAL.posdata(count, T))*EXP.restrictionAngle;
            end
        end
        
        %% check if not going backwards in the main corridor
        % MK - timeout the animal if it goes backwards (only in the main
        % corridor)
        
        if trialActive && syncState
            if (-TRIAL.posdata(count,Z)<(EXP.roomLength-EXP.corridorWidth-10)) && ...
                    abs(TRIAL.posdata(count, T))>pi/2 && TRIAL.posdata(count, S)>0
                timeOut;
                fhandle = @trialEnd;
                TRIAL.info.outcome='FAIL';
                timeIsUp=1;
                disp([num2str(count), ' FAIL']);
                fprintf('Wrong way - go North!\n');
            end
        end
        
        %% check if not moved significantly
        %         if(count<10)
        %             speed = mean(TRIAL.posdata(1:count,S));
        %         else
        %             speed = mean(TRIAL.posdata(count-9:count,S));
        %         end
        
        %% checking if to start showing the maze
        blankTime = toc(trialStartTic);
        % next line is a hack to prevent crashing during replay;
        if isequal(EXP.stimType, 'REPLAY') && ~exist('mazeOnTic', 'var')
            mazeOnTic = trialStartTic;
        end
        if(blankTime >= EXP.grayScreenDur) && ~trialActive
            mazeOnTic = tic;
            trialActive=true;
            giveReward(count, 'START');
        end
        
        %% checking if it's time to start a timed optical stimulation (and check if it is finished)
        if EXP.optiStim && isequal(EXP.optiStimType, 'TIME')
            timeFromStart=toc(trialStartTic);
            if (timeFromStart-EXP.stopTime>=EXP.optiStimOnsetTime) && (timeFromStart-EXP.stopTime-EXP.optiStimOnsetTime<EXP.optiStimDuration)
                doOptiStim;
            end
        end
        
        %% checking if target reached, or wrong target reached
        currentPos = [TRIAL.posdata(count,X) TRIAL.posdata(count,Y) TRIAL.posdata(count,Z)];
        
        if syncState && trialActive && currentPos(3)<=nextInterReward
            giveReward(count, 'INTERMEDIATE');
            nextInterReward=nextInterReward-EXP.rewardDistance;
        end
        
        if syncState && trialActive &&...
                TRIAL.posdata(count,Z)<-(EXP.roomLength-EXP.corridorWidth) &&...
                abs(TRIAL.posdata(count,X))>=EXP.roomWidth/2-EXP.corridorWidth
            if isequal(TRIAL.info.stimulus, 'BOTH') ||...
                    (TRIAL.posdata(count, X)>=0 && isequal(TRIAL.info.stimulus, 'RIGHT')) ||...
                    (TRIAL.posdata(count, X)<=0 && isequal(TRIAL.info.stimulus, 'LEFT'))
                
                giveReward(count, 'CORRECT')
                TRIAL.info.outcome='CORRECT';
                disp('CORRECT');
            else
                giveReward(count, 'WRONG')
                TRIAL.info.outcome='WRONG';
                disp('WRONG');
            end
            fhandle = @trialEnd;
            break;
        end
        
        %% checking if freeze is over
        
        if ~isequal(EXP.stimType, 'REPLAY') && trialActive && ~freezeOver ...
                && ~(isequal(EXP.stimType, 'INTERLIEVED') && ~TRIAL.info.ClosedLoop)
            if toc(mazeOnTic)>=EXP.freezeDuration
                freezeOver=true;
            end
        end
        
        %% checking timeout and user abort
        % checking for timeout only after the STOP was performed by the
        % mouse
        if ~isequal(EXP.stimType, 'REPLAY') && syncState && trialActive && (toc(mazeOnTic)>EXP.maxTrialDuration) || ...
                isequal(EXP.stimType, 'REPLAY') && count==length(SESSION2REPLAY.allTrials(TRIAL.info.no).posdata(:,T)) || ...
                ~(isequal(EXP.stimType, 'INTERLIEVED') && TRIAL.info.ClosedLoop==false) && syncState && trialActive && (toc(mazeOnTic)>EXP.maxTrialDuration) || ...
                (isequal(EXP.stimType, 'INTERLIEVED') && TRIAL.info.ClosedLoop==false) && count==length(SESSION.allTrials(TRIAL.info.no-1).posdata(:,T))
            timeOut;
            fhandle = @trialEnd;
            TRIAL.info.outcome='TIMEOUT';
            timeIsUp = 1;
            disp([num2str(count), ' TIMEOUT']);
        end
        
        if checkKeyboard
            TRIAL.info.abort =1;
            fhandle = @trialEnd;
            TRIAL.info.outcome='USER ABORT';
            disp([num2str(count), ' USER ABORT']);
        end
        
        
    end
    
catch ME
    fprintf(['exception : ' ME.message '\n']);
    fprintf(['line #: ' num2str(ME.stack(1,1).line)]);
    
    %           glDeleteTextures(length(texname),texname);
    
    %           Screen('EndOpenGL', MYSCREEN.windowPtr);
    Screen('CloseAll');
    ListenChar(0);
    psychrethrow(psychlasterror);
    
end %try..catch..

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