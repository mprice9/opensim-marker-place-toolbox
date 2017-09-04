%-------------------------------------------------------------------------% 
% AmpModel_ID_Batch.m
% 
% This file analyzes the coordinate data from IK and calculates Inverse
% Dynamics.
% 
% Before running, ensure the following folders are in the working
% directory:
%     IKResults       Contains kinematic results for each trial
%     MarkerData      Contains marker trajectory files for each trial
%     ModelsScaled    Contains the models used in ID
%     ExtForces       Contains external force files from experimental data
%     IDSetup         Contains generic setup filefor ID
%     IDResults       Where ID results are written
%
% Before running, modify script options cell appropriately.
% 
% Written by Andrew LaPre, Mark Price 2/2016
% Last modified 8/10/2017
%
%-------------------------------------------------------------------------%

close all
clear all
clc

%% script options

% specify model names in folder ModelsScaled\4.0Models\
% models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_6dof_base_locked_z.osim';
% models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_6dof_base_locked_z.osim';
% models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_6dof_base_locked_z.osim';
% models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_6dof_base_locked_z.osim';
% models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_locked_z.osim';
% models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_locked_z.osim';

models{1} = 'A07_passive_FULL_auto_marker_place_RIGID_6dof_base_locked_z_mod_foot.osim';
models{2} = 'A07_passive_FULL_auto_marker_place_FLEXION_ONLY_6dof_base_locked_z_mod_foot.osim';
models{3} = 'A07_passive_FULL_auto_marker_place_PISTON_ONLY_6dof_base_locked_z_mod_foot.osim';
models{4} = 'A07_passive_FULL_auto_marker_place_FLEXION_PISTON_6dof_base_locked_z_mod_foot.osim';
models{5} = 'A07_passive_FULL_auto_marker_place_4DOF_6dof_base_locked_z_mod_foot.osim';
models{6} = 'A07_passive_FULL_auto_marker_place_6DOF_6dof_base_locked_z_mod_foot.osim';

% specify the original trials
PREF = {'0002', '0003', '0005'};

%% Pull OpenSim modeling classes, specify folders and define idTool

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

% specify model folder
model_folder = ([pwd '\Models\AutoPlaced\']);
% model_folder = ([pwd '\Models\ModelsScaled\NormalSocket\']);

% Go to the folder in the subject's folder where .mot files are
grf_data_folder = ([pwd '\ExtForces\']);

% specify where ik results are stored
ik_results_folder = ([pwd '\IKResults\']);

% Get and operate on the files
genericSetupForID = 'A07_Setup_ID.xml';
genericSetupPath = ([pwd '\IDSetup\']);



%% main inverse dynamics code for 4 DoF model

trialsForID = dir(fullfile(ik_results_folder, '*.mot'));
nTrials = size(trialsForID);

grfData = dir(fullfile(grf_data_folder, '*.mot'));

nPrefTrials = 0;




% Loop through the trials
for trial= 1:nTrials;
    
    % Get the name of the file for this trial
    motionFile = trialsForID(trial).name;
%     motFile = trialsForID{trial};
    motData = Storage([ik_results_folder motionFile]);
    
    % get first and last times
    initial_time = motData.getFirstTime();
    final_time = motData.getLastTime();
    
    
    % Create name of trial from .mot file name
    nametemp = regexprep(motionFile,'.mot','');
    C = strsplit(nametemp,'_');
    
    % count trials that are for the 4 DoF socket model
    if(strcmp(C{4},'LockState5'));
        
        % identify original trial and model, assign appropriate force file
        % and model
        for i = 1:size(PREF,2);
            if(strcmp(C{3},PREF(i)));
                TR=i; 
                grfFile = ([grf_data_folder grfData(i).name]);
            end
        end
        
        modelFile = models{5};
        
%         if(strcmp(C{4},'SR1'));
%             SR=1;
%             modelFile = model1;
%         end
%         if(strcmp(C{4},'SR2'));
%             SR=2;
%             modelFile = model2;
%         end
%         if(strcmp(C{4},'SR3'));
%             SR=3;
%             modelFile = model3;
%         end
        
        model = Model([model_folder modelFile]);
        
        % get coordinates and set defaults that may be altered from scaling
        coords = model.getCoordinateSet();
        coords.get('mtp_angle_r').setDefaultLocked(false);
        coords.get('foot_flex').setDefaultLocked(false);
        % set socket lock conditions
        coords.get('socket_tx').setDefaultLocked(true);
        coords.get('socket_ty').setDefaultLocked(false);
        coords.get('socket_tz').setDefaultLocked(true);
        coords.get('socket_flexion').setDefaultLocked(false);
        coords.get('socket_adduction').setDefaultLocked(false);
        coords.get('socket_rotation').setDefaultLocked(false);
        
        

        model.initSystem();
        
        % create external loads object and modify
        extLoads = ExternalLoads(model,([genericSetupPath 'ExtForces.xml']));
        % Set the grf filename
        extLoads.setDataFileName(grfFile);
        extLoads.setExternalLoadsModelKinematicsFileName([ik_results_folder motionFile]);
        extLoads.print([genericSetupPath 'temp.xml']);
        
        % set up tool and work on files
        idTool = InverseDynamicsTool([genericSetupPath genericSetupForID]);
        idTool.setModel(model);
        idTool.setStartTime(initial_time);
        idTool.setEndTime(final_time);
        
        idTool.setCoordinatesFileName([ik_results_folder motionFile])
        idTool.setExternalLoadsFileName([genericSetupPath 'temp.xml'])
        idTool.setLowpassCutoffFrequency(6)
        name = ([C{1} '_' C{2} '_' C{3} '_' C{4} '_id.sto']);
        idTool.setOutputGenForceFileName(name)
        idTool.setResultsDir([pwd '\IDResults\'])
        
        fprintf(['Calculating inverse dynamics for trial ' num2str(trial) ' of ' num2str(nTrials(1)) '\n']);
        
%         idTool.getCoordinatesFileName()
%         extLoads.getDataFileName()
        
        idTool.run();
    end
    
    % count trials that are for the Rigid socket model
    if(strcmp(C{4},'LockState1'));
        
        % identify original trial and model, assign appropriate force file
        % and model
        for i = 1:size(PREF,2);
            if(strcmp(C{3},PREF(i)));
                TR=i; 
                grfFile = ([grf_data_folder grfData(i).name]);
            end
        end
        
        modelFile = models{1};
        
%         if(strcmp(C{4},'SR1'));
%             SR=1;
%             modelFile = model1;
%         end
%         if(strcmp(C{4},'SR2'));
%             SR=2;
%             modelFile = model2;
%         end
%         if(strcmp(C{4},'SR3'));
%             SR=3;
%             modelFile = model3;
%         end
        
        model = Model([model_folder modelFile]);
        
        % get coordinates and set defaults that may be altered from scaling
        coords = model.getCoordinateSet();
        coords.get('mtp_angle_r').setDefaultLocked(false);
        coords.get('foot_flex').setDefaultLocked(false);
        % set socket lock conditions
        coords.get('socket_tx').setDefaultLocked(true);
        coords.get('socket_ty').setDefaultLocked(true);
        coords.get('socket_tz').setDefaultLocked(true);
        coords.get('socket_flexion').setDefaultLocked(true);
        coords.get('socket_adduction').setDefaultLocked(true);
        coords.get('socket_rotation').setDefaultLocked(true);
        
        
        model.initSystem();
        
        % create external loads object and modify
        extLoads = ExternalLoads(model,([genericSetupPath 'ExtForces.xml']));
        % Set the grf filename
        extLoads.setDataFileName(grfFile);
        extLoads.setExternalLoadsModelKinematicsFileName([ik_results_folder motionFile]);
        extLoads.print([genericSetupPath 'temp.xml']);
        
        % set up tool and work on files
        idTool = InverseDynamicsTool([genericSetupPath genericSetupForID]);
        idTool.setModel(model);
        idTool.setStartTime(initial_time);
        idTool.setEndTime(final_time);
        
        idTool.setCoordinatesFileName([ik_results_folder motionFile])
        idTool.setExternalLoadsFileName([genericSetupPath 'temp.xml'])
        idTool.setLowpassCutoffFrequency(6)
        name = ([C{1} '_' C{2} '_' C{3} '_' C{4} '_id.sto']);
        idTool.setOutputGenForceFileName(name)
        idTool.setResultsDir([pwd '\IDResults\'])
        
        fprintf(['Calculating inverse dynamics for trial ' num2str(trial) ' of ' num2str(nTrials(1)) '\n']);
        
%         idTool.getCoordinatesFileName()
%         extLoads.getDataFileName()
        
        idTool.run();
    end
end

fprintf('ID processing complete!');

% clear all



