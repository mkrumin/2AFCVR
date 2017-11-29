function createExpRef()

global OFFLINE
global EXP
global EXPREF
global initParams % only used in fakerun.m

%% animal (subject) name

if OFFLINE
    animalName = 'fake';
elseif ~isempty(initParams)
    animalName=initParams.animalName;
else
    animalName = input('Please enter mouse name: ','s');
end

if isempty(animalName)
    animalName = 'fake';
end

EXP = setExperimentPars(animalName);

%% session name (by default using the currnet time in HHMM format)
sessionName = '';
if OFFLINE
    sessionName = '9999';
elseif ~isempty(initParams)
    sessionName=initParams.sessionName;
% else
%     sessionName = input('Please enter session id: ','s');
end

if isempty(sessionName)
    sessionName = datestr(now, 'HHMM');
end

sessionName = str2num(sessionName);

%% current date
dateString = datestr(now, 'yyyy-mm-dd');

%% generate ExpRef

EXPREF = dat.constructExpRef(animalName, dateString, sessionName);
EXP.expRef = EXPREF;
