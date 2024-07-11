function didFinish = agi_wait_for_logging(agi, estLoggingTime)
    % poke Agilent until sweep is finished, return true if it finished in
    % expected amount of time
    if ~exist('maxWaitTime', 'var')
        estLoggingTime = 15;
    end

    % once the logging starts, the VISA communication line will become
    % unresponsive until it finishes. So we should increase the VISA
    % timeout to a little more than the estimated duration of logging
    agi.Timeout = estLoggingTime + 3; 
    % if the logging starts, it is almost guaranteed that it will
    % eventually finish (in the absense of loss of connection etc.)

    % if sweep is complete, we get this:
    completeString = ['LOGGING_STABILITY,COMPLETE' newline()]; 
    % if sweep is in progress, we get this:
    progressString = ['LOGGING_STABILITY,PROGRESS' newline()];

    % Check once per second, up to a maximum number of seconds - we use
    % estLoggingTime for this for convenience, though once the sweep
    % actually starts, the query will hang until it finishes. The only time
    % we'll reach the full number of loops is if logging never starts.
    didFinish = false;
    for waitIdx = 1:estLoggingTime
        thisResponse = query(agi, ":SENS2:CHAN1:FUNC:STAT?");
        fwrite(agi, '*WAI');
        if(strcmp(thisResponse, completeString))
            disp('Agilent complete!');
            didFinish = true;
            return
        elseif(strcmp(thisResponse, progressString))
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
            error(['Unexpected response from Agilent: ' thisResponse]);
        end
        pause(1);
    end
end