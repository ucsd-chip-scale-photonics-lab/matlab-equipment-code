function agi_set_basic_params(agi, power, lambda, options)
% Set some basic params for laser and power meter 
% Software alternative to pressing buttons on laser
% Doesn't include triggering, logging, sweep settings etc.
    arguments
        agi
        power
        lambda
        options.LaserSlot (1,1) {mustBeInteger} = 0 % slot #
    end
    % laser power (dBm)
    str = sprintf('sour%d:pow %f dBm', options.LaserSlot, power);
    write(agi, str);
    write(agi, '*WAI');
    
    % laser wavelength (nm)
    str = sprintf('sour%d:wav %f nm', options.LaserSlot, lambda);
    write(agi, str);
    write(agi, '*WAI');

end

