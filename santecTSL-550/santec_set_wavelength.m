function santec_set_wavelength(santec, lambdaNm)
    % Set output wavelength in nm
    if(~isnumeric(lambdaNm))
        error("Second input must be numeric!");
    end

%     temp_wav = 1520.0;
%     TSL.Query(strcat('WA',num2str(temp_wav,'%.4f'))); pause(0.05)

    sendStr = sprintf('WA %.4f', lambdaNm);
    
    reply = santec.Query(sendStr);
    replyNum = str2double(reply.string);
    pause(2); % I don't know how to properly query Santec as to whether it's finished moving or not
    %extractedNum = str2double(result);
    ERROR_THRESHOLD = 0.1; % how many nm off before we worry
    if(abs(replyNum - lambdaNm) >= ERROR_THRESHOLD)
        warning('Commanded Santec to wavelength %1.2f nm, actual wavelength set to %1.2f nm', ...
            lambdaNm, replyNum);
    end

end

