function [lambda_array] = agi_get_lambda_logging_result(agi, options)
    arguments
        agi
        options.LaserSlot (1,1) {mustBeInteger} = 0
    end
    read_command = sprintf("sour%d:read:data? llog", options.LaserSlot);
    lambda_array = agi_download_float_array(agi, read_command, Precision = 8);    
end