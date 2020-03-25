function tblOut = printTable(data, fieldNames)

% make sure 'expRef' is the first field and 'date' is the second
[~, idx] = ismember('date', fieldNames);
fieldNames = fieldNames([idx, 1:idx-1, idx+1:end]);
[~, idx] = ismember('expRef', fieldNames);
fieldNames = fieldNames([idx, 1:idx-1, idx+1:end]);

% create a cell array with the data from the original structure
tmp = cell(0);
for iF = 1:length(fieldNames)
    tmp(:, iF) = {data.(fieldNames{iF})}';
end

% convert the cell array into a table
% this will also print it nicely in the command window for inspection
tblOut = cell2table(tmp, 'VariableNames', fieldNames)
