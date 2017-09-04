% This file processes data generated from IK, specifically looking at error
% sensitivity to changes in the model. 

% before running: 
%
% 1)Ensure the following folders are in the working
% directory:
%     IKErrors        Where marker errors are written for each trial
%     IKResults       Where kinematic results are  written for each trial
%     IKSetup         Contains generic setup file and trial specific setup 
%                     files are written
%     IDResults       Contains inverse dynamics general forces results
%
% 2) Ensure 'FAST', 'PREF', and 'SLOW' arrays contain the names
% corresponding to their specific experimental data
%
% File names used for IK must be in format of
% SUBJECT_SPEED_TRIAL_SOCKETREF_LOCKSTATE_DATA.sto

% Written by Andrew LaPre 3/2016
% Last modified 3/1/2016
%
%-------------------------------------------------------------------------%

clear all
% close all 
clc

%% script options

% list trial number labels manually in the corresponding array as they 
% appear in the file name
% don't delete an array if you don't want the data, it will be detected
FAST = {'T0021', 'T0022', 'T0024'};
PREF = {'0002', '0003', '0005'};
SLOW = {'T0026', 'T0027', 'T0029'};

mass = 73.1637;

% set flags for trials to evaluate
% currently only works for PREF
FAST_flag = 0;
PREF_flag = 1;
SLOW_flag = 0;

% specify if IK is on full body(1) or just the effected thigh and socket(2)
IK_tasks = 1;
% specify subject speed for analysis
spFirst = 2;
spLast = 2;

%% load data
fprintf('loading data\n');

% point to folders where data is located
id_data_folder = ([pwd '\IDResults']);

IDtrials = dir(fullfile(id_data_folder, '*.sto'));

nTrials = size(IDtrials);

normData = cell(3,3);
normData{1,1} = 'fast';
normData{1,2} = cell(6,3); % normalized trial data
normData{1,3} = cell(6,2); % trial avg and stdev
normData{2,1} = 'pref';
normData{2,2} = cell(6,3); % normalized trial data
normData{2,3} = cell(6,2); % trial avg and stdev
normData{3,1} = 'slow';
normData{3,2} = cell(6,3); % normalized trial data
normData{3,3} = cell(6,2); % trial avg and stdev

%% separate trials
fprintf('separating trials, normalizing to percent stance, storing new data\n')
for trial = 1:nTrials

    % Get the name of the file for this trial
    GenFFile = IDtrials(trial).name;
    
    % Create name of trial from .mot file name
    fileName = regexprep(GenFFile,'.sto','');
    fullpath = ([id_data_folder '\' GenFFile]);
    
    % import data from file
    delimiterIn = '\t';
    headerlinesIn = 7;
    data = importdata(fullpath,delimiterIn,headerlinesIn);
    
    % get trial headers, assuming they are all the same
    % if not, need to sort data by tags, then analyze
    tags = data.colheaders;
    
    % decompose file name
    C = strsplit(fileName,'_');
    
    % label speed and trial
    for i = 1:size(FAST,2)
        if(strcmp(C{3},FAST{i}));Sp = 1; Tr = i;end
    end
    for i = 1:size(PREF,2)
        if(strcmp(C{3},PREF{i}));Sp = 2; Tr = i;end
    end
    for i = 1:size(SLOW,2)
        if(strcmp(C{3},SLOW{i}));Sp = 3; Tr = i;end
    end
    
%     % label socket reference
%     if(strcmp(C{4},'SR1'));SR = 1;end
%     if(strcmp(C{4},'SR2'));SR = 2;end
%     if(strcmp(C{4},'SR3'));SR = 3;end
    
    % label socket lock state
    if(strcmp(C{4},'LockState1'));LS = 1;end
    if(strcmp(C{4},'LockState2'));LS = 2;end
    if(strcmp(C{4},'LockState3'));LS = 3;end    
    if(strcmp(C{4},'LockState4'));LS = 4;end
    if(strcmp(C{4},'LockState5'));LS = 5;end  
    if(strcmp(C{4},'LockState6'));LS = 6;end    
    
    % create empty matrix
    normData{Sp,2}{LS,Tr} = zeros(201,size(data.data,2)); 
    
    % normalize data to gait percentage
    for row = 1:size(data.data,2)
        % examine individual rows for all trials
%         if row == 24&&LS==5&&SR==3
%             figure
%             plot(data.data(:,row))
%         end
        temp = data.data(:,row);
%         temp = dynWindFilt(10,temp);
        P = 201;
        Q = size(temp,1);
        x = resample(temp,P,Q);
%         x = norm2stance(temp);
        
        % store in appropriate cell
        normData{Sp,2}{LS,Tr}(:,row) = x;
    end
    
    clear temp P Q x  Avg SD temp temp2 peak row
    
    fprintf(['working on trial ' num2str(trial) '\n'])
end

clear trial nTrials LS GenFFile fileName data delimiterIn ...
    FAST PREF SLOW Tr SR Sp i fullerrpath fullkinpath headerlinesIn...
    id_data_folder IDtrials 

%% calculate and store statistics
fprintf('calculating inverse dynamics statistics\n')

for speed = spFirst:spLast
    for lockstate = 1:6
%         for model = 1:3
            for var = 1:size(normData{speed,2}{lockstate,1},2)
                for samp = 1:201
                    h = zeros(size(normData{speed,2},2),1);
                    nTrials = size(normData{speed,2},2);
                    for trial = 1:nTrials 
                        h(trial) = normData{speed,2}{lockstate,trial}(samp,var);
                    end 
                    normData{speed,3}{lockstate,1}(samp,var) = mean(h);   % average
                    normData{speed,3}{lockstate,2}(samp,var) = std(h);    % standard deviation
                    clear h
                end
            end
%         end
    end
end

clear speed lockstate model var samp  trial

fprintf('statistics stored\n')

%% PREF SPEED Plot Coordinates for each model with 4 DoF socket

if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
    
    figure
    
    lockstate = 5;
    
    if lockstate ==1;LTag = 'Rigid';end
    if lockstate ==2;LTag = 'Flexion';end
    if lockstate ==3;LTag = 'Pistoning';end
    if lockstate ==4;LTag = 'Flex/Pist';end
    if lockstate ==5;LTag = '4-DOF';end

    for plots = 1:4

        if plots == 1;tag = 'socket_ty_force';end
        if plots == 2;tag = 'socket_flexion_moment';end
        if plots == 3;tag = 'socket_rotation_moment';end
        if plots == 4;tag = 'socket_adduction_moment';end
        

        % find state 
        for t = 1:size(tags,2)
            if strcmp(tag, tags(t))
                state = t;
            end
        end

        clear t

        stance = 0:0.5:100;

        speed = 2;
        
%         % fake plot to control legend contents
%         if plots == 1;
%         for model = 1:3;
%             subplot(4,1,plots);
%             if model == 1; color = 'k'; end
%             if model == 2; color = 'b'; end
%             if model == 3; color = 'r'; end
%             dataTemp = normData{speed,3}{model, lockstate,1}(:,state);
%             hold on
%             plot(stance,dataTemp,color)
%                         
%             clear dataTemp
%         end
%         end

        % Plot coordinate averages for speed and model
%         for model = 1:3;
            subplot(4,1,plots);
%             if model == 1; color = 'k'; end
%             if model == 2; color = 'b'; end
%             if model == 3; color = 'r'; end
            
            color = 'r';
            dataTemp = normData{speed,3}{lockstate,1}(:,state);
            SDTemp = normData{speed,3}{lockstate,2}(:,state);
            hold on
            boundedline(stance,dataTemp,SDTemp,color,'alpha')
            if plots ==1; 
                ylabel('Pist F (N)','FontSize',10);
                ylim([-100 1200]);
            end
            if plots ==2; 
                ylabel('Flex M (N-m)','FontSize',10);
                ylim([-40 100])
            end
            if plots ==3; 
                ylabel('Rot M (N-m)','FontSize',10);
                ylim([-20 20])
            end
            if plots ==4; 
                ylabel('Add M (N-m)','FontSize',10);
                ylim([-20 20])
            end
            box on

%             ylabel(tag);
            if plots==1&&IK_tasks==1;title(['A07 ' LTag ' Socket Forces for Pref Speed Trials'],'FontSize',14);end
            if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Gen Forces (socket/thigh tracking)'],'FontSize',14);end
            
            clear dataTemp
%         end

        % Create legend
%         if plots == 1
%             legend('SR1','SR2','SR3');
%             set(legend,'Orientation','horizontal','box','on',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         end
    end
    
    clear dataTemp color lockstate 
end



% fprintf('saving results \n')
% save ID_analysis.mat
fprintf('program finished!')
