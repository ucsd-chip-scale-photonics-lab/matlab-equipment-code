function power_W = newport_get_power(np)
%NEWPORT_POWER Get power in W for currently active channel (see newport_channel())
    reply = newport_query(np, "PM:DPower?");
    power_W = str2double(reply);
    if(isnan(power_W))
        warning("str2double failed, original reply %s" ,reply);
    end
end

