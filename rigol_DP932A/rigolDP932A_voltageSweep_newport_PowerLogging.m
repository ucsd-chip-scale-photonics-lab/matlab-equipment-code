clear pwr pwr_avg
%np = newport_start();

%%
num_power_points = 10000;
sample_period = 1e-3;
%newport_setup_logging(np, num_power_points, SamplingPeriod=sample_period);
%newport_arm_logging(np, DoSoftwareTrigger=true);
  scan_time = num_power_points*sample_period;
    max_wait_time = scan_time+5;
%%
vheater_min=0.7;
vheater_max=1;
vheater_step=0.05;
vheater=vheater_min:vheater_step:vheater_max;
for i=1:length(vheater)
    rigo_vsweep1=[':APPL CH1,',num2str(vheater(i)-0.025),',0.015'];
    rigo_vsweep2=[':APPL CH2,',num2str(vheater(i)),',0.015'];
    write(rigo,rigo_vsweep1)
    write(rigo,rigo_vsweep2)
    pause(5);
    newport_setup_logging(np, num_power_points, SamplingPeriod=sample_period);
    newport_arm_logging(np, DoSoftwareTrigger=true);
    newport_write(np, "PM:TRIG:STATE 1");
  
    loggingSuccessful = newport_wait_for_logging(np, EstLoggingTime = max_wait_time);
    if(loggingSuccessful)
        pwr(i,:)= newport_get_data_store(np, num_power_points);
        pwr_avg(i)=mean(pwr(i,:));
    else
       warning("Logging did not finish in alloted time.");
    end
    
end
%%
plot(vheater,pwr_avg);
