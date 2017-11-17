%-------------------------------------------------------------------------% 
% AmpModel_IK_Batch.m
% 
% This file analyzes the marker data from subject A01, and performs IK.
% Files and directories are dependent on the location of the files on this
% pc, if the directories change you will have to relocate the files. 
% 
% Before running, ensure the following folders are in the parent working
% directory:
%     IKErrors        Where marker errors are written for each trial
%     IKResults       Where kinematic results are  written for each trial
%     IKSetup         Contains generic setup file and trial specific setup 
%                     files are written
%     MarkerData      Contains marker trajectory files for each trial
%     ModelsScaled    Contains the models used in IK
%
% Before running, modify script options cell appropriately.
% 
% Written by Andrew LaPre 12/2015
% Last modified 07/10/2017
%
%-------------------------------------------------------------------------%

close all
clear all
clc

%% script options

% Create strings for the subject name and type of prosthesis.
subjNames = {'S01','S02','S04','S05','S06','S08','S09','S10'};
numSubj = length(subjNames);

% Also define paths to individual subject and model folders in options structure
for i = 1:numSubj
    
    subjDir{i} = [pwd '\' subjNames{i} '\'];
    
    % specify model folder
    modelDir{i} = [subjDir{i} 'Models\AutoPlaced\'];
    
    trcDataDirPref{i} = [subjDir{i} 'MarkerData\PREF'];
    trcDataDirSlow{i} = [subjDir{i} 'MarkerData\SLOW'];
    trcDataDirFast{i} = [subjDir{i} 'MarkerData\FAST'];
    genericSetupDir{i} = [subjDir{i} 'IKSetup\'];
    
    % specify where results will be printed.
    resultsDir{i} = [subjDir{i} 'IKResults\AutoPlaceNoTiltReal\'];
    errorDir{i} = [subjDir{i} 'IKErrors\AutoPlaceNoTiltReal\'];
%     resultsDir{i} = [subjDir{i} 'IKResults\AutoPlace100Tilt\'];
%     errorDir{i} = [subjDir{i} 'IKErrors\AutoPlace100Tilt\'];
%     resultsDir{i} = [subjDir{i} 'IKResults\StdMarkerPlaceMe\'];
%     errorDir{i} = [subjDir{i} 'IKErrors\StdMarkerPlaceMe\'];
    
    if ~exist(resultsDir{i}, 'dir')
        mkdir(resultsDir{i});
    end
    
    if ~exist(errorDir{i}, 'dir')
        mkdir(errorDir{i});
    end
end

runPref = true;
runFast = true;
runSlow = true;

% specify model names in folder model_dir
% inputModels{1} = 'S01_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{2} = 'S02_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{3} = 'S04_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{4} = 'S05_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{5} = 'S06_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{6} = 'S08_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{7} = 'S09_no-amp_ALLBODY_auto_marker_place_PSF.osim';
% inputModels{8} = 'S10_no-amp_ALLBODY_auto_marker_place_PSF.osim';

% inputModels{1} = 'S01_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{2} = 'S02_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{3} = 'S04_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{4} = 'S05_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{5} = 'S06_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{6} = 'S08_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{7} = 'S09_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';
% inputModels{8} = 'S10_no-amp_ALLBODY_auto_marker_place_PSF_notilt.osim';

inputModels{1} = 'S01_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{2} = 'S02_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{3} = 'S04_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{4} = 'S05_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{5} = 'S06_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{6} = 'S08_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{7} = 'S09_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';
inputModels{8} = 'S10_no-amp_ALLBODY_auto_marker_place_notilt_real.osim';

% inputModels{1} = 'S01_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{2} = 'S02_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{3} = 'S04_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{4} = 'S05_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{5} = 'S06_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{6} = 'S08_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{7} = 'S09_no-amp_ALLBODY_auto_marker_place_100tilt.osim';
% inputModels{8} = 'S10_no-amp_ALLBODY_auto_marker_place_100tilt.osim';

% inputModels = {'S01_RRA_Model_PSF_newmass.osim',...
%     'S02_RRA_Model_PSF_newmass.osim','S04_RRA_Model_newmass.osim',...
%     'S05_Scaled_BK_5.osim','S06_RRA_Model_newmass.osim',...
%     'S08_RRA_Model_newmass.osim','S09_RRA_Model_newmass.osim',...
%     'S10_RRA_Model_newmass.osim'};

genericSetupForIK{1} = 'S01_PSF_T06_IK_Settings.xml';
genericSetupForIK{2} = 'S02_PSF_T01_IK_Settings.xml';
genericSetupForIK{3} = 'S04_PSF_T02_IK_Settings.xml';
genericSetupForIK{4} = 'S05_PSF_T01_IK_Settings.xml';
genericSetupForIK{5} = 'S06_PSF_T02_IK_Settings.xml';
genericSetupForIK{6} = 'S08_PSF_T04_IK_Settings.xml';
genericSetupForIK{7} = 'S09_PSF_T03_IK_Settings.xml';
genericSetupForIK{8} = 'S10_PSF_T03_IK_Settings.xml';

%% Pull OpenSim modeling classes, specify folders and define ikTool

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

for i = 1:numSubj
    
%     ikTool = InverseKinematicsTool([genericSetupDir{i} genericSetupForIK]);
    
    % load the model and initialize
    modelFile = [modelDir{i} inputModels{i}];
    model = Model(modelFile);
    model.initSystem();
    
    trialsForIK = [];

    if runPref == true
        trialsForIK = [trialsForIK; dir(fullfile(trcDataDirPref{i}, '*.trc'))];
    end
    
    if runSlow == true
        trialsForIK = [trialsForIK; dir(fullfile(trcDataDirSlow{i}, '*.trc'))];
    end
    
    if runFast == true
        trialsForIK = [trialsForIK; dir(fullfile(trcDataDirFast{i}, '*.trc'))];
    end
    
    nTrials = size(trialsForIK);
    
    %% Loop through the trials
    for trial= 1:nTrials

        % Get the name of the file for this trial
        markerFile = trialsForIK(trial).name;
        folder = trialsForIK(trial).folder;

        % Create name of trial from .trc file name
        name = regexprep(markerFile,'.trc','');
        fullpath = [folder '\' markerFile];

%         % Get trc data to determine time range
%         markerData = MarkerData(fullpath);
        
        setupFile = [genericSetupDir{i} name '_IK_Settings.xml'];
        ikTool = InverseKinematicsTool(setupFile);
        
        % Tell Tool to use the loaded model
        ikTool.setModel(model);

        outputMotionFile = [resultsDir{i} name '_ik.mot'];
        
        % Edit setup .xml with model path
        factorProp  = ikTool.getPropertyByName('model_file');
        PropertyHelper.setValueString(modelFile,factorProp); % Set the value for this string to the model path
        factorProp  = ikTool.getPropertyByName('marker_file');
        PropertyHelper.setValueString(fullpath,factorProp); % Set the .trc marker file path in the setup .xml
        factorProp  = ikTool.getPropertyByName('output_motion_file');
        PropertyHelper.setValueString(outputMotionFile,factorProp); % Set the model path in the setup .xml

        ikTool.print(setupFile);

        % print progress to command window
        fprintf(['Performing IK on trial # ' num2str(trial) ', Subject ' subjNames{i} '\n']);

        % Run IK
%             ikTool.run();   
        [~, log_mes] = dos(['ik -S ' setupFile]);

        lines = strsplit(log_mes,'\n');
        nLines = size(lines,2);
        time = zeros(nLines-21,1); 
        TSE = zeros(nLines-21,1); 
        RMS = zeros(nLines-21,1);
        errMax = zeros(nLines-21,1);

        fileID = fopen([errorDir{i} name '_ik_marker_errors.sto'], 'w');
        message = ['Model Marker Errors from IK \nversion=1 \nnRows=' num2str(length(time)) '\nnColums=4 \ninDegrees=no \nendheader \n'];
        fprintf(fileID, message);
        message = ['time\ttotal_squared_error\tmarker_error_RMS\tmarker_error_max \n'];
        fprintf(fileID, message);

        for line = 19:nLines-3

            frame = strsplit(lines{line},{'\t', ' ',',','='});
            temptime = frame{1,4};
            temptime(end-1:end) = [];
            time(line-18,1) = str2double(temptime);
            TSE(line-18,1) = str2double(frame{1,8});
            RMS(line-18,1) = str2double(frame{1,12});
            errMax(line-18,1) = str2double(frame{1,14});

        end

        errData = [time TSE RMS errMax];
        dlmwrite([errorDir{i} name '_ik_marker_errors.sto'],errData,'-append','delimiter','\t','precision',8);

        fclose(fileID);

%         % if error .sto file exists, move to IKErrors folder
%         if exist([name '_ik_marker_errors.sto'], 'file')
%             movefile([name '_ik_marker_errors.sto'],errorDir{i},'f');
%         end

    end
    
end


fprintf('IK processing complete!');

% clear all


