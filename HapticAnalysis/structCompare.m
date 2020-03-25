function activeFields = structCompare(data)

% activeFields will be fields with non-identical contents
% useful when you want to check which parameters changed between experiments

nStructs = length(data);
activeFields = cell(0);
allFields = fields(data(1));
for iStruct = 2:nStructs
    allFields = union(allFields, fields(data(iStruct)));
end

nFields = length(allFields);
for iField = 1:nFields
    fName = allFields{iField};
    for iStruct = 2:nStructs
    if isequal(data(1).(fName), data(iStruct).(fName))
        continue;
    else
        activeFields{end+1} = fName;
        break;
    end
    end
end

activeFields = activeFields(:);