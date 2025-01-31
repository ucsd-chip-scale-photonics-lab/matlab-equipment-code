function newport_arm_logging(np, options)
%NEWPORT_ARM_LOGGING Arm newport so once it gets triggered, logging will start
% You need to call newport_setup_logging() before this TODO PROGRAM CAN CHECK THIS
    arguments
        np
        % if set to 1 or 2, only one of the channels will be armed
        options.ChannelsToArm (1,1) {mustBeMember(options.ChannelsToArm, [1,2,3])} = 3 
    end
    % clear buffer
    newport_write(np, "PM:DS:CLEAR");
    % enable external triggering on both channels 
    newport_write(np, sprintf("PM:TRIG:EXTERNAL %d", options.ChannelsToArm));

    % ext rising edge starts measurements
    newport_write(np, "PM:TRIG:EDGE 1");
    newport_write(np, "PM:TRIG:HOLDOFF 0");
    newport_write(np, "PM:TRIG:START 1"); % 1 = wait to start until trigger occurs
    % the buffer just fills up, so we never need to stop measurement - the
    % power meter will just keep running (which is its normal state)
    newport_write(np, "PM:TRIG:STOP 0"); % 0 = measurement never stops
    % arm trigger
    newport_write(np, "PM:TRIG:STATE 0"); % 0 = armed
    % enable data store
    newport_write(np, "PM:DS:ENABLE 1");
end

