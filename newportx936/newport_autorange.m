function [outputArg1,outputArg2] = newport_autorange(np, do_auto)
%NEWPORT_AUTORANGE Turn on/off autoranging on power meter
    if(do_auto), value = 1; else value = 0; end
    newport_write(np, sprintf("PM:AUTO %d", value));
end

