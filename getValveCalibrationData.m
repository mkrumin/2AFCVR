function [water, dur] = getValveCalibrationData

[~, rigName] = system('hostname');
rigName = rigName(1:end-1);

switch lower(rigName)
    case 'zmaze'
        dur = [0.02,0.0525,0.085,0.1175,0.15];
        water = [0.0002, 0.001, 0.0017, 0.0023, 0.003];
        %calibrated 2019-07-21 by JL
    otherwise
        msg = ...
            sprintf('No valve calibration data for rig ''%s'', loading default values...\n', upper(rigName));
        msg = ...
            sprintf('%sCalibration data should be entered in getValveCalibrationData()', msg);
        warning(msg);
        
        water = [0.002, 0.004];
        dur = [0.07, 0.115];
end