function power1  = agi_get_power(agi)
    % Just triggers and returns a single value from power meter 2.1
    % There is no simple analagous function for 2.2 unfortunately
    % Does not change any settings, that must be done beforehand
    % Value returned is in W from laser, this function returns mW
    power1 = 1000*str2double(query(agi, "read2:chan1:pow?"));
end

