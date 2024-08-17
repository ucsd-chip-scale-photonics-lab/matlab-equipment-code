function [float_array] = agi_download_float_array(agi, command, options)
    arguments
        agi
        command % command that is queried to get the data
        options.Precision (1,1) {mustBeMember(options.Precision,[4,8])} = 4
    end

    % do an initial query to know # of bytes to read
    queryResult = char(writeread(agi,command));
    if(char(queryResult(1)) ~= '#') %
        error("Float array query result did not start with a #:" + dataIn);
    end
    % number of digits in following number of bytes
    numDigits = str2double(queryResult(2));
    % number of bytes comprising result
    numBytes = str2double(queryResult(3:3+numDigits-1));
    % now, we can do an fread to get those bytes - can't do a query as some
    % of the bytes may be same as EOF which ends query
    % must add a few bytes to the beginning since the beginning of the
    % buffer has that stuff we just used above
    extraBytes = 2 + numDigits;
    % now do real download
    % increase buffer size
    agi.InputBufferSize = extraBytes+numBytes + 100; % +100 to be safe
    write(agi,command);
    dataIn = fread(agi,extraBytes+numBytes,'uint8');
    % single precision float readings have 4 bytes
    bytesPerReading = options.Precision;
    numReadings = numBytes/bytesPerReading;
    float_array = zeros(1,numReadings);
    for readingIdx = 1:numReadings
        byteIdx = extraBytes+bytesPerReading*(readingIdx-1);
        theseBytes = dataIn(byteIdx+1:byteIdx+bytesPerReading);
        if(options.Precision == 4)
            floatType = 'single';
        else
            floatType = 'double';
        end
        float_array(readingIdx) = typecast(uint8(theseBytes), floatType);
    end
end