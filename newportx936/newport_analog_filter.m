function filter_bw = newport_analog_filter(np, filter_idx)
% Set newport to specified analog filter
% 0 - None
% 1 - 250 kHz
% 2 - 12.5 kHz
% 3 - 1 kHz
% 4 - 5 Hz
    if(filter_idx < 0 || filter_idx > 4)
        error("Specified filter index %d out of acceptable range [0-4]", filter_idx);
    end
    newport_write(np, sprintf("PM:ANALOGFILTER %d", filter_idx));
end

