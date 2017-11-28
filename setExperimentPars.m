function Exp = setExperimentPars(animalName)

if nargin<1
    warning('Animal name not provided, will load default parameters')
    animalName = 'default';
end

switch upper(animalName)
    case 'MK027'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadMK027;
    case 'MK028'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadMK028;
    otherwise
        fprintf('Loading default parameters\n');
        Exp = loadDefaultPars;
end
