%%
clear rigo
rigo=rigolDP932A_start();

%% CH3 settings
write(rigo,':APPL CH3,2,0.01')
write(rigo,':OUTP:OCP:STAT CH3,1')
write(rigo,':OUTP:OCP:VAL CH3,0.02')

write(rigo,':OUTP:OVP:STAT CH3,1')
write(rigo,':OUTP:OVP:VAL CH3,2.5')

write(rigo,':OUTP:STAT CH3,1')
%% CH2 settings
write(rigo,':APPL CH2,0.82,0.015')
write(rigo,':OUTP:OCP:STAT CH2,1')
write(rigo,':OUTP:OCP:VAL CH2,0.02')

write(rigo,':OUTP:OVP:STAT CH2,1')
write(rigo,':OUTP:OVP:VAL CH2,1.5')

write(rigo,':OUTP:STAT CH2,1')
%% CH1 settings
write(rigo,':APPL CH1,0,0.015')
write(rigo,':OUTP:OCP:STAT CH1,1')
write(rigo,':OUTP:OCP:VAL CH1,0.02')

write(rigo,':OUTP:OVP:STAT CH1,1')
write(rigo,':OUTP:OVP:VAL CH1,1.2')

write(rigo,':OUTP:STAT CH1,1')
%% switch off supplies

% write(rigo,':OUTP:STAT CH1,0');
% write(rigo,':OUTP:STAT CH2,0');
% write(rigo,':OUTP:STAT CH3,0');
