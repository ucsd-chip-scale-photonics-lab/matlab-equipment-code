function N = agi_scan_setup(agi,options)
    arguments
        agi
        options.SweepSpeed (1,1) {mustBeNumeric} = 10 % nm/s
        options.SweepStep (1,1) {mustBeNumeric} = 0.1 % nm
        options.LaserPower (1,1) {mustBeNumeric} = 0 % dBm
        options.SweepStart (1,1) {mustBeNumeric} = 1530 % nm
        options.SweepStop (1,1) {mustBeNumeric} = 1570 % nm
        options.DetectorRange (1,1) {mustBeNumeric} = -10 % dBm
        options.DetectorSlot (1,1) {mustBeInteger} = 2 % slot #
        options.LaserSlot (1,1) {mustBeInteger} = 0 % slot #
        options.DoManualN (1,1) = false 
        options.DetectorIntTime (1,1) {mustBeNumeric} = 1e-4 % 100 us
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Laser Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % TODO better controllability of both detector channels in one slot


    % Trigger from laser goes to power meter
    write(agi, 'trig:conf loop');
    %fwrite(agi, '*WAI');
    
    % power unit: dBm
    write(agi, sprintf('outp%d:pow:un dbm', options.LaserSlot));
    
    % laser power
    str = sprintf("sour%d:pow %f dBm", options.LaserSlot, options.LaserPower);
    write(agi, str);

    % sweep mode: continuous
    write(agi, sprintf('sour%d:wav:swe:mode cont', options.LaserSlot));
    
    % sweep speed - include conversion to nm/s
    str = sprintf('sour%d:wav:swe:speed %e', options.LaserSlot, options.SweepSpeed*1e-9);
    write(agi, str);

    % start wavelength
    
    str = sprintf('sour%d:wav:swe:start %e', options.LaserSlot, options.SweepStart*1e-9);
    write(agi, str);
    % verify result
    % TODO VERIFY
    % startLambdaCheck = writeread(sprintf('sour%d:wav:swe:start?', options.LaserSlot));

    % stop wavelength
    str = sprintf('sour%d:wav:swe:stop %e', options.LaserSlot, options.SweepStop*1e-9);
    write(agi, str);
    
    % sweep step:
    str = sprintf('sour%d:wav:swe:step %e', options.LaserSlot, options.SweepStep*1e-9);
    write(agi, str);
    
    % amplitude modulation off (required to allow LLoging)
    write(agi, sprintf('sour%d:am:stat off', options.LaserSlot));
    
    % Output Trigger mode: step finished 
    write(agi, sprintf('trig%d:outp stf', options.LaserSlot));
    
    % Input Trigger mode: start sweep 
    write(agi, sprintf('trig%d:inp sws', options.LaserSlot));
    
    % Laser channel: High output
    % on TLS modules with two outputs, this says which one to use
    % I believe this only applies on slot 0 modules
    % TODO add option to switch this
    if(options.LaserSlot == 0)
        write(agi, sprintf('output%d:path high', options.LaserSlot));
    end
    
    % Send laser to start wavelength - the unit actually does this
    % automatically when you start a sweep, but doing it now makes the
    % "laser_scan" command trigger much faster, if that's needed for some
    % reason
    write(agi, sprintf('sour0:wav %f nm', options.LaserSlot, options.SweepStart));
    
    % Laser output ON
    agi_output(agi, true, LaserSlot = options.LaserSlot);
    
    % Lambda logging ON: records the exact wavelength of a tunable laser
    % use upper('sour0:read:data? llog') to read this data TODO write this
    % function
    write(agi, sprintf('sour%d:wav:swe:llog 1', options.LaserSlot));
    
    % N = number of sweep points
    % workaround for a broken 8164 that returns bogus result on the swe:exp
    % query
    if(options.DoManualN)
        N = (options.LambdaStop - options.LambdaStart)/options.LambdaStep + 1;
    else
        formatString = sprintf('sour%d:wav:swe:exp?', options.LaserSlot);
        N = writeread(agi,formatString,'%s','%d');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Sensor Parameters %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Set Sensor Wavelength
    str = sprintf('sens%d:chan1:pow:wav %f nm', options.DetectorSlot, options.SweepStart);
    write(agi, str);
    
    % set range    
    agi_set_range(agi, options.DetectorRange, DetectorSlot = options.DetectorSlot)

    % TODO CHECK IF INT TIME IS TOO LONG
    % use logging setup functions to setup and arm power logging
    agi_setup_logging(agi, N, DetectorSlot = options.DetectorSlot, ...
        DetectorIntTime = options.DetectorIntTime)

    % arm logging using "single" trigger - one per power measurement
    agi_arm_logging(agi, DetectorSlot = options.DetectorSlot, ...
        TriggerType = "single");    
end