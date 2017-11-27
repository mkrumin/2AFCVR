function Exp = setExperimentPars(animalName)

if nargin<1
    warning('Animal name not provided, will load default parameters')
    animalName = 'default';
end

switch upper(animalName)
    case 'MK027'
        Exp = loadMK027;
    case 'MK028'
        Exp = loadMK028;
    otherwise
        Exp = loadDefaultPars;
end
