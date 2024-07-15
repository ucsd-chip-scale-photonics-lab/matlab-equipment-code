function [channel1, channel2] = agi_get_logging_result(agi, options)

    % this function assumes we've checked LOGGING_STABILITY, COMPLETE
    % already
    arguments
        agi
        options.DetectorSlot (1,1) {mustBeInteger} = 2
    end

    % do an initial query to know # of bytes to read
    queryResult = writeread(agi,sprintf('sens%d:chan1:func:res?', options.DetectorSlot));
    if(char(queryResult(1)) ~= '#') %
        error("Logging result did not start with a #:" + dataIn);
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
    channel1 = getChannelResults(agi, 1, extraBytes, numBytes);
    channel2 = getChannelResults(agi, 2, extraBytes, numBytes);
end


function readingArray = getChannelResults(agi, channel, extraBytes, numBytes)
    % channel must be 1 or 2 (number)
    writeString = sprintf("sens%d:chan%d:func:res?", options.DetectorSlot, channel);
    write(agi,writeString);
    dataIn = fread(agi,extraBytes+numBytes,'uint8');
    % power meter readings have 4 bytes
    bytesPerReading = 4;
    numReadings = numBytes/bytesPerReading;
    readingArray = zeros(1,numReadings);
    for readingIdx = 1:numReadings
        byteIdx = extraBytes+bytesPerReading*(readingIdx-1);
        theseBytes = dataIn(byteIdx+1:byteIdx+4);
        readingArray(readingIdx) = typecast(uint8(theseBytes), 'single');
    end
end