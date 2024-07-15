function agi = agilent816x_start(options) 
    arguments
        options.Address = 'TCPIP0::169.254.188.145::inst0::INSTR' % default to CPTF TCPIP address for 8164b
    end
    agi = visadev(options.Address);
    agi.Timeout=20; % set maximum waiting time [s]  
    disp(writeread(agi, '*IDN?')); % enquires equipment info
end