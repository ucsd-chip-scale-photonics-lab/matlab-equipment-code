%%
clear;
delete(instrfindall); % Delete all existing instruments
anr = anritsu_start();
key = key_start();
%% Settings + path to save
heater_R = 950; % ohms
key_power_list = 1e-3*(100:2.5:150); % W
key_current_list = 1e3*sqrt(key_power_list/heater_R);
% Set Save directory and prefix
[file_prefix, save_dir] = uiputfile('*', ...
    'Select location and prefix where data will be saved:');
if(~file_prefix)
    error("You must select a save location");
end
%% Run sweep

for this_current_idx = 1:length(key_current_list)
    this_current = key_current_list(this_current_idx);
    this_power = key_power_list(this_current_idx);
    % set current
    key_set_I(key, this_current);
    % Save spectrum from Anritsu OSA to a file using current settings set with buttons on unit
    anr_single(anr); anr_wait_for_operation(anr);
    [osa_lambda,osa_power_dbm] = anr_get_trace(anr,"C");
    %figure; plot(osa_lambda,osa_power_dbm);
    %figure; plot(osa_lambda,10.^(osa_power_dbm/10));
    % save file
    this_filename = sprintf('%s_%1.1f.mat', file_prefix, 1e3*this_power);
    save(fullfile(save_dir, this_filename), ...
        'osa_lambda', 'osa_power_dbm');
end