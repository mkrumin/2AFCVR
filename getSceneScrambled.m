function wallTextures = getSceneScrambled(count)

% global EXP
global TRIAL
global SESSION


stimulus=TRIAL.stimulus(count);
contrast=TRIAL.contrast(count);

contrastIndex=find(SESSION.options.gratingContrasts==contrast);
gratingName=['COSGRATING', num2str(contrastIndex)];

stim2code=stimulus;
% if EXP.flipSides
%     if isequal(stim2code, 'RIGHT')
%         stim2code='LEFT';
%     elseif isequal(stim2code, 'LEFT')
%         stim2code='RIGHT';
%     end
% end
% fprintf('%s %d%% contrast\n', stimulus, contrast);
switch stim2code
    case 'R'
        wallTextures={...
            'GRAY';...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            'WNWEAK';...
            gratingName;...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
    case 'L'
        wallTextures={...
            'GRAY';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNWEAK';...
            'WNWEAK';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
    case 'B'
        wallTextures={...
            'GRAY';...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            gratingName;...
            'WNWEAK';...
            gratingName;...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            'WNSTRONG';...
            };
end
