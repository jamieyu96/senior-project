%% DEVELOPMENT NOTES
% mat2wfdb used to write MATLAB variable into WDFB record file

% theta = 4 - 7.9 Hz
% Lower Alpha = 7.9 - 10 Hz
% Upper Alpha = 10 - 13 Hz % edited
% Lower Beta = 13 - 17.9 Hz
% Upper Beta = 18 - 24.9 Hz

%% Classification Criteria

% Sleep stage 1/2 consist of Theta Waves (4-8Hz, amplitude 10)
% Sleep stage 3/4 consist of Delta Waves (0-4Hz, amplitude 20-100)
% REM sleep (R) demonstrate characteristics similar to waking sleep
% = a combination of alpha, beta, and desynchronous waves

% There is no real division between stages 3 and 4 except that,
% typically, stage 3 is considered delta sleep in which less than 50 
% percent of the waves are delta waves, and in stage 4 more than 50 percent
% of the waves are delta waves. 
%% Loading signal data from MIT-BIH slpdb

% Read EEG signal (3 = 3rd column).
[tm,rawData] = rdsamp('slpdb/slp02a', 3);

% Read the annotation file. Each value represents a 30 second interval.
[~,~,~,~,~,comments] = rdann('slpdb/slp02a', 'st');

% Get the sleep stages only.
classifierAnnotations = getSleepStages(comments);

%% PRE-PROCESSING
windowDuration = 30; % seconds
Fs = 250; % samples (ticks)/second

% Calculate specifications for frequency domain.
dF = Fs/length(sleepStage1);       
f = -Fs/2:dF:Fs/2-dF;

% Filter for Theta waves
alphaHd = alphaFilter(Fs);
alphaFilteredData = filter(alphaHd, rawData);

betaHd = betaFilter(Fs);
betaFilteredData = filter(betaHd, rawData);

deltaHd = deltaFilter(Fs);
deltaFilteredData = filter(deltaHd, rawData);

thetaHd = thetaFilter(Fs);
thetaFilteredData = filter(thetaHd, rawData);

% Split the entire EEG signal recording into 30 second recordings.
% Do this for each type of filtered data.
[tArr, alphaWindows] = getWindows(alphaFilteredData, windowDuration, Fs);
[~, betaWindows] = getWindows(betaFilteredData, windowDuration, Fs);
[~, deltaWindows] = getWindows(deltaFilteredData, windowDuration, Fs);
[~, thetaWindows] = getWindows(thetaFilteredData, windowDuration, Fs);

% Test plotting an interval classified as Sleep Stage 2
% We can find a demo sleep stage 2 interval by searching the classifierArr
% For an index labeled as "2".
sleepStage3Index = find([classifierAnnotations{:}] == 3);
tSleepStage3 = tArr{sleepStage3Index(1)}; % Associated time values

sleepStage3InAlpha = alphaWindows{sleepStage3Index(1)};
sleepStage3InBeta = betaWindows{sleepStage3Index(1)};
sleepStage3InDelta = deltaWindows{sleepStage3Index(1)};
sleepStage3InTheta = thetaWindows{sleepStage3Index(1)};

DFT2Alpha = abs(fftshift(fft(sleepStage3InAlpha)));
DFT2Beta = abs(fftshift(fft(sleepStage3InBeta)));
DFT2Delta = abs(fftshift(fft(sleepStage3InDelta)));
DFT2Theta = abs(fftshift(fft(sleepStage3InTheta)));

%% Compare sleep stages through plotting.
fig1 = figure(1);
subplot(5,1,1)
plot(tSleepStage3, sleepStage3);
xlabel('Sample (250 samples/sec)')
ylabel('EEG Signal')
xlim([tSleepStage3(1) tSleepStage3(end)]);
set(gcf, 'Position', [0, 210, 1440, 800])
title('Theta Wave Filtered EEG Signal, Time Domain');
grid on

subplot(5,1,2)
plot(f, DFT2Delta);
xlabel('Frequency (Hz)');
xlim([-20 20]);
title('Delta Wave Filtered EEG Signal, Frequency Domain');
grid on

subplot(5,1,3)
plot(f, DFT2Theta);
xlabel('Frequency (Hz)');
xlim([-20 20]);
title('Theta Wave Filtered EEG Signal, Frequency Domain');
grid on

subplot(5,1,4)
plot(f, DFT2Alpha);
xlabel('Frequency (Hz)');
xlim([-20 20]);
title('Alpha Wave Filtered EEG Signal, Frequency Domain');
grid on

subplot(5,1,5)
plot(f, DFT2Beta);
xlabel('Frequency (Hz)');
xlim([-20 20]);
title('Beta Wave Filtered EEG Signal, Frequency Domain');
grid on

saveas(fig1, 'bandpass_filter.jpg');

%% CLASSIFICATION

xIndex2 = find(DFT2 == max(DFT2), 1, 'last');
maxXValue2 = f(xIndex2);

maxValues = [maxXValue2];

classifiedStageArr = zeros(1, length(maxValues));
for i = 1:length(maxValues)
    if (maxValues(i) >= 13) % Beta
        classifiedStageArr(i) = 1;
    elseif (maxValues(i) >= 4 && maxValues(i) <= 8) % Theta
        classifiedStageArr(i) = 2;
    elseif (maxValues(i) >= 0.5 && maxValues(i) < 4) % Delta
        classifiedStageArr(i) = 3;
    end
end