np = newport_start();
%%
num_power_points = 10000;
sample_period = 1e-3;
newport_setup_logging(np, num_power_points, SamplingPeriod=sample_period);
newport_arm_logging(np, DoSoftwareTrigger=true);

%% manually trigger newport
newport_write(np, "PM:TRIG:STATE 1");
scan_time = num_power_points*sample_period;
max_wait_time = scan_time+5;
loggingSuccessful = newport_wait_for_logging(np, EstLoggingTime = max_wait_time);
if(loggingSuccessful)
    powerArray = newport_get_data_store(np, num_power_points);
else
   
    warning("Logging did not finish in alloted time.");
end
%%
plot(powerArray);