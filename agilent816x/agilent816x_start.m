function agi = agilent816x_start() 
    % hard-coded address
    agi = visadev('TCPIP0::169.254.188.145::inst0::INSTR');
    agi.Timeout=20; % set maximum waiting time [s]  
    disp(writeread(agi, '*IDN?')); % enquires equipment info
end