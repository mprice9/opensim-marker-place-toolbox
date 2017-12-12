%-------------------------------------------------------------------------
% AB_IK_Processed_Data.m
%-------------------------------------------------------------------------

clear
clc
close all

%% Load data

convTypes = [1 2 3 4 5 6 7 8 9 10 20 30 40 50];

for convValue = 1:length(convTypes)

dataSetName = ['10TiltLockedASIS' num2str(convTypes(convValue)) 'Conv'];
logDir = ['Logs\thresh' num2str(convTypes(convValue)) ];

% figDir = ['Figures\' dataSetName '\'];
% if ~exist(figDir, 'dir')
%     mkdir(figDir);
% end

load(['fullNormData' dataSetName '.mat']);
load(['fullErrData' dataSetName '.mat']);
load('fullTags.mat');
load('subjNames.mat');

numSubj = size(fullNormData,1);

%% Error comparison setup
fprintf('parsing error statistics\n')

% err = zeros(2,3,numSubj);
% errStd = zeros(2,3,numSubj);
    errFast = zeros(2,numSubj);
    errFastStd = zeros(2,numSubj);
    errPref = zeros(2,numSubj);
    errPrefStd = zeros(2,numSubj);
    errSlow = zeros(2,numSubj);
    errSlowStd = zeros(2,numSubj);

% speed = [];
% if FAST_flag == 1;speed=1;end
% if PREF_flag == 1;speed=[speed 2];end
% if SLOW_flag == 1;speed=[speed 3];end

% errGenPref = zeros(2,5*numSubj);
% errGenPrefMax = zeros(2,5*numSubj);
% errGenSlow = zeros(2,5*numSubj);
% errGenSlowMax = zeros(2,5*numSubj);
% errGenFast = zeros(2,5*numSubj);
% errGenFastMax = zeros(2,5*numSubj);



for subj = 1:numSubj
%     for currSpeed = speed
        for placetype = 1:2
            errFast(placetype,subj) = fullErrData{subj}{1,4}{placetype}(1,3);
            errFastStd(placetype,subj) = fullErrData{subj}{1,5}{placetype}(2,3);
            errPref(placetype,subj) = fullErrData{subj}{2,4}{placetype}(1,3);
            errPrefStd(placetype,subj) = fullErrData{subj}{2,5}{placetype}(2,3);
            errSlow(placetype,subj) = fullErrData{subj}{3,4}{placetype}(1,3);
            errSlowStd(placetype,subj) = fullErrData{subj}{3,5}{placetype}(2,3);
            for trial = 1:5
                errGenPref(placetype,trial + (5*(subj-1))) = fullErrData{subj}{2,3}{placetype,trial}(1,3);
                errGenPrefMax(placetype,trial + (5*(subj-1))) = fullErrData{subj}{2,3}{placetype,trial}(3,3);
                errGenFast(placetype,trial + (5*(subj-1))) = fullErrData{subj}{1,3}{placetype,trial}(1,3);
                errGenFastMax(placetype,trial + (5*(subj-1))) = fullErrData{subj}{1,3}{placetype,trial}(3,3);
                errGenSlow(placetype,trial + (5*(subj-1))) = fullErrData{subj}{3,3}{placetype,trial}(1,3);
                errGenSlowMax(placetype,trial + (5*(subj-1))) = fullErrData{subj}{3,3}{placetype,trial}(3,3);
            end
        end
%     end
end

errGenPrefMean{convValue} = mean(errGenPref,2);
errGenPrefMaxMean{convValue} = mean(errGenPrefMax,2);
errGenPrefStd{convValue} = std(errGenPref,0,2);
errGenPrefMaxStd{convValue} = std(errGenPrefMax,0,2);

normErrPrefMean(convValue) = errGenPrefMean{convValue}(2)./errGenPrefMean{convValue}(1);
normErrPrefMaxMean(convValue) = errGenPrefMaxMean{convValue}(2)./errGenPrefMaxMean{convValue}(1);
normErrPrefStd(convValue) = errGenPrefStd{convValue}(2)./errGenPrefMean{convValue}(1);
normErrPrefMaxStd(convValue) = errGenPrefMaxStd{convValue}(2)./errGenPrefMaxMean{convValue}(1);

errGenFastMean{convValue} = mean(errGenFast,2);
errGenFastMaxMean{convValue} = mean(errGenFastMax,2);
errGenFastStd{convValue} = std(errGenFast,0,2);
errGenFastMaxStd{convValue} = std(errGenFastMax,0,2);

normErrFastMean(convValue) = errGenFastMean{convValue}(2)./errGenFastMean{convValue}(1);
normErrFastMaxMean(convValue) = errGenFastMaxMean{convValue}(2)./errGenFastMaxMean{convValue}(1);
normErrFastStd(convValue) = errGenFastStd{convValue}(2)./errGenFastMean{convValue}(1);
normErrFastMaxStd(convValue) = errGenFastMaxStd{convValue}(2)./errGenFastMaxMean{convValue}(1);

errGenSlowMean{convValue} = mean(errGenSlow,2);
errGenSlowMaxMean{convValue} = mean(errGenSlowMax,2);
errGenSlowStd{convValue} = std(errGenSlow,0,2);
errGenSlowMaxStd{convValue} = std(errGenSlowMax,0,2);

normErrSlowMean(convValue) = errGenSlowMean{convValue}(2)./errGenSlowMean{convValue}(1);
normErrSlowMaxMean(convValue) = errGenSlowMaxMean{convValue}(2)./errGenSlowMaxMean{convValue}(1);
normErrSlowStd(convValue) = errGenSlowStd{convValue}(2)./errGenSlowMean{convValue}(1);
normErrSlowMaxStd(convValue) = errGenSlowMaxStd{convValue}(2)./errGenSlowMaxMean{convValue}(1);

fprintf('complete\n')

%% Kinematics averaging over all subjects
fprintf('parsing kinematics statistics\n')

kinData = cell(3,2,length(fullTags{1}));
kinDataMean = cell(3,2,length(fullTags{1}));
kinDataStd = cell(3,2,length(fullTags{1}));

for subj = 1:numSubj
    for speed = 1:3
        for placetype = 1:2
            for var = 1:size(fullNormData{subj}{speed,2}{1},2)
%                 for samp = 1:101
                    h = zeros(101,1);
                    nTrials = size(fullNormData{subj}{speed,2},2);
                    for trial = 1:nTrials 
                        h(:,trial) = fullNormData{subj}{speed,2}{placetype,trial}(:,var);
                    end 
                    kinData{speed,placetype,var} = [kinData{speed,placetype,var} h];
                    kinDataMean{speed,placetype,var} = mean(kinData{speed,placetype,var},2);
                    kinDataStd{speed,placetype,var} = std(kinData{speed,placetype,var},0,2);
                    clear h
%                 end
            end
        end
    end
end

fprintf('complete\n')

%% Read log data and extract time

logs = dir(fullfile(logDir, '*.txt'));
time = zeros(size(logs,1),1);
for i = 1:size(logs)
    
    logFile = logs(i).name;            
    fullLogPath = ([logDir '\' logFile]);
    f = fopen(fullLogPath);
    logData = textscan(f, '%s');
    timeTemp = logData{1}{end,1};
    time(i) = str2double(timeTemp(1:end-2));
    fclose(f);
end
timeAvg(convValue) = mean(time);
timeStd(convValue) = std(time);

end


%% plot figure
figure
hold on

for i = 1:length(convTypes)
    errorbar(timeAvg(i),normErrPrefMean(i),normErrPrefStd(i),normErrPrefStd(i),timeStd(i),timeStd(i),'o')
end

legend('1mm','2mm','3mm','4mm','5mm','6mm','7mm','8mm','9mm','10mm','20mm','30mm','40mm','50mm');
title('Effect of convergence criteria strictness')
ylabel('Normalized IK error')
xlabel('Time per subject (s)')