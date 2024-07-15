function agi_arm_logging(agi, options)
    arguments
        agi
        options.DetectorSlot (1,1) {mustBeInteger} = 2
        options.TriggerType (1,1) {mustBeMember(options.TriggerType,["single","complete"])}
    end

    % turn off continuous measurement
    write(agi, sprintf(":INIT%d:CONT 0", options.DetectorSlot));
    % set trigger mode "arm" trigger
    if(options.TriggerType == "single")
        write(agi, sprintf(":TRIG%d:CHAN1:INP SME", options.DetectorSlot));
    elseif(options.TriggerType == "complete")
        write(agi, sprintf(":TRIG%d:CHAN1:INP CME", options.DetectorSlot));
    else
        error("Unknown TriggerType %s", options.TriggerType);
    end
    % REALLY arm trigger
    write(agi, sprintf(":SENS%d:CHAN1:FUNC:STAT LOGG,STAR", options.DetectorSlot));
    % Check that everything is armed
    % This also ensures we wait long enough before exiting this function to
    % avoid race condition
    thisResponse = writeread(agi, sprintf(":SENS%d:CHAN1:FUNC:STAT?", options.DetectorSlot));
    % this is what's returned if the arming was successful
    progressString = ['LOGGING_STABILITY,PROGRESS' newline()];
    if(~strcmp(thisResponse, progressString))
        warning("Unexpected logging progress response immediately after arming: %s", thisResponse);
    end
end

