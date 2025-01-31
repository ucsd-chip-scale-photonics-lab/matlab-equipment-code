function didFinish = newport_wait_for_logging(np, options)
% poke Newport until logging is finished, return true if it finished in time 
    arguments
        np
        options.EstLoggingTime (1,1) {mustBeNumeric} = 15
    end
    % download currently set buffer size from instrument
    buffer_size = str2double(newport_query(np, "PM:DS:SIZE?"));
    current_time = 0;
    while(current_time < options.EstLoggingTime)
        current_count = str2double(newport_query(np, "PM:DS:COUNT?"));
        if(current_count == buffer_size)
            fprintf('Done!\n');
            didFinish = true;
            return;
        end
        fprintf('%d...', current_count);
        pause(1); current_time = current_time + 1;
    end
    didFinish = false;
end

