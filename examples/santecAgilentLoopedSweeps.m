%% TSL control
clear; 
% Laser
dllPath = 'C:\Users\CSPTF-packaging\Equipment\matlab-equipment-code\santecTSL-550\Santec_FTDI.dll';
asmInfo = NET.addAssembly(dllPath); pause(1);
TSL = Santec_FTDI.FTD2xx_helper('20060036');
pause(1);
TSL.Query('*IDN?')


%% connect to agilent 8163a
delete(instrfindall);
agi = agilent816x_start(Address = 'GPIB0::20::INSTR'); % note: this is a legacy function name for the 8164b


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
%% Loop sweeps to form a very high resolution spectrum
% not limited by buffer size of power meter
maxDataPoints = 20001;
wvRes = 0.001; % nm
wvStart = 1500; % nm
wvEnd = 1580; % nm
wvSpeed = 10; % nm/s
agilent_detector_range_1 = -40; % dBm, multiple of 10 from -60 to 10
agilent_detector_range_2 = -40;
%
% Calculate scan ranges
scanOverlap = 0;
maxScanRange = round((maxDataPoints-1)*wvRes) - scanOverlap;
numScans = ceil((wvEnd-wvStart)/(maxScanRange-scanOverlap));

% Set global settings that aren't gonna change
TSL.Write('*CLS'); pause(0.1)
TSL.Write('*RST'); pause(0.1)
TSL.Query('SM 1'); % Sweep Mode; 1-continous one way, 2-continous two ways, 3- step one way
pause(0.1); TSL.Query('SZ 1'); % Number of sweeps
pause(0.1); TSL.Query('TM 2'); % Trigger behaviour; 1-Stop, 2-Start, 3-Step
pause(0.1); TSL.Query(sprintf('SN %.1f',wvSpeed)); % Continous sweep speed (nm/s); [0.5:0.1:100]
pause(0.1); %TSL.Query(sprintf('TW %.4f',dummy_wvRes)); %0.0015 Trigger step (nm); [0.0001:0.0001:160] <1kHz
%TSL.Query("WA"+num2str(temp_wvStart,'%.4f')); pause(0.3)


% cell array to save results in
lambdaArrayLooped = cell(numScans, 1);
channel1Looped = cell(numScans, 1);
channel2Looped = cell(numScans, 1);
%%
scanLow = wvStart;
scanHigh = min(scanLow + maxScanRange, wvEnd);
doSmartRange = false;
for i = 1:numScans
    agi_set_range(agi, agilent_detector_range_1, DetectorChannel = 1);
    agi_set_range(agi, agilent_detector_range_2, DetectorChannel = 2);
    fprintf("Doing scan %d/%d: [%d,%d]\n", i, numScans, scanLow, scanHigh);
    [lambdaArrayLooped{i}, channel1Looped{i}, channel2Looped{i}] = runWavelengthScan(TSL, agi, scanLow, scanHigh, wvRes, wvSpeed);
    if(doSmartRange)
        thisMaxDbm = pow2dbm(max(channel1Looped{i}));
        if(thisMaxDbm > 50)
            warning("Detector saturated!");
        elseif(thisMaxDbm < agilent_detector_range - 7)
            
            newRange = 10*ceil((thisMaxDbm-3)/10);
            fprintf("Re-taking w/ new range of %d... \n", newRange);
            agi_set_range(agi, newRange);
            [lambdaArrayLooped{i}, channel1Looped{i}, channel2Looped{i}] = runWavelengthScan(TSL, agi, scanLow, scanHigh, wvRes, wvSpeed);
        end
    end
    scanLow = scanHigh - scanOverlap;
    scanHigh = min(scanLow + maxScanRange, wvEnd);
end


%% PLOTTING
figure; hold on;
for i = 1:numScans
    plot(lambdaArrayLooped{i}, 10*log10(abs(channel1Looped{i})) + 30, '.-');
    %plot(lambdaArrayLooped{i}, 10*log10(abs(channel2Looped{i})) + 30, '.-');
end
%plot(wvs, 10*log10(abs(channel2)) + 30);
hold off;
xlabel("Wavelength");
ylabel("Power (dBm)");

%% save result
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    %save(strcat(output_path,output_filename), 'wvs', 'channel1', 'channel2');
    save(strcat(output_path,output_filename), 'lambdaArrayLooped', 'channel1Looped');
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