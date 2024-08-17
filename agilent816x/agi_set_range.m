function agi_set_range(agi, range, options)
    arguments
        agi
        range % dBm
        options.DetectorSlot (1,1) {mustBeInteger} = 2 % slot #
        options.DetectorChannel (1,1) {mustBeInteger} = 1
    end
    % Turn off power autorange
    agilent_autorange(agi, false, DetectorSlot = options.DetectorSlot);
    % Set Power Range
    str = sprintf('sens%d:chan%d:pow:rang %f', options.DetectorSlot,...
        options.DetectorChannel, range);
    write(agi, str);
end

