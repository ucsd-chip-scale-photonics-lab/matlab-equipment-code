% Program to collect spectra using Venturi 6600 swept laser and
% BOTH Agilent 8164B + Newport 2936 simultaneously (used for developmental
% testing of Newport 2936 code)
clear; delete(instrfindall);
ven = venturi_start();
agi = agilent816x_start(Address = 'GPIB1::20::INSTR'); % legacy function name, not using laser on Agilent
np = newport_start();
%% Setup sweep
startWavelength = 1520; % nm
stopWavelength = 1630; % nm
sweepRate = 10; % nm/s
wavelengthStep = 0.01; 
laserPower = 5; % dBm, 0 to 9.9
powerMeterRange1 = -20; % dBm, multiples of 10 from -60 to 10
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

% Newport settings
newport_channel(np, 1);
newportRangeW = 1e-5; % W
newport_range(np, newportRangeW);
newport_setup_logging(np, numPts, SamplingPeriod = avgTime);
%% run sweep
scanTime = numPts*avgTime;
max_wait_time = scanTime+5; % time to wait for agilent before timing out
laser.Timeout = max_wait_time;
agi_arm_logging(agi, TriggerType = "complete");
newport_arm_logging(np);
venturi_output(ven, true);
venturi_sweep_run(ven);
venturi_sweep_run(ven);
%loggingSuccessful = agi_wait_for_logging(agi, EstLoggingTime = max_wait_time);
loggingSuccessful = newport_wait_for_logging(np, EstLoggingTime = max_wait_time);
if(loggingSuccessful)
    disp("Downloading Agilent data...");
    [channel1, channel2] = agi_get_logging_result(agi);
    disp("Downloading Newport data...");
    newport_data = newport_get_data_store(np);
    agi_reset_triggers(agi);
else
    warning("Logging did not finish in alloted time.");
end
%%
figure; hold on;
plot(lambdaArray, 10*log10(abs(channel1)) + 30,'r.-');
plot(lambdaArray, 10*log10(abs(newport_data)) + 30,'b.-');
%plot(lambdaArray, abs(channel1),'r.-');
%plot(lambdaArray, abs(newport_data),'b.-');
%plot(lambdaArray, 10*log10(channel2) + 30);
hold off;
xlabel("Wavelength");
ylabel("Transmission (dB)");
legend("Agilent detector", "Newport detector");
%%
figure; hold on;
plot(lambdaArray, 10*log10(channel1./channel2));
hold off;
xlabel("Wavelength");
ylabel("Transmission (dB)");
% wait for Venturi to *think* its done before we can turn off laser
% fprintf("Waiting for Venturi...");
% while(~strcmp(venturi_extract_result(query(ven, ":STAT?"),6),'Complete'))
%     fprintf('.');
%     pause(1);
% end
% venturi_output(ven, false);

%%
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'actualRate', 'avgTime', 'laserPower', 'channel1', 'channel2', 'lambdaArray');
else
    disp("File save cancelled");
end

