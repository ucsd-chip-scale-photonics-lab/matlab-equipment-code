%% connect to instruments
clear; delete(instrfindall);
nkt = NKTControl; nkt.connect;
anr = anritsu_start();
%% Settings + path to save
nkt_lambda_list = 1150:50:1700;
% Set Save directory and prefix
[file_prefix, save_dir] = uiputfile('*', ...
    'Select location and prefix where data will be saved:');
if(~file_prefix)
    error("You must select a save location");
end
%% Run sweep
nkt.enableLaser(true);
nkt.enableRF(true);
for this_lambda_idx = 1:length(nkt_lambda_list)
    this_lambda = nkt_lambda_list(this_lambda_idx);
    % set lambda
    nkt.setRFWavelength(this_lambda);
    % Save spectrum from Anritsu OSA to a file using current settings set with buttons on unit
    anr_single(anr); anr_wait_for_operation(anr);
    [osa_lambda,osa_power_dbm] = anr_get_trace(anr,"A");
    %figure; plot(osa_lambda,osa_power_dbm);
    %figure; plot(osa_lambda,10.^(osa_power_dbm/10));
    % save file
    this_filename = sprintf('%s_%1.0f.mat', file_prefix, 1e3*this_lambda);
    save(fullfile(save_dir, this_filename), ...
        'osa_lambda', 'osa_power_dbm');
end
nkt.enableRF(false);
nkt.enableLaser(false);