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

% Socket Model Lock State selection:
% 1 = all locked
% 2 = only pistoning unlocked
% 3 = only flexion unlocked
% 4 = only flexion and pistoning unlocked
% 5 = only Tx and Tz are locked, all other DoF are unlocked
% 6 = 6 DoF socket
LockStateBegin = 1;
LockStateEnd = 6;

% specify model folder
model_dir = ([pwd '\Models\AutoPlaced\']);

% specify model names in folder model_dir
% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_4dof_base.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_4dof_base.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_4dof_base.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_4dof_base.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_4dof_base.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_4dof_base.osim';

% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_4dof_base_orientation.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_4dof_base_orientation.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_4dof_base_orientation.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_4dof_base_orientation.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_4dof_base_orientation.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_4dof_base_orientation.osim';

% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_6dof_base_orient.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_6dof_base_orient.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_6dof_base_orient.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_6dof_base_orient.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_orient.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_orient.osim';

% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_6dof_base_static_align.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_6dof_base_static_align.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_6dof_base_static_align.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_6dof_base_static_align.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_static_align.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_static_align.osim';

% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_test.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_test.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_test.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_test.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_orient.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_orient.osim';

% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_6dof_base_locked_z.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_6dof_base_locked_z.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_6dof_base_locked_z.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_6dof_base_locked_z.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_locked_z.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_locked_z.osim';

models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_fixed_ankle.osim';
models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_fixed_ankle.osim';
models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_fixed_ankle.osim';
models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_fixed_ankle.osim';
models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_fixed_ankle.osim';
models{6} = 'A07_passive_FULL_auto_marker_place_6DOF__fixed_ankle.osim';

% specify .trc marker file repository 
trc_data_dir = ([pwd '\MarkerData\PREF']);

genericSetupPath = ([pwd '\IKSetup\']);
genericSetupForIK = 'A07_Setup_IK.xml';

%% Pull OpenSim modeling classes, specify folders and define ikTool

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

% % Ensure that 6DoF model exists based on 4DoF model
% if ~exist([model_dir models{6}], 'file')
%     modelFile6 = [model_dir models{5}];
%     model6 = Model(modelFile6);
%     coords = model6.getCoordinateSet();
%     coords.get('mtp_angle_r').setDefaultLocked(false);
%     coords.get('foot_flex').setDefaultLocked(false);
%     coords.get('socket_tx').setDefaultLocked(false);
%     coords.get('socket_ty').setDefaultLocked(false);
%     coords.get('socket_tz').setDefaultLocked(false);
%     coords.get('socket_flexion').setDefaultLocked(false);
%     coords.get('socket_adduction').setDefaultLocked(false);
%     coords.get('socket_rotation').setDefaultLocked(false);
%     model6.initSystem();
%     model6.print([model_dir models{6}]);
% end


% specify where results will be printed.
results_dir = ([pwd '\IKResults']);
if ~exist('IKResults', 'dir')
    mkdir('IKResults');
end
error_fold = 'IKErrors';
if ~exist('IKErrors', 'dir')
    mkdir('IKErrors');
end

ikTool = InverseKinematicsTool([genericSetupPath genericSetupForIK]);

%% main inverse kinematics loop
    
    
    %% loop through the different model dof lockstates
    for LockState = LockStateBegin:LockStateEnd % 6 socket states are defined
        
        %% load the model and initialize
        if ~exist([model_dir models{LockState}], 'file')
            modelFile = [model_dir models{5}];
            model = Model(modelFile);
            model.initSystem();
            model.print([model_dir models{LockState}]);
        end
        
        modelFile = [model_dir models{LockState}];
        model = Model(modelFile);

        %% get coordinates and set defaults that may be altered from scaling
        coords = model.getCoordinateSet();
        coords.get('mtp_angle_r').setDefaultLocked(false);
        coords.get('foot_flex').setDefaultLocked(false);

        %% Lock/unlock coordinates here!
        if LockState == 1

            % all locked
            coords.get('socket_tx').setDefaultLocked(true);
            coords.get('socket_ty').setDefaultLocked(true);
            coords.get('socket_tz').setDefaultLocked(true);
            coords.get('socket_flexion').setDefaultLocked(true);
            coords.get('socket_adduction').setDefaultLocked(true);
            coords.get('socket_rotation').setDefaultLocked(true);

            % name modification
%             nameMod = ([NameMod '_LockState1']);
        end
        if LockState == 2

            % flexion unlocked
            coords.get('socket_tx').setDefaultLocked(true);
            coords.get('socket_ty').setDefaultLocked(true);
            coords.get('socket_tz').setDefaultLocked(true);
            coords.get('socket_flexion').setDefaultLocked(false);
            coords.get('socket_adduction').setDefaultLocked(true);
            coords.get('socket_rotation').setDefaultLocked(true);

            % name modification
%             nameMod = ([NameMod '_LockState2']);

        end
        if LockState == 3

            % pistoning unlocked
            coords.get('socket_tx').setDefaultLocked(true);
            coords.get('socket_ty').setDefaultLocked(false);
            coords.get('socket_tz').setDefaultLocked(true);
            coords.get('socket_flexion').setDefaultLocked(true);
            coords.get('socket_adduction').setDefaultLocked(true);
            coords.get('socket_rotation').setDefaultLocked(true);

            % name modification
%             nameMod = ([NameMod '_LockState3']);

        end
        if LockState == 4

            % flexion/pistoning unlocked
            coords.get('socket_tx').setDefaultLocked(true);
            coords.get('socket_ty').setDefaultLocked(false);
            coords.get('socket_tz').setDefaultLocked(true);
            coords.get('socket_flexion').setDefaultLocked(false);
            coords.get('socket_adduction').setDefaultLocked(true);
            coords.get('socket_rotation').setDefaultLocked(true);
            
            % name modification
%             nameMod = ([NameMod '_LockState4']);

        end
        if LockState == 5

            % only tx and ty locked
            coords.get('socket_tx').setDefaultLocked(true);
            coords.get('socket_ty').setDefaultLocked(false);
            coords.get('socket_tz').setDefaultLocked(true);
            coords.get('socket_flexion').setDefaultLocked(false);
            coords.get('socket_adduction').setDefaultLocked(false);
            coords.get('socket_rotation').setDefaultLocked(false);

            % name modification
%             nameMod = ([NameMod '_LockState5']);

        end
        
        if LockState == 6

            % only tx and ty locked
            coords.get('socket_tx').setDefaultLocked(false);
            coords.get('socket_ty').setDefaultLocked(false);
            coords.get('socket_tz').setDefaultLocked(false);
            coords.get('socket_flexion').setDefaultLocked(false);
            coords.get('socket_adduction').setDefaultLocked(false);
            coords.get('socket_rotation').setDefaultLocked(false);

            % name modification
%             nameMod = ([NameMod '_LockState6']);

        end
        
        nameMod = ['_LockState' num2str(LockState)];
        
        model.initSystem();
        model.print([model_dir models{LockState}]);
            
        %% Tell Tool to use the loaded model
        
        ikTool.setModel(model);

        trialsForIK = dir(fullfile(trc_data_dir, '*.trc'));

        nTrials = size(trialsForIK);

        %% Loop through the trials
        for trial= 1:nTrials;

            % Get the name of the file for this trial
            markerFile = trialsForIK(trial).name;

            % Create name of trial from .trc file name
            nametemp = regexprep(markerFile,'.trc','');
            name = [nametemp nameMod];
            fullpath = ([trc_data_dir '\' markerFile]);

            % Get trc data to determine time range
            markerData = MarkerData(fullpath);

            % Get initial and intial time 
            initial_time = markerData.getStartFrameTime();
            final_time = markerData.getLastFrameTime();

            % Setup the ikTool for this trial
            ikTool.setName(name);
            ikTool.setMarkerDataFileName(fullpath);
            ikTool.setStartTime(initial_time);
            ikTool.setEndTime(final_time);
            ikTool.setOutputMotionFileName([results_dir '\' name '_ik.mot']);

            % Save the settings in a setup file
            outfile = ['Setup_IK_' name '.xml'];
            
            % Edit setup .xml with model path
            factorProp  = ikTool.getPropertyByName('model_file');
            % Set the value for this string to the model path
            PropertyHelper.setValueString(modelFile,factorProp);
            
            
            ikTool.print([genericSetupPath outfile]);

            % print progress to command window
            setupStr = (['IKSetup\' outfile]);
            fprintf(['Performing IK on trial # ' num2str(trial) ', Socket Lock State ' num2str(LockState) '\n']);

            % Run IK
%             ikTool.run();   
            [~, log_mes] = dos(['ik -S ' setupStr]);

            lines = strsplit(log_mes,'\n');
            nLines = size(lines,2);
            time = zeros(nLines-21,1); 
            TSE = zeros(nLines-21,1); 
            RMS = zeros(nLines-21,1);
            errMax = zeros(nLines-21,1);
            
            fileID = fopen([name '_ik_marker_errors.sto'], 'w');
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
            dlmwrite([name '_ik_marker_errors.sto'],errData,'-append','delimiter','\t','precision',8);
            
            fclose(fileID);
            
            % if error .sto file exists, move to IKErrors folder
            if exist([name '_ik_marker_errors.sto'], 'file')
                movefile([name '_ik_marker_errors.sto'],error_fold,'f');
            end
            
        end
        
        clear model

    end

fprintf('IK processing complete!');

% clear all


