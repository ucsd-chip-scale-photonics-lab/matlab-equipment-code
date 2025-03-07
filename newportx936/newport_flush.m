function newport_flush(np)
    % read without writes until buffer is empty
    MAX_ATTEMPTS = 1000;
    for i = 1:MAX_ATTEMPTS
        reply = newport_read(np);
        if(strcmp(reply, ""))
            return
        end
    end
    error("Did not flush buffer within %d tries", MAX_ATTEMPTS);
end

