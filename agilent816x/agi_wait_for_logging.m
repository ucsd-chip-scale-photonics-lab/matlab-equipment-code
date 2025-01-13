function didFinish = agi_wait_for_logging(agi, options)
    % poke Agilent until sweep is finished, return true if it finished in
    arguments
        agi
        options.EstLoggingTime (1,1) {mustBeNumeric} = 15
        options.DetectorSlot (1,1) {mustBeInteger} = 2
    end

    % once the logging starts, the VISA communication line will become
    % unresponsive until it finishes. So we should increase the VISA
    % timeout to a little more than the estimated duration of logging
    agi.Timeout = round(options.EstLoggingTime + 3); 
    % if the logging starts, it is almost guaranteed that it will
    % eventually finish (in the absense of loss of connection etc.)

    % if sweep is complete, we get this: 'LOGGING_STABILITY,COMPLETE'
    % for robustness against a missing newline etc., to check for complete
    % we only check if these substrings are in it:
    completeString = ['LOGGING_STABILITY,COMPLETE']; 
    % if sweep is in progress, we check for this:
    progressString = ['LOGGING_STABILITY,PROGRESS'];

    % Check once per second, up to a maximum number of seconds - we use
    % estLoggingTime for this for convenience, though once the sweep
    % actually starts, the query will hang until it finishes. The only time
    % we'll reach the full number of loops is if logging never starts.
    didFinish = false;
    commandStr = sprintf(":SENS%d:CHAN1:FUNC:STAT?", options.DetectorSlot);
    for waitIdx = 1:options.EstLoggingTime
        thisResponse = writeread(agi, commandStr);
        write(agi, '*WAI');
        if(contains(thisResponse, completeString))
            disp('Agilent complete!');
            didFinish = true;
            return
        elseif(contains(thisResponse, progressString))
            if(waitIdx == 1)
                disp('Agilent power meter logging in progress...');
            else
                fprintf('.'); % dot dot dot loading
                if(mod(waitIdx,10) == 0)
                    fprintf('\n');
                end
            end
        else
            % we got some other response, error and print it
            warning('Unexpected response from Agilent: %s', thisResponse);
        end
        pause(1);
    end
end