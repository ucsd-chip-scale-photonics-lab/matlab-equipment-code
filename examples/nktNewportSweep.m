%% connect to instruments
clear; delete(instrfindall);
nkt = NKTControl; nkt.connect;
np = newport_start();
%% Turn on/off for alignment
nkt.enableLaser(true);
nkt.enableRF(true);
nkt.setRFWavelength(1570);
%nkt.setRFPower(50);
%%
nkt.enableRF(false);
nkt.enableLaser(false);

%% Settings
nkt_lambda_array = 1150:5:1950;
%newport_autorange(np, true); % sweep should be slowish so maybe this is aight?
uW = 1e-6;
newport_range(np, 10*uW);
%% Run sweep
nkt.enableLaser(true);
nkt.enableRF(true);
power_array = zeros(size(nkt_lambda_array));
for this_lambda_idx = 1:length(nkt_lambda_array)
    this_lambda = nkt_lambda_array(this_lambda_idx);
    % set lambda
    nkt.setRFWavelength(this_lambda);
    % Save spectrum from Anritsu OSA to a file using current settings set with buttons on unit
    % take power measurement with newport
    power_array(this_lambda_idx) = newport_get_power(np);
    %progress = round(100*this_lambda_idx/length(lambdaArray));
    disp(this_lambda);
end
nkt.enableRF(false);
nkt.enableLaser(false);
%%
figure; semilogy(nkt_lambda_array, power_array);
%%
%%
[output_filename, output_path] = uiputfile('*', 'Select location to save data:');
if(output_filename)
    save_file = fullfile(output_path, output_filename);
    save(save_file, ...
        'nkt_lambda_array', 'power_array');
else
    disp("File save cancelled");
end