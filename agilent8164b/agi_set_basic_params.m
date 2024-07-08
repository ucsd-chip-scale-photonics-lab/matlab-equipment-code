function agi_set_basic_params(agi, power, lambda)
% Set some basic params for laser and power meter 
% Software alternative to pressing buttons on laser
% Doesn't include triggering, logging, sweep settings etc.

    % laser power (dbM)
    str = upper(['sour0:pow ',num2str(power),'dBm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % laser wavelength (nm)

    str = upper(['sour0:wav ',num2str(lambda),'nm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');

end

