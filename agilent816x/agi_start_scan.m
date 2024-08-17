%% NOT YET MIGRATED Trigger wavelength sweep on Agilent 816x, after configured using laser_scan_setup
function agi_start_scan(agi,options)
    arguments
        agi
        options.LaserSlot (1,1) {mustBeInteger} = 0 % slot #
    end
    % Laser sweep ON
    str = sprintf('sour%d:wav:swe 1', options.LaserSlot);
    fwrite(agi, str);
    fwrite(agi, '*WAI')
    % force wait with unnecessary query
    writeread(agi, sprintf('sour%d:wav?', options.LaserSlot));
    % hardware trigger
    write(agi, 'trig 1');
end

    