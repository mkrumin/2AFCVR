function [water, dur] = getValveCalibrationData

[~, rigName] = system('hostname');
rigName = rigName(1:end-1);

switch lower(rigName)
    case 'zmaze'
%         water = [0.002, 0.004];
%         dur = [0.07, 0.115];
        % calbration on 2017-08-13
        water = [0.0014, 0.0023, 0.0032, 0.004, 0.0056, 0.0072];
        dur = [0.0475, 0.07, 0.0925, 0.115, 0.16, 0.205];
    otherwise
        msg = ...
            sprintf('No valve calibration data for rig ''%s'', loading default values...\n', upper(rigName));
        msg = ...
            sprintf('%sCalibration data should be entered in getValveCalibrationData()', msg);
        warning(msg);
        
        water = [0.002, 0.004];
        dur = [0.07, 0.115];
end