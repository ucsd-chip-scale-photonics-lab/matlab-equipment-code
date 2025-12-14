function out = newport_query(np, command)
    buffer = System.Text.StringBuilder(65536);
    buffer.Clear();
    % talking to a specific device uses USB object AND ID
    np.USB.Query(np.ID,command,buffer);
    out = string(buffer.ToString); % convert to matlab string type
    if(out == "")
        warning("Newport returning blank messages upon queries, the cause of this issue has not yet been identified. Please restart MATLAB and try again.");
    end
end

