%-------------------------------------------------------------------------% 
% Multisubject_IK_ID_Process_Results.m
% 
% This file processes data generated from IK, specifically looking at error
% sensitivity to changes in the model. 

% before running: 
% 1)Ensure the following folders are in the working
% directory:
%     IKErrors        Where marker errors are written for each trial
%     IKResults       Where kinematic results are  written for each trial
%     IKSetup         Contains generic setup file and trial specific setup 
%                     files are written
%     MarkerData      Contains marker trajectory files for each trial
%
% 2) Ensure 'FAST', 'PREF', and 'SLOW' arrays contain the names
% corresponding to their specific experimental data
%
% File names used for IK must be in format of
% SUBJECT_SPEED_TRIAL_SOCKETREF_LOCKSTATE_DATA.mot

% Written by Andrew LaPre, Mark Price 7/2017
% Last modified 7/11/2017
%
%-------------------------------------------------------------------------%

clear
clc
close all

%% Script options

% list subject labels manually in the corresponding array as they 
% appear in the file name

% subjLabels = {'A03', 'A07'};
% subjLabels = {'A07'};
subjLabels = {'A01', 'A03', 'A07'};
subjLabelsPlots = {'Subject 1', 'Subject 2', 'Subject 3'};

numSubj = size(subjLabels,2);

% specify if IK is on full body(1) or just the effected thigh and socket(2)
IK_tasks = 1;

% specify socket lockstates to compare: Choose 5 to compare the first 5,
% choose 6 to compare error for up to 6 DoF socket model
SComp = 6;

% set flags for trials to evaluate
% currently only works for PREF
FAST_flag = 0;
PREF_flag = 1;
SLOW_flag = 0;

% choose speed
spFirst = 2;
spLast = 2;

%% Load in formatted subject data

for i = 1:numSubj
    subjFile = [subjLabels{i} '_processed_kinematics.mat'];
    load(subjFile);
    fullNormData{i} = normData;
    fullErrData{i} = errData;
    fullTags{i} = tags;
    
    subjFile = [subjLabels{i} '_processed_kinetics.mat'];
    load(subjFile);
    fullNormIDData{i} = normData;
    fullIDTags{i} = tags;
end

%% Error comparison setup
fprintf('parsing error statistics\n')
if FAST_flag == 1
    speed=1;
    errFast = zeros(6,1);
    for lockstate = 1:6;
        for subj = 1:3
            errFast(lockstate,subj) = fullErrData{subj}{speed,4}{lockstate}(1,3);
        end
    end
end

if PREF_flag == 1
    speed=2;
    errPref = zeros(6,numSubj);
    errStd = zeros(6,numSubj);
    for lockstate = 1:6;
        for subj = 1:numSubj
            errPref(lockstate,subj) = fullErrData{subj}{speed,4}{lockstate}(1,3);
            errStd(lockstate,subj) = fullErrData{subj}{speed,5}{lockstate}(2,3);
        end
    end
end

if SLOW_flag == 1;
    speed=3;
    errSlow = zeros(6,1);
    for lockstate = 1:6;
        for subj = 1:3
            errSlow(lockstate,subj) = fullErrData{subj}{speed,4}{lockstate}(1,3);
        end
    end
end

fprintf('complete\n')
clear lockstate speed model

%% PREF SPEED assemble table for max marker error per subj per socket condition

errMax = zeros(6,numSubj);
speed = 2;

for subj = 1:numSubj
    for lockstate = 1:6
        for trial = 1:3
            tempMax(lockstate,trial) = fullErrData{subj}{speed,3}{lockstate,trial}(3,4);
        end
    end
    errMax(:,:,subj) = tempMax;
end

errMeanMax = mean(errMax,2);
errMeanMax = reshape(errMeanMax,6,3);
errStdMax = std(errMax,0,2);
errStdMax = reshape(errStdMax,6,3);

%% PREF SPEED Plot Marker error RMS comparing socket reference and lock state for each speed
if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    % Create figure
figure1 = figure;
 
% Create axes
if SComp==5;axes1 = axes('Parent',figure1,...
'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF'},...
'XTick',[1 2 3 4 5],...
'FontSize',14);
end
if SComp==6; axes1 = axes('Parent',figure1,...
'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF', '6-DOF'},...
'XTick',[1 2 3 4 5 6],...
'FontSize',12); 
end
if IK_tasks == 1; ylim(axes1,[0.000 0.012]); end
if SComp==5;xlim(axes1,[0.5 5.5]);end
if SComp==6;xlim(axes1,[0.5 6.5]);end

box(axes1,'on');
hold(axes1,'all');
 
% Create multiple lines using matrix input to bar
bar1 = bar(errPref,'Parent',axes1);
for i = 1:numSubj
    set(bar1(i),'DisplayName',subjLabelsPlots{i});
end
set(bar1,'BarWidth',1);    % The bars will now touch each other
set(bar1(1),'FaceColor',[.5 .5 1]);

numgroups = size(errPref, 1); 
numbars = size(errPref, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errPref(:,i), errStd(:,i), 'k', 'linestyle', 'none');
 end

% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
% if IK_tasks==2;daspect([250 1 1]);end
%  
% Create title
if IK_tasks ==1;
    title('IK Marker Error RMS','FontSize',14);
end
if IK_tasks ==2;
    title('Pref. Speed Marker Error RMS (socket/thigh tracking)','FontSize',14);
end
 
% Create legend
legend1 = legend(axes1,bar1);

end

%% PREF SPEED Plot Normalized Marker error RMS comparing socket reference and lock state 
if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    % Create figure
figure2 = figure;
 
% normalize the data
normErrPref = zeros(size(errPref));
for ls=1:size(errPref,1)
   for mod = 1:size(errPref,2) 
       normErrPref(ls,mod) = errPref(ls,mod)/errPref(1,mod);
       normErrStd(ls,mod) = errStd(ls,mod)/errPref(1,mod);
   end
end

% Create axes
if SComp==5;axes1 = axes('Parent',figure2,...
'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF'},...
'XTick',[1 2 3 4 5],...
'FontSize',14);
end
if SComp==6; axes1 = axes('Parent',figure2,...
'XTickLabel',{'Rigid','Flex','Pist','Flex/Pist','4-DOF', '6-DOF'},...
'XTick',[1 2 3 4 5 6],...
'FontSize',12); 
end
if IK_tasks == 1; ylim(axes1,[0 1.05]); end
if SComp==5;xlim(axes1,[0.5 5.5]);end
if SComp==6;xlim(axes1,[0.5 6.5]);end
box(axes1,'on');
hold(axes1,'all');
 
% Create multiple lines using matrix input to bar
bar1 = bar(normErrPref,'Parent',axes1);
for i = 1:numSubj
    set(bar1(i),'DisplayName',subjLabelsPlots{i});
end
set(bar1,'BarWidth',1);    % The bars will now touch each other
set(bar1(1),'FaceColor',[.5 .5 1]);

numgroups = size(errPref, 1); 
numbars = size(errPref, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, normErrPref(:,i), normErrStd(:,i), 'k', 'linestyle', 'none');
 end
 
% Create ylabel
ylabel('Normalized Avg. RMS','FontSize',13);
% if IK_tasks==1;daspect([8 1 1]);end
% if IK_tasks==2;daspect([250 1 1]);end
 
% Create title
if IK_tasks ==1;
    title('Normalized IK Marker Error RMS','FontSize',14);
end
if IK_tasks ==2;
    title('Pref. Speed Marker Error (socket/thigh tracking)','FontSize',14);
end
 
% Create legend
legend1 = legend(axes1,bar1);

end

%% PREF SPEED Plot Marker error MAX comparing socket reference and lock state for each speed
if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    % Create figure
figure1 = figure;
 
% Create axes
if SComp==5;axes1 = axes('Parent',figure1,...
'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF'},...
'XTick',[1 2 3 4 5],...
'FontSize',14);
end
if SComp==6; axes1 = axes('Parent',figure1,...
'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF', '6-DOF'},...
'XTick',[1 2 3 4 5 6],...
'FontSize',12); 
end
if IK_tasks == 1; ylim(axes1,[0.000 0.050]); end
if SComp==5;xlim(axes1,[0.5 5.5]);end
if SComp==6;xlim(axes1,[0.5 6.5]);end

box(axes1,'on');
hold(axes1,'all');
 
% Create multiple lines using matrix input to bar
bar1 = bar(errMeanMax,'Parent',axes1);
for i = 1:numSubj
    set(bar1(i),'DisplayName',subjLabelsPlots{i});
end
set(bar1,'BarWidth',1);    % The bars will now touch each other
set(bar1(1),'FaceColor',[.5 .5 1]);

numgroups = size(errMeanMax, 1); 
numbars = size(errMeanMax, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));
for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errMeanMax(:,i), errStdMax(:,i), 'k', 'linestyle', 'none');
 end

% Create ylabel
ylabel('Max error (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
% if IK_tasks==2;daspect([250 1 1]);end
%  
% Create title
if IK_tasks ==1;
    title('IK Marker Error Max','FontSize',14);
end
if IK_tasks ==2;
    title('Pref. Speed Marker Error Max (socket/thigh tracking)','FontSize',14);
end
 
% Create legend
legend1 = legend(axes1,bar1);

end

%% PREF SPEED Plot Coordinates for each model with 4 DoF socket

if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    figure('OuterPosition',[20 20 850 850])
    
    for subj = 1:numSubj
        
        lockstate = 5;

        if lockstate ==1;LTag = 'Rigid';end
        if lockstate ==2;LTag = 'Flexion';end
        if lockstate ==3;LTag = 'Pistoning';end
        if lockstate ==4;LTag = 'Flex/Pist';end
        if lockstate ==5;LTag = '4-DOF';end

        for plots = 1:4

            if plots == 1;tag = 'socket_ty';end
            if plots == 2;tag = 'socket_flexion';end
            if plots == 3;tag = 'socket_rotation';end
            if plots == 4;tag = 'socket_adduction';end


            % tag = foot_flex; % change to coordinate you want to plot

            % find state 
            for t = 1:size(fullTags{subj},2)
                if strcmp(tag, fullTags{subj}(t))
                    state = t;
                end
            end

            clear t

            stance = 0:1:100;

            speed = 2;
            
            absPlotNum = subj + ((plots-1) * 3);



            % Plot coordinate averages for speed and model

            subplot(4,3,absPlotNum)
            color = 'k';
            dataTemp = fullNormData{subj}{speed,3}{lockstate,1}(:,state);
            SDTemp = fullNormData{subj}{speed,3}{lockstate,2}(:,state);
            hold on
            if plots ==1;boundedline(stance,dataTemp.*1000,SDTemp.*1000,color,'alpha');end
            if plots ==2;boundedline(stance,-dataTemp,SDTemp,color,'alpha');end
            if plots >2;boundedline(stance,dataTemp,SDTemp,color,'alpha');end
            if plots ==1 && subj == 1; ylabel(['Pistoning',sprintf('\n'),'(mm)'],'FontSize',12);end
            if plots ==2 && subj == 1; ylabel(['Flexion/',sprintf('\n'),'Extension (deg)'],'FontSize',12);end
            if plots ==3 && subj == 1; ylabel(['Axial',sprintf('\n'),'Rotation (deg)'],'FontSize',12);end
            if plots ==4 && subj == 1; ylabel(['Abduction/',sprintf('\n'),'Adduction (deg)'],'FontSize',12);end
            box off

            if plots==1&&IK_tasks==1;title([subjLabelsPlots{subj}],'FontSize',14);end
            if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Motion (socket/thigh tracking)'],'FontSize',14);end

            clear dataTemp



            % Create legend
            if plots ==1;
                ylim([-40 50])
    %             legend('SR-0','SR-25','SR-50');
    %             set(legend,'Orientation','horizontal',...
    %             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
            end
            if plots ==2;
                ylim([-15 15])
            end
            if plots ==3;
                ylim([-30 30])
            end
            if plots ==4;
                ylim([-15 10])
%                 xlabel('% Gait')
            end
            
            if absPlotNum > 9 && absPlotNum < 13;
                xlabel('% Gait')
            end
        end
    box off
    end

    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
end    
%% Hip/knee/ankle kinematics both sides

figure('OuterPosition',[20 20 850 850])

for subj = 1:numSubj


    for plots = 1:3

        if plots == 1;p_tag = 'foot_flex';i_tag = 'ankle_angle_r';end
        if plots == 2;p_tag = 'knee_angle_l';i_tag = 'knee_angle_r';end
        if plots == 3;p_tag = 'hip_angle_l';i_tag = 'hip_angle_r';end


        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(fullTags{subj},2)
            if strcmp(p_tag, fullTags{subj}(t))
                p_state = t;
            end
            if strcmp(i_tag, fullTags{subj}(t))
                i_state = t;
            end
        end

        clear t

        stance = 0:1:100;

        speed = 2;
        
        absPlotNum = subj + ((plots-1) * 3);

        subplot(3,3,absPlotNum)
            
            % Plot coordinate averages for speed and model
        if plots == 2    
            dataProsRigid = -fullNormData{subj}{speed,3}{1,1}(:,p_state);
            dataIntactRigid = -fullNormData{subj}{speed,3}{1,1}(:,i_state);
            dataPros4dof = -fullNormData{subj}{speed,3}{5,1}(:,p_state);
            dataIntact4dof = -fullNormData{subj}{speed,3}{5,1}(:,i_state);
        
        else
            dataProsRigid = fullNormData{subj}{speed,3}{1,1}(:,p_state);
            dataIntactRigid = fullNormData{subj}{speed,3}{1,1}(:,i_state);
            dataPros4dof = fullNormData{subj}{speed,3}{5,1}(:,p_state);
            dataIntact4dof = fullNormData{subj}{speed,3}{5,1}(:,i_state);
        end
%                 SDTemp = fullNormData{subj}{speed,3}{lockstate,2}(:,state);
        hold on
        plot(stance,dataProsRigid,'LineWidth',2,'Color',[0 0 0],'LineStyle','--')
        plot(stance,dataIntactRigid,'LineWidth',2,'Color',[0.5, 0.5, 0.5],'LineStyle','--')
        plot(stance,dataPros4dof,'LineWidth',2,'Color',[0 0 0])
        plot(stance,dataIntact4dof,'LineWidth',2,'Color',[0.5, 0.5, 0.5])
%         ylabel('Angle (deg)', 'FontSize',14)
        if plots == 1; title([subjLabelsPlots{subj}], 'FontSize',14);end
%         if plots == 2; title(['Subj ' num2str(subj) ' Knee'], 'FontSize',14);end
%         if plots == 3; title(['Subj ' num2str(subj) ' Hip'], 'FontSize',14);end
        
        if plots ==1 && subj == 1; ylabel(['Ankle/Pros Foot',sprintf('\n'),'Angle (deg)'],'FontSize',12);end
        if plots ==2 && subj == 1; ylabel(['Knee Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        if plots ==3 && subj == 1; ylabel(['Hip Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        
        if plots ==1;
            ylim([-40 20])
        end       
        if plots ==2;
            ylim([-50 100])
        end
        if plots ==3;
            ylim([-100 50])
        end

        
        % Create legend
        if absPlotNum ==9;
            legend('ESR Rigid','Intact Rigid','ESR 4-DOF','Intact 4-DOF');
            set(legend,'Orientation','horizontal',...
            'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        end
        if absPlotNum > 6 && absPlotNum < 10;
            xlabel('% Gait')
        end
        
    end
    box off
 end

    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
%% PREF SPEED Plot socket forces for each model with 4 DoF socket

if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    figure('OuterPosition',[20 20 850 850])
    
    for subj = 1:numSubj
        
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


            % tag = foot_flex; % change to coordinate you want to plot

            % find state 
            for t = 1:size(fullIDTags{subj},2)
                if strcmp(tag, fullIDTags{subj}(t))
                    state = t;
                end
            end

            clear t

            stance = 0:0.5:100;

            speed = 2;
            
            absPlotNum = subj + ((plots-1) * 3);



            % Plot coordinate averages for speed and model

            subplot(4,3,absPlotNum)
            color = 'k';
            dataTemp = fullNormIDData{subj}{speed,3}{lockstate,1}(:,state);
            SDTemp = fullNormIDData{subj}{speed,3}{lockstate,2}(:,state);
            hold on
            boundedline(stance,dataTemp,SDTemp,color,'alpha');

            if plots ==1 && subj == 1; 
                ylabel(['Pistoning Force',sprintf('\n'),'(N)'],'FontSize',12);
                ylim([-100 1200]);
            end
            if plots ==2 && subj == 1; 
                ylabel(['Flexion/Extension',sprintf('\n'),'Moment (N-m)'],'FontSize',12);
                ylim([-40 100])
            end
            if plots ==3 && subj == 1; 
                ylabel(['Axial Rotation',sprintf('\n'),'Moment (N-m)'],'FontSize',12);
                ylim([-20 20])
            end
            if plots ==4 && subj == 1; 
                ylabel(['Abduction/Adduction',sprintf('\n'),'Moment (N-m)'],'FontSize',12);
                ylim([-20 20])
            end
            
            box off

            if plots==1;title([subjLabelsPlots{subj}],'FontSize',14);end

            clear dataTemp



            % Create legend
            if plots ==1;
                ylim([-100 1200]);
    %             legend('SR-0','SR-25','SR-50');
    %             set(legend,'Orientation','horizontal',...
    %             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
            end
            if plots ==2;
                ylim([-40 100])
            end
            if plots ==3;
                ylim([-20 20])
            end
            if plots ==4;
                ylim([-20 20])
            end
            
            if absPlotNum > 9 && absPlotNum < 13;
                xlabel('% Gait')
            end
        end
    box off
    end

    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
end    
%% Hip/knee/ankle kinetics both sides

figure('OuterPosition',[20 20 850 850])

for subj = 1:numSubj


    for plots = 1:3

        if plots == 1;p_tag = 'foot_flex_moment';i_tag = 'ankle_angle_r_moment';end
        if plots == 2;p_tag = 'knee_angle_l_moment';i_tag = 'knee_angle_r_moment';end
        if plots == 3;p_tag = 'hip_angle_l_moment';i_tag = 'hip_angle_r_moment';end


        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(fullIDTags{subj},2)
            if strcmp(p_tag, fullIDTags{subj}(t))
                p_state = t;
            end
            if strcmp(i_tag, fullIDTags{subj}(t))
                i_state = t;
            end
        end

        clear t

        stance = 0:0.5:100;

        speed = 2;
        
        absPlotNum = subj + ((plots-1) * 3);

        subplot(3,3,absPlotNum)
            
            % Plot coordinate averages for speed and model
%         if plots == 2    
%             dataProsRigid = -fullNormIDData{subj}{speed,3}{1,1}(:,p_state);
%             dataIntactRigid = -fullNormIDData{subj}{speed,3}{1,1}(:,i_state);
%             dataPros4dof = -fullNormIDData{subj}{speed,3}{5,1}(:,p_state);
%             dataIntact4dof = -fullNormIDData{subj}{speed,3}{5,1}(:,i_state);
%         
%         else
            dataProsRigid = fullNormIDData{subj}{speed,3}{1,1}(:,p_state);
            dataIntactRigid = fullNormIDData{subj}{speed,3}{1,1}(:,i_state);
            dataPros4dof = fullNormIDData{subj}{speed,3}{5,1}(:,p_state);
            dataIntact4dof = fullNormIDData{subj}{speed,3}{5,1}(:,i_state);
%         end
%                 SDTemp = fullNormData{subj}{speed,3}{lockstate,2}(:,state);
        hold on
        plot(stance,dataProsRigid,'LineWidth',2,'Color',[0 0 0],'LineStyle','--')
        plot(stance,dataIntactRigid,'LineWidth',2,'Color',[0.5, 0.5, 0.5],'LineStyle','--')
        plot(stance,dataPros4dof,'LineWidth',2,'Color',[0 0 0])
        plot(stance,dataIntact4dof,'LineWidth',2,'Color',[0.5, 0.5, 0.5])
%         ylabel('Angle (deg)', 'FontSize',14)
        if plots == 1; title([subjLabelsPlots{subj}], 'FontSize',14);end
%         if plots == 2; title(['Subj ' num2str(subj) ' Knee'], 'FontSize',14);end
%         if plots == 3; title(['Subj ' num2str(subj) ' Hip'], 'FontSize',14);end
        
        if plots ==1 && subj == 1; ylabel(['Ankle/Pros Foot',sprintf('\n'),'Moment (N-m)'],'FontSize',12);end
        if plots ==2 && subj == 1; ylabel(['Knee Moment',sprintf('\n'),'(N-m)'],'FontSize',12);end
        if plots ==3 && subj == 1; ylabel(['Hip Moment',sprintf('\n'),'(N-m)'],'FontSize',12);end
        
%         if plots ==1;
%             ylim([-40 20])
%         end       
%         if plots ==2;
%             ylim([-50 100])
%         end
%         if plots ==3;
%             ylim([-100 50])
%         end

        
        % Create legend
        if absPlotNum ==9;
            legend('ESR Rigid','Intact Rigid','ESR 4-DOF','Intact 4-DOF');
            set(legend,'Orientation','horizontal',...
            'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        end
        if absPlotNum > 6 && absPlotNum < 10;
            xlabel('% Gait')
        end
        
    end
    box off
 end

    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR

