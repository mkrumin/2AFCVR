%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

function fhandle = trialEnd

global TRIAL;
global SESSION;
global EXP;
global DIRS;
global ScanImageUDP;
global EyeCameraUDP;
global TimelineUDP;
global OptiStimUDP;
global OFFLINE
global EXPREF
global SAVE2SERVER

% save all the code in a zip archive if this is the first trial of the session
% it would probably be better to move this to the beginning of the session
% (otherwise there is a larger inter-stimulus interval after the first
% trial

[~, basename, ~] = fileparts(DIRS.fileName);

if TRIAL.info.no==1
    %     zip(fullfile(DIRS.serverFolder, [basename, '_code']), '*.m*');
    zip(fullfile(DIRS.localFolder, [basename, '_code']), '*.m*');
end

if TRIAL.info.no > 0
    % cutting out excessive zeros
    TRIAL.posdata=TRIAL.posdata(1:TRIAL.info.epoch, :);
    TRIAL.time=TRIAL.time(1:TRIAL.info.epoch, :);
    
    s = fullfile(DIRS.serverFolder, sprintf('%s_trial%03d', basename, TRIAL.info.no));
    slocal = fullfile(DIRS.localFolder, sprintf('%s_trial%03d', basename, TRIAL.info.no));
    try
        save(slocal, 'TRIAL', 'EXP');
    catch
        warning('There was a problem saving locally to %s', DIRS.localFolder);
    end
    
    SESSION.allTrials(TRIAL.info.no)=TRIAL;
    s = fullfile(DIRS.serverFolder, DIRS.fileName);
    slocal = fullfile(DIRS.localFolder, DIRS.fileName);
    if SAVE2SERVER
        try
            save(s, 'EXP', 'SESSION');
        catch
            warning('There was a problem saving to the \\zserver');
        end
    end
    try
        save(slocal, 'EXP', 'SESSION');
    catch
        warning('There was a problem saving locally');
    end
end

if ~OFFLINE
    stopAllDaq;
    
    [animalID, iseries, iexp] = dat.expRefToMpep(EXPREF);
    istim=TRIAL.info.no;
    irepeat=1;
    
    msgString = sprintf('StimEnd %s %d %d %d %d', animalID, iseries, iexp, irepeat, istim); %%%
    
    pnet(ScanImageUDP, 'write', msgString);
    pnet(ScanImageUDP, 'writePacket');
    
    pnet(EyeCameraUDP, 'write', msgString);
    pnet(EyeCameraUDP, 'writePacket');
    
    pnet(TimelineUDP, 'write', msgString);
    pnet(TimelineUDP, 'writePacket');
    
    msgStruct = struct('instruction', 'ZapStop', 'ExpRef', EXPREF);
    msgJson = savejson('msg', msgStruct);
    
    pnet(OptiStimUDP, 'write', msgJson);
    pnet(OptiStimUDP, 'writePacket');

end

if TRIAL.info.no == EXP.maxNTrials || TRIAL.info.abort == 1
    if SAVE2SERVER
        % save the code to the server
        zip(fullfile(DIRS.serverFolder, [basename, '_code']), '*.m*');
        % save the data to the server
        s = fullfile(DIRS.serverFolder, DIRS.fileName);
        try
            save(s, 'EXP', 'SESSION');
        catch
            warning('There was a problem saving to the \\zserver');
        end
    end
    fhandle = @endOfExperiment;
else
    fhandle = @prepareNextTrial;
end

