%%
clear; delete(instrfindall);
ven = venturi_start();
key = key_start();
agi = agilent816x_start();
%%

key_auto_ohm(key, false);
key_output(key, true);
pause(1);
heater_R = key_measure_resistance(key);
key_output(key, false);

%% Setup sweep
startWavelength = 1520; % nm
stopWavelength = 1630; % nm
sweepRate = 50; % nm/s
wavelengthStep = 0.01; 
laserPower = 5; % dBm, 0 to 9.9
powerMeterRange1 = -30; % dBm, multiples of 10 from -60 to 10
powerMeterRange2 = 10; % dBm, multiples of 10 from -60 to 10

venturi_set_power(ven, laserPower);
[actualRange, actualRate] = venturi_sweep_setup(ven, sweepRate, startWavelength, stopWavelength);
% compute parameters to give to Agilent power meter logging
% the points collected are not instantaneous - they average over the
% interval spacing (for now, unless we set up Stability power meter mode)
avgTime = wavelengthStep/actualRate;
% as such, the calc below is not a fencepost error - our measurements are
% the gaps, not the posts in the fence
numPts = actualRange/wavelengthStep;
% our array of wavelengths, then, is the CENTER of these gaps!
lambdaArray = startWavelength + wavelengthStep*(0.5 + 0:(numPts));
agi_set_range(agi, powerMeterRange1, DetectorChannel = 1);
agi_set_range(agi, powerMeterRange2, DetectorChannel = 2);
agi_setup_logging(agi, numPts, DetectorIntTime=avgTime);
%%
P_desired = (0:.5:7.5)*1e-3;
I_supply = sqrt(P_desired/heater_R);
P_max = max(P_desired);
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
figure; hold on;
for heater_idx = 1:length(I_supply)
    pause(5);
    this_P = P_desired(heater_idx);
    key_set_I(key, 1000*I_supply(heater_idx));
    pause(1);
    [V_measure, I_measure] = key_measure(key);

    scanTime = numPts*avgTime;
    max_wait_time = scanTime+5; % time to wait for agilent before timing out
    laser.Timeout = max_wait_time;
    agi_arm_logging(agi, TriggerType = "complete");
    venturi_output(ven, true);
    venturi_sweep_run(ven);
    venturi_sweep_run(ven);
    loggingSuccessful = agi_wait_for_logging(agi, EstLoggingTime = max_wait_time);
    if(loggingSuccessful)
        [channel1, channel2] = agi_get_logging_result(agi);
        agi_reset_triggers(agi);
    else
        warning("Logging did not finish in alloted time.");
    end
    
    this_filename = sprintf('%s_%f.mat', file_prefix, this_P);
    save(fullfile(save_dir, this_filename), ...
        'channel1', 'channel2', 'lambdaArray', 'this_P', 'V_measure', 'I_measure');
    plot(lambdaArray, channel1); drawnow;
end
key_output(key, false);
