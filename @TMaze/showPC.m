function axesHandle = showPC(obj, axesHandle, color)

fontSize = 12;
if iscell(obj.ExpRef)
    ind = true(size(obj.ExpRef{1}));
    for iExpRef = 2:length(obj.ExpRef)
        ind = ind & (obj.ExpRef{1} == obj.ExpRef{iExpRef});
    end
    expRefStr = obj.ExpRef{1};
    expRefStr(~ind) = 'X';
else
    expRefStr = obj.ExpRef;
end

if nargin<2
    figure('Name', sprintf('Psychometric Curve, %s', expRefStr));
    axesHandle = gca;
end

if nargin<3
    color = 'k';
end
% making the string valid for the title() function
expRefStr = strrep(expRefStr, '_', '\_');

addpath('\\zserver\Code\Psychofit\');
cc = obj.pcData.cc;
minX = min(cc) - 0.1*abs(min(cc))-0.01;
maxX = max(cc) + 0.1*abs(max(cc))+0.01;
xx = [minX:maxX]';
nModels = length(obj.pcFit);
yy = nan(length(xx), nModels);
pcColors = [0.7 0.7 0.7;...
    0.4 0.4 0.7;...
    0.7 0.4 0.4;...
    0.4 0.7 0.4;...
    0.7 0.4 0.7;...
    0.4 0.7 0.7;...
    0.7 0.7 0.4];

try
    for iModel = 1:nModels
        pars = obj.pcFit(iModel).pars;
        yy(:, iModel) = eval(sprintf('%s(pars, xx);', obj.pcFit(iModel).modelType));
        iColor = mod(iModel, size(pcColors, 1))+1;
        plot(xx, yy(:, iModel), 'k', 'LineWidth', 3, 'Color', pcColors(iColor, :));
        hold on;
    end
catch
    ; % do nothing
end
% legend(obj.pcFit.modelStr, 'Location', 'SouthEast');

% errorbar(obj.pcData.cc, obj.pcData.pp, obj.pcData.sem, 'k.', 'MarkerSize', 30);
if ~isfield(obj.pcData, 'conf')
    obj = getPCData(obj);
end
lowErr = obj.pcData.pp - obj.pcData.conf(1,:);
upErr = obj.pcData.conf(2,:) - obj.pcData.pp;
errorbar(obj.pcData.cc, obj.pcData.pp, lowErr, upErr, '.', 'MarkerSize', 30, 'Color', color);
xlim([minX, maxX]);
ylim([0 1]);
hold on;

plot([0 0], ylim, 'k:');
plot(xlim, [0.5, 0.5], 'k:');
title(expRefStr)
xlabel('Contrast [%]');
ylabel('Rightward Choice Probability');
set(axesHandle, 'XTick', cc, 'YTick', [0:0.2:1]);
set(axesHandle, 'FontSize', fontSize)
axis square;
box off;

nTrials = sum(obj.pcData.nn);
text(min(cc), max(ylim)-0.02*(diff(ylim)), sprintf('nTrials = %d', nTrials), ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'Color', color, 'FontSize', fontSize);

end % showPC()
