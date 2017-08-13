function [water, dur] = getValveCalibrationData

[~, rigName] = system('hostname');
rigName = rigName(1:end-1);

switch lower(rigName)
    case 'zmaze'
        water = [0.002, 0.004];
        dur = [0.07, 0.115];
    otherwise
        msg = ...
            sprintf('No valve calibration data for rig ''%s'', loading default values...\n', upper(rigName));
        msg = ...
            sprintf('%sCalibration data should be entered in getValveCalibrationData()', msg);
        warning(msg);
        
        water = [0.002, 0.004];
        dur = [0.07, 0.115];
end