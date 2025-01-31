function newport_mode(np, mode_idx)
%NEWPORT_MODE Set newport to specified measurement mode
% modes for each value are as follows:
% 0 - DC Continuous
% 1 - DC Single
% 2 - Integrate
% 3 - Peak-to-peak Continuous
% 4 - Peak-to-peak Single
% 5 - Pulse Continuous
% 6 - Pulse Single
% 7 - RMS
    if(mode_idx < 0 || mode_idx > 7)
        error("Specified mode index %d out of acceptable range [0-7]", mode_idx);
    end
    newport_write(np, sprintf("PM:MODE %d", mode_idx));
end

