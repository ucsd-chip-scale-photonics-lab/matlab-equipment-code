function newport_digital_filter(np, filter_length)
% Set newport to specified digital filter length (boxcar averaging)
    if(filter_length < 0 || filter_length > 10000)
        error("Specified filter length %d out of acceptable range [0-10000]", filter_length);
    end
    newport_write(np, sprintf("PM:DIGITALFILTER %d", filter_length));
end