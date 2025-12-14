clear agi
clear pwr pwr_avg pwr_avg_dac1 i j vheater 
%agi = agilent816x_start();
agi=agilent816x_start(Address="TCPIP0::169.254.188.145::inst0::INSTR");
%%
j=1;
num_power_points = 100;
sample_period = 1e-3;
%newport_setup_logging(np, num_power_points, SamplingPeriod=sample_period);
%newport_arm_logging(np, DoSoftwareTrigger=true);
  scan_time = num_power_points*sample_period;
    max_wait_time = scan_time+5;
%%
clear pwr pwr_avg
vheater_min=0.75;
vheater_max=0.825;
vheater_step=0.005;
vheater=vheater_min:vheater_step:vheater_max;
for i=1:length(vheater)

    %rigo_vsweep1=[':APPL CH1,',num2str(vheater(i)-0.025),',0.015'];
    rigo_vsweep1=[':APPL CH1,',num2str(0),',0.015'];
    rigo_vsweep2=[':APPL CH2,',num2str(vheater(i)),',0.015'];
    fprintf("Vheater = "+num2str(vheater(i))+"\n");

    write(rigo,rigo_vsweep1)
    write(rigo,rigo_vsweep2)
    pause(3)
    agi_setup_logging(agi, num_power_points, DetectorIntTime=sample_period);
    agi_arm_logging(agi, TriggerType = "complete");
    write(agi,'TRIG 1');

    max_wait_time = scan_time+5; % time to wait for agilent before timing out
    
    loggingSuccessful = agi_wait_for_logging(agi, EstLoggingTime = max_wait_time);
    if(loggingSuccessful)
        [channel1, channel2] = agi_get_logging_result(agi);
        pwr_avg(i)=mean(channel1);
        %pwr_avg(i)=agi_get_power(agi);
        agi_reset_triggers(agi);
    else
        warning("Logging did not finish in alloted time.");
    end

pause(1)
end
%%
%figure;
pwr_avg_dac1(j,:)=pwr_avg;
j=j+1;
plot(vheater,pwr_avg,'LineWidth',2); hold on;
