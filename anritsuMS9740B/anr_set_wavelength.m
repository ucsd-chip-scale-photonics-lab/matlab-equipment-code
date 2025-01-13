function anr_set_wavelength(anr, startL, stopL)
%ANR_SET_WAVELENGTH Set start and stop lambda on OSA.
% input units are nm.
% TODO input verification
    fwrite(anr, sprintf("STA %f", startL));
    fwrite(anr, sprintf("STO %f", stopL));
end

