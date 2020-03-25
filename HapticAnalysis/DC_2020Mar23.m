% Script for Data Club on March 23 2020

clear TM EXP

% select which animal and what dates to include in the analysis

% animalName = 'MK040';
% dates = datenum('2020-03-06'):datenum('2020-03-18');
% excludeDates = datenum('2020-03-12');
% animalName = 'MK041';
% dates = datenum('2020-03-06'):datenum('2020-03-18');
% excludeDates = datenum('2020-03-12');
animalName = 'MK042';
dates = datenum('2020-03-06'):datenum('2020-03-18');
excludeDates = datenum('2020-03-12');
% animalName = 'MK043';
% dates = datenum('2020-03-06'):datenum('2020-03-18');
% excludeDates = datenum('2020-03-11');

% animalName = 'MK044';
% dates = datenum('2020-03-05'):datenum('2020-03-18');
% excludeDates = datenum('2020-03-11');

dates = setdiff(dates, excludeDates);
[allExpRefs, allDateNums, iExp] = dat.listExps(animalName);
[validDates, expIdx] = ismember(allDateNums, dates);
validDates = allDateNums(validDates);
expIdx = find(expIdx);
nExps = length(expIdx);
nRows = floor(sqrt(nExps));
nColumns = ceil(nExps/nRows);
figure;
for iExp = 1:nExps
    TM(iExp) = TMaze(allExpRefs{expIdx(iExp)});
    try
        TM(iExp).getPCData;
        TM(iExp).fitPC;
        TM(iExp).showPC(subplot(nRows, nColumns, iExp));
    end
    EXP(iExp) = TM(iExp).EXP;
end

% let's see what parameters had changed between the different experiments
% then decide if we really want to merge these experiments together
activeFieldNames = structCompare(EXP);
printTable(EXP, activeFieldNames);

% merge all the sessions
for iExp = 2:nExps
    TM(1) = TM(1).Merge(TM(iExp));
end
TM = TM(1);
% ExpRef = '2020-03-17_1724_MK041';
% TM = TMaze(ExpRef);
TM.getPCData;
TM.fitPC;
TM.showPC;

%% Extract all the data into an easy to work with format

TM.getVectors;

%% plot x and theta distributions for different conditions

plotXThDistributions(TM);

%% let's see some trajectories (closed- and open-loop)
% some extra settings/parameters inside the function

plotSampleTrajectories(TM);

%% plot distributions of derivatives of the heading angle (Theta)

plotDThetaDistributions(TM);

