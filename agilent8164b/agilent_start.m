function agi = agilent_start() 
    % hard-coded address
    agi = visa('agilent','TCPIP0::169.254.188.145::inst0::INSTR');
    agi.InputBufferSize = 5000000;   % set input buffer
    agi.OutputBufferSize = 5000000;  % set output buffer
    agi.Timeout=20; % set maximum waiting time [s]  
    fopen(agi); % open communication channel
    disp(query(agi, '*IDN?')); % enquires equipment info
end