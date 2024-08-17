function agi = agilent816x_start(options) 
    arguments
        options.Address = 'GPIB0::20::INSTR' % default to CPTF TCPIP address for 8164b
    end
    agi = visadev(options.Address);
    agi.Timeout=20; % set maximum waiting time [s]  
    disp(writeread(agi, '*IDN?')); % enquires equipment info
end