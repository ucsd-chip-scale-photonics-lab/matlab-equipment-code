function [lambdaRange, lambdaSpeed] = venturi_sweep_setup(ven, inRate, startWave, stopWave)
    % set up laser for sweep, and return actual lambda range and sweep
    % speed that was set.
    % because the sweep only has one trigger at the start :c
    fwrite(ven, ':CONF:SWEE:MODE CONT'); % continuous sweep mode
    fwrite(ven, ':CONF:SWEE:TRIG IMME'); % software trigger
    
    % make sure everything is a number
    if(~isnumeric(startWave))
        error("Sweep start wavelength must be numeric!");
    end
    if(~isnumeric(stopWave))
        error("Sweep stop wavelength must be numeric!");
    end
    if(~isnumeric(inRate))
        error("Sweep rate must be numeric!");
    end
    % for some reason, the Venturi often gives a wrong response when we do
    % the query in this section. As such, we try this many times, and if
    % it gives a bad response that many times, only then do we throw an
    % error
    MAX_NUM_ATTEMPTS = 5;
    num_attempts = 0;
    while(num_attempts < MAX_NUM_ATTEMPTS)
        rateResponse = query(ven, sprintf(':CONF:SWEE:RATE %f', inRate));
        setRate = str2double(venturi_extract_result(rateResponse));
        if(~isnan(setRate))
            if(abs(setRate - inRate) >= 0.1)
                warning('Commanded Venturi to sweep rate %1.1f nm/s, actual rate set to %1.1f nm/s', ...
                    inRate, setRate);
            end
            break;
        end
        if(num_attempts == 0)
            warning("Sweep rate command didn't work first time, retrying...");
        else
            warning("...retrying again");
        end
    end
    if(isnan(setRate))
        error("Tried setting sweep rate %d times, still failed. Final response: %s", ...
            MAX_NUM_ATTEMPTS, rateResponse);
    end
    
    % sweep start/stop settings give a synax error for some reason, TODO
    setStart = str2double(venturi_extract_result(...
        query(ven, sprintf(':CONF:SWEE:STAR Continuous %f', startWave)), 3));
    if(abs(setStart - startWave) >= 0.1)
        warning('Commanded Venturi to start wavelength %1.2f nm, actual start wavelength set to %1.2f nm', ...
            startWave, setStart);
    end
    setStop = str2double(venturi_extract_result(...
        query(ven, sprintf(':CONF:SWEE:STOP Continuous %f', stopWave)), 3));
    if(abs(setStop - stopWave) >= 0.1)
        warning('Commanded Venturi to stop wavelength %1.2f nm, actual stop wavelength to %1.1f nm', ...
            stopWave, setStop);
    end
    
    % set current wavelength to sweep start wavelength
    venturi_set_wavelength(ven, setStart);
    
    lambdaRange = (setStop - setStart); % nm
    lambdaSpeed = setRate; % nm/s
end

