function power1  = agi_get_power(agi, options)
    % Just triggers and returns a single value from power meter 2.1
    % There is no simple analagous function for 2.2 unfortunately!
    % Does not change any settings, that must be done beforehand
    % Value returned is in W from laser, this function returns mW
    arguments
        agi
        options.DetectorSlot (1,1) {mustBeInteger} = 2
    end
    readstr = sprintf("read%d:chan1:pow?", options.DetectorSlot);
    power1 = str2double(writeread(agi, readstr));
end

