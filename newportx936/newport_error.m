function newport_error(np)
    % print last error from error queue
    newport_query(np, "ERRSTR?")
end

