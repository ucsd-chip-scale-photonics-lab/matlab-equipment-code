function rigo = rigolDP932A_start(options) 
    arguments
        options.Address = 'USB0::0x1AB1::0xA4A8::DP9A264601095::INSTR' % default to CPTF TCPIP address for 8164b
    end
    rigo = visadev(options.Address);
    rigo.Timeout=20; % set maximum waiting time [s]  
    disp(writeread(rigo, '*IDN?')); % enquires equipment info
end