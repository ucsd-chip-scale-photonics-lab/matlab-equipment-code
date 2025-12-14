function TSL = santec_start(options)
    arguments
        options.SerialNumber = '20060036'
    end
    dllPath = fullfile(pwd, 'matlab-equipment-code\santecTSL-550\Santec_FTDI.dll');
    asmInfo = NET.addAssembly(dllPath); pause(1);
    TSL = Santec_FTDI.FTD2xx_helper(options.SerialNumber);
    pause(1);
    TSL.Query('*IDN?')
end

