function agi_output(agi, doTurnOn)
% Function to turn laser output on/off
    if(doTurnOn)
        % Laser output ON
        str = upper('sour0:pow:stat 1');
        fwrite(agi, str);
        fwrite(agi, '*WAI');
    else
        % Laser output OFF
        str = upper('sour0:pow:stat 0');
        fwrite(agi, str);
        fwrite(agi, '*WAI');
    end
end

