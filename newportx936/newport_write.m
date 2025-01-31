function newport_write(np, command)
% wrapper for newport write
    np.USB.Write(np.ID,command);
end

