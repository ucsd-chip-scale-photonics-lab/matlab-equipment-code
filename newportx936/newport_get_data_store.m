function out = newport_get_data_store(np)
%NEWPORT_GET_DATA_STORE Download full data store/buffer from newport
% There are limitations on the number of data points put in each message,
% so we have to download in several messages

    %
    disp("Downloading Newport data...");
    num_pts = str2double(newport_query(np, "PM:DS:COUNT?"));
    % TODO more robust preallocation size
    buffer1 = System.Text.StringBuilder(65536);
    buffer2 = System.Text.StringBuilder(65536);
    % NOTE: once you ask for this very long string of data, the newport will
    % keep spitting out pieces of it, no matter what command you use to query
    % it, until it's finished, so you gotta clean up after yourself after
    % issuing this command
    np.USB.Write(np.ID,strcat('PM:DS:GET? +',num2str(num_pts)));
    for kk=1:100   
        if np.USB.ReadBinary(np.ID,buffer2) ~=0
            break
        end
        buffer1.Append(buffer2);
        %pause(0.05)
    end
    A = string(buffer1.ToString());
    B = strsplit(A, '\n');
    data_start_idx = find(contains(B, "End of Header")) + 1;
    data_end_idx = find(contains(B, "End of Data")) - 1;
    % TODO actually use info in the header???
    % check if our parsing was reasonable
    if(data_end_idx - data_start_idx + 1 == num_pts)
        out = str2double(B(data_start_idx:data_end_idx));
    else
        error("Parsing error, data_start_idx = %d, data_end_idx = %d", data_start_idx, data_end_idx);
    end
end

