[file, location] = uigetfile('.mat', 'Select One or More Files', 'MultiSelect', 'on');
if(iscell(file))
    numFiles = length(file);
else
    numFiles = 1;
    file = {file};

end
%%
figure; hold on; 
colors = cool(numFiles);
colororder(colors);
for i = 1:numFiles
    clear newport_data lambdaArray
    load(fullfile(location, file{i}), 'newport_data', 'lambdaArray');
    plot(lambdaArray, newport_data, 'DisplayName', file{i});
    plot_name = file{i};
end
hold off;
l = legend();
%set(l, "Interpreter", "none");
xlabel("Wavelength (nm)"); ylabel("Power (dBm)");
%% FFTs
figure; 
for i = 1:numFiles
    clear channel1 channel2 lambdaArray
    %load(fullfile(location, file{i}), 'channel1', 'channel2', 'lambdaArray');
    load(fullfile(location, file{i}), 'powerArray', 'lambdaArray');
    c = 2.998e8;
    lambdaArrayMeters = 1e-9*lambdaArray;
    nuArray = c./lambdaArrayMeters;
    thisDnu = abs(nuArray(2) - nuArray(1));
    thisTransmission = powerArray; %./channel2;
    thisTransNorm = thisTransmission - mean(thisTransmission); %/max(thisTransmission);
    %thisTransNorm = 10*log10(thisTransmission/max(thisTransmission)); l
    oversample = 4;
    N = oversample*length(thisTransNorm);
    thisFFT = abs(fft(thisTransNorm,N)).^2;
    %thisDlambda = lambdaArray(2)-lambdaArray(1); % assumes uniform


    thisFreqAxis = (0:N-1)/(N*thisDnu); thisMaxN = round(N/2);
    thisDistance = c*thisFreqAxis;
    loglog(1e3*thisDistance(1:thisMaxN), thisFFT(1:thisMaxN)./max(thisFFT), 'DisplayName', file{i});
    if(i == 1)
        hold on;
    end
end
hold off; legend();
xlabel("Distance (mm)"); ylabel("Power spectral density");


%% low pass filter
numAvg = 50;
h = [1/2 1/2];
binomialCoeff = conv(h,h);
for n = 1:numAvg
    binomialCoeff = conv(binomialCoeff, h);
end

numFiles = length(file);
figure; hold on;
for i = 1:numFiles
    clear channel1 channel2 lambdaArray
    load(fullfile(location, file{i}), 'channel1', 'channel2', 'lambdaArray');
    
    movingFilter = ones(1,numAvg)/numAvg;
    filteredC1 = filter(binomialCoeff, 1, channel1);
    plot(lambdaArray, 10*log10(filteredC1./channel2), 'DisplayName', file{i});
end
hold off