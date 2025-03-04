%% 
clear;
delete (instrfindall); % Delete all existing instruments
addpath("C:\Users\user\Desktop\Karl Johnson\Code\matlab-equipment-code\keithley2400")
key = key_start(Address = "GPIB1::3::INSTR");
%% Power supply settings
v_compliance = 10; % volts
I_supply = 1; % mA
key_config_I_source(key, v_compliance); 
key_set_I(key, I_supply);
logPeriod = 10; % period in seconds, only approximate - datetime saves precise timing
%% Contact test
fwrite(key, 'sens:res:mode MAN');
key_config_I_source(key, v_compliance); 
key_set_I(key, I_supply);
[twoWire, fourWire] = key_contact_resistance(key);
contact = twoWire - fourWire;
fprintf("2-wire = %f, 4-wire = %f, diference = %f \n", twoWire, fourWire, contact);

%% Output csv file
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    full_name = fullfile(output_path, output_filename);
    % check if it exists
    if(isfile(full_name))
        warning("Selected file already exists - results will be appended to this file.");
    end
    
else
    disp("File save cancelled");
end
%% Log resistance until user ctrl-C's
key_output(key,true);
loopCount = 0;
disp("Logging in progress...");
key_set_4wire(key, true);
    
while(true)
    pause(logPeriod);
    loopCount = loopCount + 1;
    %disp(loopCount);
    dateStr = datetime('now', 'Format', 'yyyy-MM-dd-HH-mm-ss.SSS');

    fourWire = key_measure_resistance(key);
    % hack: turn power back on
    %key_output(key,true);
    % display to user
    fprintf("%s, %e, \r\n", dateStr, fourWire);
    fid = fopen(full_name, 'a');
    fprintf(fid, "%s, %e \r\n", dateStr, fourWire);
    fclose(fid);
end