[file, location] = uigetfile('.mat', 'Select One or More Files', 'MultiSelect', 'on');
if(iscell(file))
    numFiles = length(file);
else
    numFiles = 1;
    file = {file};
end
%%

figure(units="inches", Position=[3 3 3 2.5]); hold on;
for i = 1:numFiles
    load(fullfile(location, file{i}), 'channel1Looped', 'lambdaArrayLooped');
    
    numScans = length(channel1Looped);
    for j = 1:numScans
        thisData = channel1Looped{j};%/max(channel1Looped{j});
        thisData(thisData > 1) = NaN;
        if(j == 1)
            p = plot(lambdaArrayLooped{j}, 10*log10(abs(thisData)) + 30, '.-', DisplayName = file{i});
            thisColor  = p.Color;
        else
            p = plot(lambdaArrayLooped{j}, 10*log10(abs(thisData)) + 30, '.-', Color = thisColor, HandleVisibility = 'off');
        end
    end
    clear channel1Looped lambdaArrayLooped
end
hold off; legend(Interpreter="none",Location="best");
xlabel("Wavelength (nm)"); ylabel("Power (dB)");