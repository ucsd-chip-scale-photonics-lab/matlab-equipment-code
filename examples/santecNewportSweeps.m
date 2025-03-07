%% TSL control
clear; 
% Laser
TSL = santec_start(); % "ans = NR" is an OK reponse to this!
% connect to power meter
np = newport_start();

%% Turn on laser
TSL.Query('LO')
%% Turn off laser
TSL.Query('LF')
%% Shutter on
TSL.Query('SC')
%% Shutter off
TSL.Query('SO')
%% Set wavelength
temp_wav = 1520.0;
TSL.Query(strcat('WA',num2str(temp_wav,'%.4f'))); pause(0.05)
%% Set power
temp_pwr = 1;
TSL.Query(strcat('LP',num2str(temp_pwr,'%.2f'))); pause(0.05)
clear('temp_pwr')
%% Set up sweep parameters
wvRes = 0.01; % nm
wvStart = 1480; % nm
wvEnd = 1630; % nm
wvSpeed = 50; % nm/s
newport_detector_range = 200e-6; % W
newport_range(np, newport_detector_range);
newport_analog_filter(np, 2); % set newport analog filter to 12.5 kHz
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
%% Run scan
newport_flush(np);
disp("Performing scan...");
[lambdaArray, powerArray] = runWavelengthScan(TSL, np, wvStart, wvEnd, wvRes, wvSpeed);
%% PLOTTING
figure; hold on;
plot(lambdaArray, 10*log10(abs(powerArray)) + 30, '.-');
hold off;
xlabel("Wavelength");
ylabel("Power (dBm)");
%% Plot FFT
N = length(powerArray);
this_FFT = abs(fft(powerArray));
semilogy(this_FFT(1:N/2));
%% save result

[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    %save(strcat(output_path,output_filename), 'wvs', 'channel1', 'channel2');
    save(strcat(output_path,output_filename), 'lambdaArray', 'powerArray');
else
    disp("File save cancelled");
end

 % Disconnect
 
% if(exist('TSL','var'))
%     TSL.CloseUsbConnection(); % Laser
%     clear('TSL')
% end
function out = pow2dbm(x)
    out = 10*log10(x) + 30;
end

function [lambdaArray, powerArray] = runWavelengthScan(TSL, np, wvStart, wvEnd, wvRes, wvSpeed)
    % Change only settings relevant to range, and run sweep
    % TSL settings
    pause(0.1); TSL.Query(char(sprintf('SS %.4f', wvStart))); % Start wavelength (nm)
    pause(0.1); TSL.Query(sprintf('SE %.4f', wvEnd));
    
    lambdaArray = wvStart:wvRes:wvEnd;
    scanTime = ceil((wvEnd-wvStart)/wvSpeed);
    
    % newport setup
    num_power_points = length(lambdaArray);
    sample_period = wvRes/wvSpeed;
    % open loop triggering only from first santec trigger, then newport
    % simply collects values at a rate according to sweep speed
    % the accuracy of this seems fine, and it allows very rapid sweeps (10 kHz)
    newport_setup_logging(np, num_power_points, SamplingPeriod=sample_period);
    clear('temp_wvEnd','temp_wvStart','temp_wvSpeed','temp_wvRes')
    
    % this function re-arms trigger for repeated measurements (logging)
    newport_arm_logging(np);
    TSL.Query('SG');
    max_wait_time = scanTime+5; % time to wait for newport before timing out
    
    loggingSuccessful = newport_wait_for_logging(np, EstLoggingTime = max_wait_time);
    if(loggingSuccessful)
        powerArray = newport_get_data_store(np);
    else
        warning("Logging did not finish in alloted time.");
    end
end