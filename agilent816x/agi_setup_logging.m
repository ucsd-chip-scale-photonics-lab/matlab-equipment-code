function agi_setup_logging(agi, numPts, options)
    % Setup dual-channel power meter logging
    arguments
        agi
        numPts {mustBeNumeric} % number of data points to capture (max 20,000)
        options.DetectorSlot (1,1) {mustBeInteger} = 2 % slot #
        options.DetectorIntTime (1,1) {mustBeNumeric} = 1e-4 % period of data point capture in seconds, same as integration time b/c logging
    end

    % check inputs a lil bit
    if(numPts > 20000)
        error("Number of points for Agilent power meter logging cannot exceeed 20,000");
    elseif(numPts < 1)
        error("Number of points for Agilent power meter logging must be at least 1");
    end
    if(options.DetectorIntTime < 1e-4)
        error("samplTime (%1.0f us) must be >= 100 us (cannot collect samples faster than 10 kHz)!", 1e6*samplTime)
    end

    % stop any logging that's in progress
    write(agi, sprintf(":SENS%d:CHAN1:FUNC:STAT LOGG,STOP", options.DetectorSlot));

    % enable logging
    sendStr = sprintf(":SENS%d:CHAN1:FUNC:PAR:LOGG %d, %f", ...
        options.DetectorSlot, numPts, options.DetectorIntTime);
    fwrite(agi, sendStr);
    
    % check that it actually did what we want
    readParamString = writeread(sprintf(agi, ":SENS%d:CHAN1:FUNC:PAR:LOGG?", options.DetectorSlot));
    readStringSplit = split(readParamString,',');
    readNumSamples = str2double(readStringSplit{1});
    if(readNumSamples ~= numPts)
        warning("Number of points returned by Agilent during logging setup (%d) not equal to number we asked it to log (%d)", ...
        readNumSamples, numPts);
    end
    readIntTime = str2double(readStringSplit{2});
    % note: agilent rounds to nearest of the following integration times:
    % 100 us, 200 us, 500 us, 1 ms, ...
    % if it rounds to an integration time longer than the logging, the
    % result will be glitchy (because it triggers measurements faster than
    % it can take them).
    if(readIntTime > samplTime)
        error(['Agilent detector integration time (%1.1f ms) exceeds ' ...
            'requested sampling period (%1.3f ms)! ' ...
            'This is caused when the Agilent detector rounds up the ' ...
            'requested sampling interval time to the nearest valid ' ...
            'integration time (100 us, 200 us, 500 us) instead of rounding ' ...
            'down. Please adjust settings such that the sampling interval ' ...
            'will round down to 100 us, 200 us, 500 us, 1 ms, etc. ' ...
            'E.g., it is known that logging intervals between ' ...
            '350-499 us do not work, because they round up to 500 us.'], ...
            readIntTime*1e3, samplTime*1e3);
    end
end

