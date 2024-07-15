function agi_reset_triggers(agi, options)
    % return Agilent triggers to a state where the power meter auto-updates
    arguments
        agi
        options.DetectorSlot (1,1) {mustBeInteger} = 2
    end
    % just in case logging didn't finish:
    write(agi, sprintf(":SENS%d:CHAN1:FUNC:STAT LOGG,STOP", options.DetectorSlot));
    % continuous back on:
    write(agi, sprintf(":INIT%d:CONT 1", options.DetectorSlot));
    % ignore external triggers
    write(agi, sprintf(":TRIG%d:CHAN1:INP IGN", options.DetectorSlot));
end

