clear;
TSL = santec_start(SerialNumber = '24110045'); % "ans = NR" is an OK reponse to this!
%%
santec_set_wavelength(TSL, 1310);
%%
temp_wav = 1310.0;
TSL.Query(strcat('WA',num2str(temp_wav,'%.4f'))); pause(0.05)