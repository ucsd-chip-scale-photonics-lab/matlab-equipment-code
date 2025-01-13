function anr_set_res(anr, res, vbw)
%ANR_SET_ Set slit width and VBW on OSA
%   Detailed explanation goes here
    fwrite(anr, sprintf("RES %f", res));
    fwrite(anr, sprintf("VBW %f", vbw));
end

