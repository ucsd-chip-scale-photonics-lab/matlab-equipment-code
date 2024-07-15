function agi_show_error(agi)
    writeread(agi, ':SYST:ERR?');
end

