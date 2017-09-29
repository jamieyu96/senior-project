%% DEVELOPMENT NOTES
% mat2wfdb used to write MATLAB variable into WDFB record file

% TODO: write helper function to parse comments for numbers 1-4, and 'R'.
%% Loading signal data from MIT-BIH slpdb

% Read EEG signal (3 = 3rd column).
[tm,sleepStages] = rdsamp('slpdb/slp01a', 3);

% Read the annotation file. Each value represents a 30 second interval.
[ann,anntype,subtype,chan,num,comments] = rdann('slpdb/slp01a', 'st');

% Get the sleep stages only.
classifierArr = getSleepStages(comments);

Fs = 250; % samples (ticks)/second
windowDuration = 30; % seconds

% Split the entire EEG signal recording into 30 second recordings.
[tArr, windowedArr] = getWindows(sleepStages, 30, Fs);
%% Conditions for plotting
dt = 1/Fs;
t = 0:dt:30;
df = 1/30;
freq = -Fs/2:df:Fs/2;

%% Test plots
% Test plotting an interval classified as Sleep Stage 1
% We can find a demo sleep stage 1 interval by searching the classifierArr
% For an index labeled as "1".
sleepStage1Index = find([classifierArr{:}] == 1);
sleepStage1 = windowedArr{sleepStage1Index};
tSleepStage1 = tArr{sleepStage1Index};

% Test plotting an interval classified as Sleep Stage 4
sleepStage4Index = find([classifierArr{:}] == 4);
sleepStage4 = windowedArr{sleepStage4Index};
tSleepStage4 = tArr{sleepStage4Index}; % Associated time values

fig1 = figure(1);
subplot(2,2,1)
plot(tSleepStage1, sleepStage1);
xlabel('Sample (250 samples/sec)')
ylabel('EEG Signal')
xlim([tSleepStage1(1) tSleepStage1(end)]);
set(gcf, 'Position', [0, 210, 1400, 600])
title('Sleep Stage 1, Time Domain');
grid on

subplot(2,2,2)
plot(tSleepStage4, sleepStage4);
xlabel('Sample (250 samples/sec)')
ylabel('EEG Signal')
xlim([tSleepStage4(1) tSleepStage4(end)]);
set(gcf, 'Position', [0, 210, 1440, 800])
title('Sleep Stage 4, Time Domain');
grid on


