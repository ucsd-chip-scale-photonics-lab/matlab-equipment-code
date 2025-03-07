function out = newport_read(np)
    buffer = System.Text.StringBuilder(65536);
    buffer.Clear();
    % talking to a specific device uses USB object AND ID
    np.USB.Read(np.ID,buffer);
    out = string(buffer.ToString); % convert to matlab string type
end

