function N = agi_scan_setup(agi,sweep_speed,sweep_step,power,lambda_i,lambda_f,range)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Laser Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Trigger from laser goes to power meter
    fwrite(agi, 'trig:conf loop');
    fwrite(agi, '*WAI');
    
    % power unit: dBm
    fwrite(agi, 'outp0:pow:un dbm');
    fwrite(agi, '*WAI');
    
    % laser power
    str = upper(['sour0:pow ',num2str(power),'dBm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');

    % sweep mode: continuous
    fwrite(agi, 'sour0:wav:swe:mode cont');
    fwrite(agi, '*WAI');
    
    % sweep speed [nm/s]
    str = upper(['sour0:wav:swe:speed ',num2str(sweep_speed),'E-9']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');

    % start wavelength
    str = upper(['sour0:wav:swe:start ',num2str(lambda_i),'E-9']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');

    % stop wavelength
    str = upper(['sour0:wav:swe:stop ',num2str(lambda_f),'E-9']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % sweep step:
    str = upper(['sour0:wav:swe:step ',num2str(sweep_step),'E-9']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % amplitude modulation off (required to allow LLoging)
    fwrite(agi, 'sour0:am:stat off');
    fwrite(agi, '*WAI');
    
    % Output Trigger mode: step finished 
    fwrite(agi, 'trig0:outp stf');
    fwrite(agi, '*WAI'); 
    
    % Input Trigger mode: start sweep 
    fwrite(agi, 'trig0:inp sws');
    fwrite(agi, '*WAI');   
    
    % Laser channel: High output
%     str = upper('output0:path low');
    str = upper('output0:path high');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % Laser goes to start wavelength
    str = upper(['sour0:wav ',num2str(lambda_i),'nm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % Laser output ON
    str = upper('sour0:pow:stat 1');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    % Lambda logging ON: records the exact wavelength of a tunable laser
    % use upper('sour0:read:data? llog') to read this data
    fwrite(agi, 'sour0:wav:swe:llog 1');
    fwrite(agi, '*WAI');
    
    % N = number of sweep points
    N = query(agi,'sour0:wav:swe:exp?','%s','%d');
    fwrite(agi, '*WAI');
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Sensor Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Input trigger Mode:single measurement, giving one sample per trigger
    str = upper('trig2:chan1:inp sme');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    
    %Set Power Units: Watt
    str = upper('sens2:chan1:pow:unit 1');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Turn off power autorange
    str = upper('sens2:chan1:pow:rang:auto 0');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set Power Range
    str = upper(['sens2:chan1:pow:rang ' num2str(range) 'dbm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set Sensor Wavelength
    str = upper(['sens2:chan1:pow:wav ' num2str(+lambda_i) 'nm']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Stop any previous logging
    fwrite(agi,'sens2:chan1:func:stat logg,stop');
    fwrite(agi, '*WAI');
    
    %Expected number of triggers and Averaging time
    str = upper(['sens2:chan1:func:par:logg ' num2str(N) ',100us']);
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
    %Set input trigger mode
    str = upper('sens2:chan1:func:stat logg,star');
    fwrite(agi, str);
    fwrite(agi, '*WAI');
    
end
