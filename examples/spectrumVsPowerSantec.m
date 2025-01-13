%%
clear; delete(instrfindall);
key = key_start();
% Laser
dllPath = fullfile(pwd, 'matlab-equipment-code\santecTSL-550\Santec_FTDI.dll');
asmInfo = NET.addAssembly(dllPath); pause(1);
TSL = Santec_FTDI.FTD2xx_helper('20060036');
pause(1);
TSL.Query('*IDN?')
% connect to agilent 8163a
%delete(instrfindall);
agi = agilent816x_start(Address = 'GPIB1::20::INSTR');
%%

key_auto_ohm(key, true);
key_output(key, true);
pause(1);
heater_R = key_measure_resistance(key);
key_output(key, false);
key_auto_ohm(key, false);

%% Setup sweep
wvRes = 0.01; % nm
wvStart = 1480; % nm
wvEnd = 1630; % nm
wvSpeed = 100; % nm/s
agilent_detector_range_1 = -20; % dBm, multiple of 10 from -60 to 10
agilent_detector_range_2 = -40;
%

% Set global settings that aren't gonna change
TSL.Write('*CLS'); pause(0.1)
TSL.Write('*RST'); pause(0.1)
TSL.Query('SM 1'); % Sweep Mode; 1-continous one way, 2-continous two ways, 3- step one way
pause(0.1); TSL.Query('SZ 1'); % Number of sweeps
pause(0.1); TSL.Query('TM 2'); % Trigger behaviour; 1-Stop, 2-Start, 3-Step
pause(0.1); TSL.Query(sprintf('SN %.1f',wvSpeed)); % Continous sweep speed (nm/s); [0.5:0.1:100]
pause(0.1); %TSL.Query(sprintf('TW %.4f',dummy_wvRes)); %0.0015 Trigger step (nm); [0.0001:0.0001:160] <1kHz
%TSL.Query("WA"+num2str(temp_wvStart,'%.4f')); pause(0.3)

agi_set_range(agi, agilent_detector_range_1, DetectorChannel = 1);
agi_set_range(agi, agilent_detector_range_2, DetectorChannel = 2);
%% Set up power sweep
P_desired = (0:25:100)*1e-3;
I_supply = sqrt(P_desired/heater_R);
P_max = 100e-3;
V_compliance = sqrt(P_max*heater_R);
key_auto_ohm(key, false);
key_config_I_source(key, V_compliance);

%% run sweep
[file_prefix, save_dir] = uiputfile('*', ...
    'Select location and prefix where data will be saved:');
if(~file_prefix)
    error("You must select a save location");
end

key_set_I(key, 0);
key_output(key, true);
for heater_idx = 1:length(I_supply)
    this_P = P_desired(heater_idx);
    key_set_I(key, 1000*I_supply(heater_idx));
    pause(1);
    [V_measure, I_measure] = key_measure(key);

    [lambdaArray, channel1, channel2] = runWavelengthScan(TSL, agi, wvStart, wvEnd, wvRes, wvSpeed);
    
    this_filename = sprintf('%s_%f.mat', file_prefix, this_P);
    save(fullfile(save_dir, this_filename), ...
        'channel1', 'channel2', 'lambdaArray', 'this_P', 'V_measure', 'I_measure');
end
key_output(key, false);

function [lambdaArray, channel1, channel2] = runWavelengthScan(TSL, agi, wvStart, wvEnd, wvRes, wvSpeed)
    % Change only settings relevant to range, and run sweep
    % TSL settings
    pause(0.1); TSL.Query(char(sprintf('SS %.4f', wvStart))); % Start wavelength (nm)
    pause(0.1); TSL.Query(sprintf('SE %.4f', wvEnd));
    
    lambdaArray = wvStart:wvRes:wvEnd;
    scanTime = ceil((wvEnd-wvStart)/wvSpeed);
    
    % agilent setup
    agilent_num_points = length(lambdaArray);
    agilent_sample_period = wvRes/wvSpeed;
    % open loop triggering only from first santec trigger, then agilent
    % simply collects values at a rate according to sweep speed
    % the accuracy of this seems fine, and it allows very rapid sweeps (10 kHz)
    agi_setup_logging(agi, agilent_num_points, DetectorIntTime=agilent_sample_period);
    clear('temp_wvEnd','temp_wvStart','temp_wvSpeed','temp_wvRes')
    
    % this function re-arms trigger for repeated measurements (logging)
    agi_arm_logging(agi, TriggerType = "complete");
    TSL.Query('SG');
    max_wait_time = scanTime+5; % time to wait for agilent before timing out
    
    loggingSuccessful = agi_wait_for_logging(agi, EstLoggingTime = max_wait_time);
    if(loggingSuccessful)
        [channel1, channel2] = agi_get_logging_result(agi);
        agi_reset_triggers(agi);
    else
        warning("Logging did not finish in alloted time.");
    end
end