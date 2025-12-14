%%
clear;
delete(instrfindall); % Delete all existing instruments
anr = anritsu_start();
%% Save spectrum from Anritsu OSA to a file using current settings set with buttons on unit
anr_single(anr); anr_wait_for_operation(anr);
[osa_lambda,osa_power_dbm] = anr_get_trace(anr,"A");
figure; plot(osa_lambda,osa_power_dbm);
%figure; plot(osa_lambda,10.^(osa_power_dbm/10));
%%
[output_filename, output_path] = uiputfile('*', 'Select location to save OSA OSA OSA data:');
if(output_filename)
    osa_file = fullfile(output_path, output_filename);
    save(osa_file, ...
        'osa_lambda', 'osa_power_dbm');
else
    disp("File save cancelled");
end