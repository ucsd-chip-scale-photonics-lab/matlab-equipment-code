% Program to collect spectra using Venturi 6600 swept laser and
% BOTH Agilent 8164B + Newport 2936 simultaneously (used for developmental
% testing of Newport 2936 code)
clear; delete(instrfindall);
ven = venturi_start();
np = newport_start();
%% Setup sweep
startWavelength = 1520; % nm
stopWavelength = 1630; % nm
sweepRate = 10; % nm/s
wavelengthStep = 0.01; 
laserPower = 5; % dBm, 0 to 9.9
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

% Newport settings
newport_channel(np, 1);
newportRangeW = 10e-3; % W
newport_range(np, newportRangeW);
newport_setup_logging(np, numPts, SamplingPeriod = avgTime);
%% run sweep
scanTime = numPts*avgTime;
max_wait_time = scanTime+5; % time to wait for agilent before timing out
newport_arm_logging(np);
venturi_output(ven, true);
venturi_sweep_run(ven);
venturi_sweep_run(ven);
loggingSuccessful = newport_wait_for_logging(np, EstLoggingTime = max_wait_time);
if(loggingSuccessful)
%     disp("Downloading Agilent data...");
%     [channel1, channel2] = agi_get_logging_result(agi);
    disp("Downloading Newport data...");
    newport_data = newport_get_data_store(np, numPts);
else
    warning("Logging did not finish in alloted time.");
end
%%
figure; hold on;
plot(lambdaArray, 10*log10(abs(newport_data)) + 30,'b.-');
hold off;
xlabel("Wavelength");
ylabel("Transmission (dB)");
% legend("Agilent detector", "Newport detector");
%%
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save(strcat(output_path,output_filename), 'actualRate', 'avgTime', 'laserPower', 'newport_data', 'lambdaArray');
else
    disp("File save cancelled");
end

