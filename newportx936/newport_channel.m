function newport_channel(np, channel)
%NEWPORT_CHANNEL Switch PM channel which will receive subsequent commands
% channel must be 1 or 2
    if(channel == 1 || channel == 2)
        newport_write(np, sprintf("PM:CHANNEL %d", channel))
    end
end

