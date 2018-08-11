function Exp = setExperimentPars(animalName)

if nargin<1
    warning('Animal name not provided, will load default parameters')
    animalName = 'default';
end

fprintf('Loading parameters for %s\n', upper(animalName));
Exp = eval(['load', upper(animalName)]);
