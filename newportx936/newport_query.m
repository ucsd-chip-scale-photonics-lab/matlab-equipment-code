function out = newport_query(np, command)
    buffer = System.Text.StringBuilder(65536);
    buffer.Clear();
    % talking to a specific device uses USB object AND ID
    np.USB.Query(np.ID,command,buffer);
    out = string(buffer.ToString); % convert to matlab string type
end

