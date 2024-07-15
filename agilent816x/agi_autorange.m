function agi_autorange(agi, doAutorange, options)
    arguments
        agi
        doAutorange
        options.DetectorSlot (1,1) {mustBeInteger} = 2
    end
    % turn on/off power meter autoranging - applies to both detectors
    if(doAutorange)
        writeString = sprintf('sens%d:chan1:pow:rang:auto 1', options.DetectorSlot);
    else
        writeString = sprintf('sens%d:chan1:pow:rang:auto 0', options.DetectorSlot);
    end
    write(agi, writeString);
    write(agi, '*WAI');
end