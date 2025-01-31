function power_W = newport_get_power(np)
%NEWPORT_POWER Get power in W for currently active channel (see newport_channel())
    power_W = str2double(newport_query(np, "PM:DPower?"));
end

