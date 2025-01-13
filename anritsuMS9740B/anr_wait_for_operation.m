function anr_wait_for_operation(anr, options)
    arguments
        anr
        options.MaxWaitTime (1,1) {mustBeInteger} = 10 % max wait time, s
    end
    anr.Timeout = options.MaxWaitTime;
    % querying the operation complete bit hangs until a sweep is done
    if(query(anr, "*OPC?"))
        return
    else
        warning("OPC query returned false! Not sure how this could happen...")
    end

