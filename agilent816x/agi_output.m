function agi_output(agi, doTurnOn, options)
% Function to turn laser output on/off
    arguments
        agi
        doTurnOn
        options.LaserSlot (1,1) {mustBeInteger} = 0
    end
    if(doTurnOn)
        % Laser output ON
        str = sprintf('sour%d:pow:stat 1', options.LaserSlot);
    else
        % Laser output OFF
        str = sprintf('sour%d:pow:stat 0', options.LaserSlot);
    end
    write(agi, str);
    write(agi, '*WAI');
end

