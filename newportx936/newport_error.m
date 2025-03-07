function this_error = newport_error(np, options)
    arguments
        np
        options.DoDisplay = true
    end
    % print last error from error queue
    this_error = newport_query(np, "ERRSTR?");
    if(options.DoDisplay)
        disp(this_error);
    end
end

