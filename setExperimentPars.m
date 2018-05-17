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
    case 'JL015'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadJL015;  
    case 'JL022'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadJL022;  
    case 'JL023'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadJL023;  
    case 'LEW_002'
        fprintf('Loading parameters for %s\n', upper(animalName));
        Exp = loadLEW_002;
    otherwise
        fprintf('Loading default parameters\n');
        Exp = loadDefaultPars;
end
