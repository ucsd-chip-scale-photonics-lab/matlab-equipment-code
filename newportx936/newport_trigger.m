function newport_trigger(np)
    % send software trigger to newport
    newport_write(np, "PM:TRIG:STATE 1");
end

