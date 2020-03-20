%% this is a sandbox to play around with the whiskers guided T-Maze data

animals = {...
%     'MK040'; ...
    'MK041'; ...
%     'MK042'; ...
%     'MK043'; ...
%     'MK044';...
    };
% animals = {'MK044'};
dates = datenum('2020-03-17'):datenum(now);

for iAnimal = 1:length(animals)
    animalName = animals{iAnimal};
    hF = figure('Name', animalName);
%     set(hF, 'Position', [267 468 1125 527]);
    % expDate = '2020-02-24';
    [allExpRefs, allDateNums, iExp] = dat.listExps(animalName);
    validDates = unique(intersect(allDateNums, dates));
    nDates = length(validDates);
    nRows = floor(sqrt(nDates));
    nColumns = ceil(nDates/nRows);
    for iDate = 1:nDates
        ExpRef = allExpRefs(allDateNums == validDates(iDate));
        TM = TMaze(ExpRef{1});
        for i = 2:length(ExpRef)
            TM = Merge(TM, TMaze(ExpRef{i}));
        end
        TM = TM.getPCData;
        TM = TM.fitPC;
        ax = subplot(nRows, nColumns, iDate);
        TM.showPC(ax);
    end
end


%% 
idxHaptic = TM.SESSION.useWhiskerControl;
idxVisual = TM.SESSION.showWalls;

idxHaptic = idxHaptic(1:TM.nTrials);
idxVisual = idxVisual(1:TM.nTrials);


idxR = ismember(TM.SESSION.stimSequence, 'RIGHT')';
idxL = ismember(TM.SESSION.stimSequence, 'LEFT')';
idxR = idxR(1:end-1);
idxL = idxL(1:end-1);

X = 1;
Z = 3;
TH = 4;

posData = {TM.SESSION.allTrials.posdata};
ballData = {TM.SESSION.allTrials.balldata};

N = 5;
b = hamming(N);
b = b/sum(b);
a = 1;

xPos = cell(TM.nTrials, 1);
zPos = cell(TM.nTrials, 1);
thPos = cell(TM.nTrials, 1);
xBall = cell(TM.nTrials, 1);
zBall = cell(TM.nTrials, 1);
thBall = cell(TM.nTrials, 1);
dxBall = cell(TM.nTrials, 1);
dzBall = cell(TM.nTrials, 1);
dthBall = cell(TM.nTrials, 1);

for iTrial = 1:TM.nTrials
    xPos{iTrial} = [posData{iTrial}(:, X)];
    zPos{iTrial} = [-posData{iTrial}(:, Z)];
    thPos{iTrial} = [posData{iTrial}(:, TH) * 180 / pi];
    
    %     xPos{iTrial} = [posData{iTrial}(:, X); NaN];
    %     zPos{iTrial} = [-posData{iTrial}(:, Z); NaN];
    %     thPos{iTrial} = [posData{iTrial}(:, TH) * 180 / pi; NaN];
    
    xPos{iTrial} = filter(b, a, xPos{iTrial});
    zPos{iTrial} = filter(b, a, zPos{iTrial});
    thPos{iTrial} = filter(b, a, thPos{iTrial});
    
    xBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 2)])/65;
    zBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 3)])/65;
    thBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 4)])/60;
    %     xBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 2); NaN])/65;
    %     zBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 3); NaN])/65;
    %     thBall{iTrial} = -cumsum([0; 0; ballData{iTrial}(3:end, 4); NaN])/60;
    
    %     thBall{iTrial} = cumsum(ballData{iTrial}(:, 5));
    
    xBall{iTrial} = filter(b, a, xBall{iTrial});
    zBall{iTrial} = filter(b, a, zBall{iTrial});
    thBall{iTrial} = filter(b, a, thBall{iTrial});
    
    dxBall{iTrial} = [0; diff(xBall{iTrial})]*60;
    dzBall{iTrial} = [0; diff(zBall{iTrial})]*60;
    dthBall{iTrial} = [0; diff(thBall{iTrial})]*60;
    
    % resample here
    reN = 5;
    xPos{iTrial} = resample(xPos{iTrial}, 1, reN);
    zPos{iTrial} = resample(zPos{iTrial}, 1, reN);
    thPos{iTrial} = resample(thPos{iTrial}, 1, reN);
    xBall{iTrial} = resample(xBall{iTrial}, 1, reN);
    zBall{iTrial} = resample(zBall{iTrial}, 1, reN);
    thBall{iTrial} = resample(thBall{iTrial}, 1, reN);
    dxBall{iTrial} = resample(dxBall{iTrial}, 1, reN);
    dzBall{iTrial} = resample(dzBall{iTrial}, 1, reN);
    dthBall{iTrial} = resample(dthBall{iTrial}, 1, reN);
end

%%
titleStr{1} = 'No Whiskers';
titleStr{2} = 'With Whiskers';
titleStr{3} = '';
titleStr{4} = '';

yTextStr{1} = 'Gray Screen';
yTextStr{2} = '';
yTextStr{3} = 'T-Maze ON';
yTextStr{4} = '';

idx{1} = ~idxHaptic & ~idxVisual;
idx{2} = idxHaptic & ~idxVisual;
idx{3} = ~idxHaptic & idxVisual;
idx{4} = idxHaptic & idxVisual;

%%
figure
nPlots = 4;
nRows = 2;
nColumns = 2;

xData = thPos;
yData = zPos;

xlabelStr{1} = '';
xlabelStr{2} = '';
xlabelStr{3} = '\theta maze [deg]';
xlabelStr{4} = '\theta maze [deg]';

ylabelStr{1} = 'z maze [cm]';
ylabelStr{2} = '';
ylabelStr{3} = 'z maze[cm]';
ylabelStr{4} = '';

for iPlot = 1:nPlots
    idxBlue = idx{iPlot} & idxR;
    idxRed = idx{iPlot} & idxL;
    
    ax(iPlot) = subplot(nRows, nColumns, iPlot);
    xx = cell2mat(xData(idxBlue));
    yy = cell2mat(yData(idxBlue));
    plot(xx, yy, 'b.');
    hold on;
    xx = cell2mat(xData(idxRed));
    yy = cell2mat(yData(idxRed));
    plot(xx, yy, 'r.');
    
    histogram(cellfun(@median, xData(idxBlue)), -60:6:60);
    histogram(cellfun(@median, xData(idxRed)), -60:6:60);
    title(titleStr{iPlot});
    ylabel({yTextStr{iPlot}; ylabelStr{iPlot}});
    xlabel(xlabelStr{iPlot});
    %     axis equal tight
end
linkaxes(ax)

%% 
figure
nPlots = 4;
nRows = 2;
nColumns = 2;

xData = xPos;
yData = dxBall;

xlabelStr{1} = '';
xlabelStr{2} = '';
xlabelStr{3} = 'x maze [cm]';
xlabelStr{4} = 'x maze [cm]';

ylabelStr{1} = 'dx/dt ball [cm/s]';
ylabelStr{2} = '';
ylabelStr{3} = 'dx/dt ball[cm]';
ylabelStr{4} = '';

for iPlot = 1:nPlots
    idxBlue = idx{iPlot} & idxR;
    idxRed = idx{iPlot} & idxL;
    
    ax(iPlot) = subplot(nRows, nColumns, iPlot);
    xx = cell2mat(xData(idxBlue));
    yy = cell2mat(yData(idxBlue));
    plot(xx, yy, 'b.');
    hold on;
    xx = cell2mat(xData(idxRed));
    yy = cell2mat(yData(idxRed));
    plot(xx, yy, 'r.');
    
%     histogram(cellfun(@median, xData(idxBlue)), -60:6:60);
%     histogram(cellfun(@median, xData(idxRed)), -60:6:60);
    title(titleStr{iPlot});
    ylabel({yTextStr{iPlot}; ylabelStr{iPlot}});
    xlabel(xlabelStr{iPlot});
    %     axis equal tight
end
linkaxes(ax)
