function [water, dur] = getValveCalibrationData

[~, rigName] = system('hostname');
rigName = rigName(1:end-1);

switch lower(rigName)
    case 'zmaze'
%         water = [0.002, 0.004];
%         dur = [0.07, 0.115];
%         calbration on 2017-08-13
%         water = [0.0014, 0.0023, 0.0032, 0.004, 0.0056, 0.0072];
%         dur = [0.0475, 0.07, 0.0925, 0.115, 0.16, 0.205];
%         calbration on 2017-10-04
%         water = [1.98, 3, 4.12, 6.3]*1e-3;
%         dur = [0.069, 0.098, 0.1281, 0.1998];
%         calbration on 2017-11-30
        water = [1.088, 1.787, 2.98, 4.159]*1e-3;
        dur = [0.0475, 0.0677, 0.0992, 0.1292];
    case 'zamboni'
%         water = [2.2, 3.1, 3.9, 5.8]*1e-3;
%         dur = [0.07, 0.0987, 0.13, .2041];
% 10% sucrose water, 18/09/2018
%         water = [1.7, 1.9, 3, 3.6, 5]*1e-3;
%         dur = [0.049, 0.0592, 0.1028, 0.1351, 0.2104];
        % 10% sucrose water, 31/01/2020
%         water = [2.1, 3.7, 4.3, 4.7, 5.2, 19.2]*1e-3;
%         dur = [0.0084, 0.0148, 0.0237, 0.0306, 0.0378, 0.2525];
        water = [1.9, 2.8, 3.2, 3.8, 4.1, 4.4]*1e-3;
        dur = [0.0066, 0.0151, 0.0225, 0.0409, 0.0451, 0.0496];
    otherwise
        msg = ...
            sprintf('No valve calibration data for rig ''%s'', loading default values...\n', upper(rigName));
        msg = ...
            sprintf('%sCalibration data should be entered in getValveCalibrationData()', msg);
        warning(msg);
        
        water = [0.002, 0.004];
        dur = [0.07, 0.115];
end