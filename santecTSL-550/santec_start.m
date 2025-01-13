function TSL = santec_start()
    %dllPath = fullfile(pwd, 'matlab-equipment-code\santecTSL-550\Santec_FTDI.dll');
    dllPath = 'C:\Users\user\Desktop\Karl Johnson\Code\matlab-equipment-code\santecTSL-550\Santec_FTDI.dll';
    asmInfo = NET.addAssembly(dllPath); pause(1);
    TSL = Santec_FTDI.FTD2xx_helper('20060036');
    pause(1);
    TSL.Query('*IDN?')
end

