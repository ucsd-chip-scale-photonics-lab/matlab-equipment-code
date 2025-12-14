function out = newport_get_data_store(np, expected_num_points)
%NEWPORT_GET_DATA_STORE Download full data store/buffer from newport
% There are limitations on the number of data points put in each message,
% so we have to download in several messages

    %
    disp("Downloading Newport data...");
    num_pts = str2double(newport_query(np, "PM:DS:COUNT?"));
    % TODO more robust preallocation size
    % estimate total number of 
    SINGLE_DOWNLOAD_LENGTH = 4095;
    APPROX_HEADER_LENGTH = 500; % usually it's 300 I think, but need some extra margin
    BYTES_PER_DATA_POINT = 15;
    estimated_total_length = BYTES_PER_DATA_POINT*expected_num_points + APPROX_HEADER_LENGTH;
    % add 5 for some extra margin
    estimated_num_downloads = ceil(estimated_total_length/SINGLE_DOWNLOAD_LENGTH) + 5;

    buffer1 = System.Text.StringBuilder(estimated_total_length);
    buffer2 = System.Text.StringBuilder(65536);
    % NOTE: once you ask for this very long string of data, the newport will
    % keep spitting out pieces of it, no matter what command you use to query
    % it, until it's finished, so you gotta clean up after yourself after
    % issuing this command
    np.USB.Write(np.ID,strcat('PM:DS:GET? +',num2str(num_pts)));

    % sometimes, this download takes a painfully long time, so give message
    % every 10% if estimated_num_downlaods is big enough
    do_progress_bar = false;
    if(estimated_num_downloads > 10)
        do_progress_bar = true;
        time_update = 1;
        tic
        last_time = toc;
    end
    for kk=1:estimated_num_downloads
        status_code = np.USB.ReadBinary(np.ID,buffer2);
        if status_code ~=0
            break
        end
        buffer1.Append(buffer2);
        %pause(0.05)
        
        if(do_progress_bar)
            current_percent = 100*kk/estimated_num_downloads;
            if(toc - last_time > time_update)
                last_time = toc;
                fprintf('%2.0f%%..', current_percent);
            end
        end
    end
    if(do_progress_bar)
        fprintf("done! \n");
    end
    if(kk == estimated_num_downloads)
        warning("It took more messages than expected to download the data store, you may get a parsing error next...");
    end
    
    A = string(buffer1.ToString());
    if(strcmp(A, ""))
        error("Newport started returning blank messages when download started, restart matlab and the Newport");
    end
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

