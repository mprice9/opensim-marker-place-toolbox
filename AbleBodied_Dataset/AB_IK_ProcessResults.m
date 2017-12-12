%-------------------------------------------------------------------------% 
% IKProcessing.m
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

% Written by Andrew LaPre 2/2016
% Last modified 7/11/2017
%
%-------------------------------------------------------------------------%

close all 
clear all
clc


%% script options

% Create strings for the subject name and type of prosthesis.
subjNames = {'S01','S02','S04','S05','S06','S08','S09','S10'};
numSubj = length(subjNames);

normDataSaveName = 'fullNormData10TiltLockedASIS50conv.mat';
errDataSaveName = 'fullErrData10TiltLockedASIS50conv.mat';

% Also define paths to individual subject and model folders in options structure
for i = 1:numSubj
    
    subjDir{i} = [pwd '\' subjNames{i} '\'];
    
    % specify model folder
    modelDir{i} = [subjDir{i} 'Models\AutoPlaced\'];
    
    trcDataDirPref{i} = [subjDir{i} 'MarkerData\PREF'];
    trcDataDirSlow{i} = [subjDir{i} 'MarkerData\SLOW'];
    trcDataDirFast{i} = [subjDir{i} 'MarkerData\FAST'];
    genericSetupDir{i} = [subjDir{i} 'IKSetup\'];
    
    % specify where autoplace results are stored.
%     resultsDir{i} = [subjDir{i} 'IKResults\AutoPlace\'];
%     errorDir{i} = [subjDir{i} 'IKErrors\AutoPlace'];
%     resultsDir{i} = [subjDir{i} 'IKResults\AutoPlaceNoTilt\'];
%     errorDir{i} = [subjDir{i} 'IKErrors\AutoPlaceNoTilt'];
%     resultsDir{i} = [subjDir{i} 'IKResults\AutoPlaceNoTiltReal\'];
%     errorDir{i} = [subjDir{i} 'IKErrors\AutoPlaceNoTiltReal'];    
    resultsDir{i} = [subjDir{i} 'IKResults\AutoPlace10TiltLockedASIS50Conv\'];
    errorDir{i} = [subjDir{i} 'IKErrors\AutoPlace10TiltLockedASIS50Conv'];   

    % specify where standard marker placement results are stored.
    resultsManualDir{i} = [subjDir{i} 'IKResults\StdMarkerPlaceMe\'];
    errorManualDir{i} = [subjDir{i} 'IKErrors\StdMarkerPlaceMe\'];
end

% list trial number labels manually in the corresponding array as they 
% appear in the file name
% don't delete an array if you don't want the data, it will be detected
FAST = {'T04', 'T17', 'T21', 'T22', 'T24'};
PREF = {'T06', 'T09', 'T11','T12','T17'};
SLOW = {'T03', 'T09', 'T10','T12','T14'};

% specify if IK is on full body(1) or just the effected thigh and socket(2)
IK_tasks = 1;

% specify socket lockstates to compare: Choose 5 to compare the first 5,
% choose 6 to compare error for up to 6 DoF socket model
% SComp = 6;

% set flags for trials to evaluate
% currently only works for PREF
FAST_flag = 0;
PREF_flag = 1;
SLOW_flag = 0;

% choose speed
spFirst = 1;
spLast = 3;

fullNormData = cell(numSubj,1);
fullErrData = cell(numSubj,1);

for subj = 1:numSubj

%% load data
fprintf('loading data\n');

% point to folders where data is located
ik_data_folder = resultsDir{subj};
ik_error_folder = errorDir{subj};
ik_man_data_folder = resultsManualDir{subj};
ik_man_error_folder = errorManualDir{subj};

IKtrials = dir(fullfile(ik_data_folder, '*.mot'));
IKerrors = dir(fullfile(ik_error_folder, '*.sto'));
manIKtrials = dir(fullfile(ik_man_data_folder, '*.mot'));
manIKerrors = dir(fullfile(ik_man_error_folder, '*.sto'));

nTrials = size(IKtrials);

normData = cell(3,3);
normData{1,1} = 'fast';
normData{1,2} = cell(1,3); % normalized trial data
normData{1,3} = cell(1,2); % trial avg and stdev
normData{2,1} = 'pref';
normData{2,2} = cell(1,3); % normalized trial data
normData{2,3} = cell(1,2); % trial avg and stdev
normData{3,1} = 'slow';
normData{3,2} = cell(1,3); % normalized trial data
normData{3,3} = cell(1,2); % trial avg and stdev

errData = cell(3,3);
errData{1,1} = 'fast';
errData{1,2} = cell(1,3);  % trial error
errData{1,3} = cell(1,3);  % trial error stats
errData{2,1} = 'pref';
errData{2,2} = cell(1,3);  % trial error
errData{2,3} = cell(1,3);  % trial error stats
errData{3,1} = 'slow';
errData{3,2} = cell(1,3);  % trial error
errData{3,3} = cell(1,3);  % trial error stats

fprintf('data loaded\n');

%% separate trials
fprintf('separating trials, normalizing to percent stance, storing new data\n')

fastCtr = [1 1];
prefCtr = [1 1];
slowCtr = [1 1];

for trial = 1:nTrials

    for placeType = 1:2
        
        % Get the name of the file for this trial
        if placeType == 1
            kinFile = manIKtrials(trial).name;
            errFile = manIKerrors(trial).name;            
            fullkinpath = ([ik_man_data_folder '\' kinFile]);
            fullerrpath = ([ik_man_error_folder '\' errFile]);
        end
        if placeType == 2
            kinFile = IKtrials(trial).name;
            errFile = IKerrors(trial).name;
            fullkinpath = ([ik_data_folder '\' kinFile]);
            fullerrpath = ([ik_error_folder '\' errFile]);
        end
        
        % Create name of trial from .mot file name
        kinName = regexprep(kinFile,'.mot','');

        % import data from file
        delimiterIn = '\t';
        headerlinesIn = 11;
        data = importdata(fullkinpath,delimiterIn,headerlinesIn);
        headerlinesIn = 7;
        error = importdata(fullerrpath,delimiterIn,headerlinesIn);

        % get trial headers, assuming they are all the same
        % if not, need to sort data by tags, then analyze
        tags = data.colheaders;

        % decompose file name
        C = strsplit(kinName,'_');

        % label speed and trial

        if strcmp(C{2},'P20')
            Sp = 1; 
            Tr = fastCtr(placeType);
            fastCtr(placeType) = fastCtr(placeType) + 1;
        elseif strcmp(C{2},'PSF')
            Sp = 2; 
            Tr = prefCtr(placeType);
            prefCtr(placeType) = prefCtr(placeType) + 1;
        elseif strcmp(C{2},'M20')
            Sp = 3; 
            Tr = slowCtr(placeType);
            slowCtr(placeType) = slowCtr(placeType) + 1;
        end

    %     for i = 1:size(FAST,2)
    %         if(strcmp(C{3},FAST{i}) && strcmp(C{2},'P20'));Sp = 1; Tr = i;end
    %     end
    %     for i = 1:size(PREF,2)
    %         if(strcmp(C{3},PREF{i})&& strcmp(C{2},'PSF'));Sp = 2; Tr = i;end
    %     end
    %     for i = 1:size(SLOW,2)
    %         if(strcmp(C{3},SLOW{i})&& strcmp(C{2},'M20'));Sp = 3; Tr = i;end
    %     end

        % label socket reference
    %     if(strcmp(C{4},'SR1'));SR = 1;end
    %     if(strcmp(C{4},'SR2'));SR = 2;end
    %     if(strcmp(C{4},'SR3'));SR = 3;end

    %     % label socket lock state
    %     if(strcmp(C{4},'LockState1'));LS = 1;end
    %     if(strcmp(C{4},'LockState2'));LS = 2;end
    %     if(strcmp(C{4},'LockState3'));LS = 3;end    
    %     if(strcmp(C{4},'LockState4'));LS = 4;end
    %     if(strcmp(C{4},'LockState5'));LS = 5;end  
    %     if(strcmp(C{4},'LockState6'));LS = 6;end    

        % create empty matrix
        normData{Sp,2}{placeType,Tr} = zeros(101,size(data.data,2)); 
        errData{Sp,2}{placeType,Tr} = zeros(size(error.data,1),size(error.data,2));

        % normalize data to gait percentage
        for row = 1:size(data.data,2)
            % examine individual rows for all trials
    %         if row == 24&&LS==5&&SR==3 
    %             figure
    %             plot(data.data(:,row))
    %         end
            temp = data.data(:,row);
    %         P = 101;
    %         Q = size(temp,1);
    %         x = resample(temp,P,Q);
            temp = dynWindFilt(20,temp);
            x = norm2stance(temp);

            % store in appropriate cell
            normData{Sp,2}{placeType,Tr}(:,row) = x;
        end

        % store error appropriately
        for row = 1:size(error.data,2)
            temp = error.data(:,row);
            % store in appropriate cell
            errData{Sp,2}{placeType,Tr}(:,row) = temp;
        end    

        fprintf(['working on trial ' num2str(trial) ' out of ' num2str(nTrials(1)) '\n']);

        clear temp P Q x  Avg SD temp temp2 peak row
    end
end

fprintf('complete\n')

clear trial nTrials LS kinFile kinName data delimiterIn errFile errName...
    error FAST PREF SLOW Tr SR Sp i fullerrpath fullkinpath headerlinesIn...
    ik_data_folder ik_error_folder IKerrors IKtrials 

%% calculate and store statistics
fprintf('calculating kinematic statistics\n')

for speed = spFirst:spLast
    for placetype = 1:2
%         for model = 1:3
            for var = 1:size(normData{speed,2}{1},2)
                for samp = 1:101
                    h = zeros(size(normData{speed,2},2),1);
                    nTrials = size(normData{speed,2},2);
                    for trial = 1:nTrials 
                        h(trial) = normData{speed,2}{placetype,trial}(samp,var);
                    end 
                    normData{speed,3}{placetype,1}(samp,var) = mean(h);   % average
                    normData{speed,3}{placetype,2}(samp,var) = std(h);    % standard deviation
                    clear h
                end
            end
%         end
    end
end

fullNormData{subj} = normData;

fprintf('complete\n')
clear speed model var samp  trial

%% calculate marker error averages, stdevs and maximums for each speed
fprintf('calculating marker error statistics\n')
nTrials = size(errData{2,2},2);
error = cell(nTrials,3);

for speed = spFirst:spLast
    for placetype = 1:2
%         for model = 1:3
            for var = 1:size(errData{speed,2}{1},2)
                % individual trials
                for trial = 1:nTrials
                    error{trial,speed} = errData{speed,2}{placetype,trial}(:,var);
                    A = error{trial,speed};
                    if var == 2;A = sqrt(A);end     % take sqrt to get total error
                    errData{speed,3}{placetype,trial}(1,var) = mean(A);   % average 
                    errData{speed,3}{placetype,trial}(2,var) = std(A);    % standard deviation
                    errData{speed,3}{placetype,trial}(3,var) = max(A);    % max 
                    clear A
                end
                
                % combined across trials
                A = error{1,speed};
                for n = 2:nTrials
                    A = cat(1,A,error{n,speed});
                end
                if var == 2;A = sqrt(A);end         % take sqrt to get total error
                errData{speed,4}{placetype}(1,var) = mean(A);   % average
                errData{speed,4}{placetype}(2,var) = std(A);    % standard deviation
                errData{speed,4}{placetype}(3,var) = max(A);    % max
                
                clear A

                % combined across trials using individual trial averages
                for trial = 1:nTrials
                    A(trial) = errData{speed,3}{placetype,trial}(2,var);                   
                end
                errData{speed,5}{placetype}(2,var) = std(A);    % standard deviation
                
            end
%         end
    end
end

fullErrData{subj} = errData;

fprintf('complete\n')

% clear error lockstate model n nTrials speed trial var ans

end

% %% Error comparison setup
% fprintf('parsing error statistics\n')
% 
% % err = zeros(2,3,numSubj);
% % errStd = zeros(2,3,numSubj);
%     errFast = zeros(2,numSubj);
%     errFastStd = zeros(2,numSubj);
%     errPref = zeros(2,numSubj);
%     errPrefStd = zeros(2,numSubj);
%     errSlow = zeros(2,numSubj);
%     errSlowStd = zeros(2,numSubj);
% 
% speed = [];
% if FAST_flag == 1;speed=1;end
% if PREF_flag == 1;speed=[speed 2];end
% if SLOW_flag == 1;speed=[speed 3];end
% 
% errGenPref = zeros(2,5*numSubj);
% errGenPrefMax = zeros(2,5*numSubj);
% 
% for subj = 1:numSubj
% %     for currSpeed = speed
%         for placetype = 1:2
%             errFast(placetype,subj) = fullErrData{subj}{1,4}{placetype}(1,3);
%             errFastStd(placetype,subj) = fullErrData{subj}{1,5}{placetype}(2,3);
%             errPref(placetype,subj) = fullErrData{subj}{2,4}{placetype}(1,3);
%             errPrefStd(placetype,subj) = fullErrData{subj}{2,5}{placetype}(2,3);
%             errSlow(placetype,subj) = fullErrData{subj}{3,4}{placetype}(1,3);
%             errSlowStd(placetype,subj) = fullErrData{subj}{3,5}{placetype}(2,3);
%             for trial = 1:5
%                 errGenPref(placetype,trial + (5*(subj-1))) = fullErrData{subj}{2,3}{placetype,trial}(1,3);
%                 errGenPrefMax(placetype,trial + (5*(subj-1))) = fullErrData{subj}{2,3}{placetype,trial}(3,3);
%             end
%         end
% %     end
% end
% 
% errGenPrefMean = mean(errGenPref,2);
% errGenPrefMaxMean = mean(errGenPrefMax,2);
% errGenPrefStd = std(errGenPref,2);
% errGenPrefMaxStd = std(errGenPrefMax,2);
% 
% fprintf('complete\n')
% clear speed model


% %% ALL SPEEDS Plot Marker errors comparing socket reference and lock state for each speed
% if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
%     fprintf('generating plots\n')
%     Marker_Error = figure;
%     errMin = .11;
%     errMax = .145;
% 
%     % name('Average Total Marker Error')
% 
%     % Create subplot
%     subplot1 = subplot(3,1,1,'Parent',Marker_Error,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
%     ylim(subplot1,[errMin errMax]);
%     box(subplot1,'on');
%     hold(subplot1,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errFast,'Parent',subplot1);
% 
%     % Create ylabel
%     ylabel('Fast', 'fontsize', 14);
%     % Create title
%     title('Average Total Marker Error','fontsize',16);
% 
%     % Create subplot
%     subplot2 = subplot(3,1,2,'Parent',Marker_Error,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
%     ylim(subplot2,[errMin errMax]);
%     box(subplot2,'on');
%     hold(subplot2,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errPref,'Parent',subplot2);
% 
%     % Create ylabel
%     ylabel('Preferred', 'fontsize', 14);
% 
%     % Create subplot
%     subplot3 = subplot(3,1,3,'Parent',Marker_Error,...
%         'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},...
%         'XTick',[1 2 3 4 5]);
%     ylim(subplot3,[errMin errMax]);
%     box(subplot3,'on');
%     hold(subplot3,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errSlow,'Parent',subplot3);
% 
%     % Create ylabel
%     ylabel('Slow', 'fontsize', 14);
% 
%     % Create legend
%     legend('SR1','SR2','SR3');
% 
%     legend1 = legend(subplot3,'show');
%     set(legend1,'Orientation','horizontal',...
%         'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%     
% end
% 
% %% ALL SPEEDS Plot Marker errors comparing lock state and speed for each socket reference 
% if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
%     Marker_ErrorSR = figure;
%     errMin = .11;
%     errMax = .145;
% 
%     % name('Average Total Marker Error')
% 
%     % Create subplot
%     subplot1 = subplot(3,1,1,'Parent',Marker_ErrorSR,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
%     ylim(subplot1,[errMin errMax]);
%     box(subplot1,'on');
%     hold(subplot1,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errSR1,'Parent',subplot1);
% 
%     % Create ylabel
%     ylabel('SR1', 'fontsize', 14);
%     % Create title
%     title('Average Total Marker Error','fontsize',16);
% 
%     % Create subplot
%     subplot2 = subplot(3,1,2,'Parent',Marker_ErrorSR,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
%     ylim(subplot2,[errMin errMax]);
%     box(subplot2,'on');
%     hold(subplot2,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errSR2,'Parent',subplot2);
% 
%     % Create ylabel
%     ylabel('SR2', 'fontsize', 14);
% 
%     % Create subplot
%     subplot3 = subplot(3,1,3,'Parent',Marker_ErrorSR,...
%         'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},...
%         'XTick',[1 2 3 4 5]);
%     ylim(subplot3,[errMin errMax]);
%     box(subplot3,'on');
%     hold(subplot3,'all');
% 
%     % Create multiple lines using matrix input to bar
%     bar(errSR3,'Parent',subplot3);
% 
%     % Create ylabel
%     ylabel('SR3', 'fontsize', 14);
% 
%     % Create legend
%     legend('Fast','Preferred','Slow');
% 
%     legend1 = legend(subplot3,'show');
%     set(legend1,'Orientation','horizontal',...
%         'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
% 
%     clear errMax errMin
%     
% end
% 
% %% ALL SPEEDS Plot model coordinates comparing lockstates and models for each speed
% % set tag = to state you want to plot
% if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
%     for plots = 1:2
% 
%         if plots == 1;tag = 'socket_ty';end
%         if plots == 2;tag = 'socket_flexion';end
% 
%         % tag = foot_flex; % change to coordinate you want to plot
% 
%         % find state 
%         for t = 1:size(tags,2)
%             if strcmp(tag, tags(t))
%                 state = t;
%             end
%         end
% 
%     clear t
% 
%     stance = 1:1:100;
% 
%     for speed = 1:3;
% 
%         figure;
% 
%         % Plot coordinate averages for speed and model
%         for model = 1:3;
%         subplot(3,2,model*2-1);
%             for lockstate = 1:5;
%                 dataTemp = normData{speed,3}{model, lockstate,1}(:,state);
%                 if lockstate == 1; color = 'k'; end
%                 if lockstate == 2; color = 'b'; end
%                 if lockstate == 3; color = 'r'; end
%                 if lockstate == 4; color = 'c'; end
%                 if lockstate == 5; color = 'm'; end
%                 hold on
%                 plot(stance,dataTemp,color)
%             end
%         if model==1;ylabel('SR1');end
%         if model==2;ylabel('SR2');end
%         if model==3;ylabel('SR3');end
%         stringTemp = ['Avg ',tag,' for Fast Trials'];
%         if speed==1;stringTemp = ['Avg ',tag,' for Fast Trials'];end
%         if speed==2;stringTemp = ['Avg ',tag,' for Pref Trials'];end
%         if speed==3;stringTemp = ['Avg ',tag,' for Slow Trials'];end
%         if model==1;title(stringTemp);end
%         % plot standard deviation
%         subplot(3,2,model*2);
%             for lockstate = 1:5;
%                 dataTemp = normData{speed,3}{model, lockstate,2}(:,state);
%                 if lockstate == 1; color = 'k'; end
%                 if lockstate == 2; color = 'b'; end
%                 if lockstate == 3; color = 'r'; end
%                 if lockstate == 4; color = 'c'; end
%                 if lockstate == 5; color = 'm'; end
%                 hold on
%                 plot(stance,dataTemp,color)
%             end
%         if model==1;title('  Standard Deviation'); end
% 
% 
% 
%         % Create legend
%         legend('All Locked','Flexion UL','Pistoning UL','Flex/Pist UL','Tx/Tz Locked');
% 
%         % legend1 = legend(subplot,'show');
%         set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         clear dataTemp
%         end
%     end
%     end
% 
% 
%     fprintf('processing finished!')
% 
% 
%     clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
%     
% end
% 
% %% PREF SPEED Plot Marker error RMS comparing socket reference and lock state for each speed
% if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
% 
%     % Create figure
% figure1 = figure;
%  
% % Create axes
% axes1 = axes('Parent',figure1,...
% 'XTickLabel',{'Standard Placement','Auto-Placement'},'XTick',[1 2],...
% 'FontSize',14);
% % ylim(axes1,[0.004 0.010]);
% xlim(axes1,[0.5 2.5]);
% box(axes1,'on');
% hold(axes1,'all');
% 
% % Create multiple lines using matrix input to bar
% bar1 = bar(errPref,'Parent',axes1);
% for i = 1:numSubj
%     set(bar1(i),'DisplayName',subjNames{i});
% end
% 
% set(bar1,'BarWidth',1);    % The bars will now touch each other
% % set(bar1(1),'FaceColor',[.5 .5 1]);
% 
% numgroups = size(errPref, 1); 
% numbars = size(errPref, 2); 
% groupwidth = min(0.8, numbars/(numbars+1.5));
% 
% for i = 1:numbars
%       % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
%       x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
%       errorbar(x, errPref(:,i), errPrefStd(:,i), 'k', 'linestyle', 'none');
%  end
% 
% % errbar1 = errorbar(errPref,errPrefStd,'k.');
% % set(bar1(1),'DisplayName','SR1');
% % set(bar1(2),'DisplayName','SR2');
% % set(bar1(3),'DisplayName','SR3');
%  
% % Create ylabel
% ylabel('Avg. RMS (m)','FontSize',13);
% % if IK_tasks==1;daspect([800 1 1]);end
% % if IK_tasks==2;daspect([250 1 1]);end
%  
% % Create title
% if IK_tasks ==1;
%     title('Preferred Speed Marker Error RMS','FontSize',14);
% end
% if IK_tasks ==2;
%     title('Pref. Speed Marker Error RMS (socket/thigh tracking)','FontSize',14);
% end
%  
% % Create legend
% legend1 = legend(axes1,bar1);
% 
% end
% 
% %% PREF SPEED Plot Normalized Marker error RMS comparing socket reference and lock state 
% if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
% 
%     % Create figure
% figure2 = figure;
%  
% % normalize the data
% normErrPref = zeros(size(errPref));
% for ls=1:size(errPref,1)
%    for mod = 1:size(errPref,2) 
%        normErrPref(ls,mod) = errPref(ls,mod)/errPref(1,1);
%    end
% end
% 
% % Create axes
% if SComp==5;axes1 = axes('Parent',figure2,...
% 'XTickLabel',{'Rigid','Flexion','Pistoning','Flex/Pist','4-DOF'},...
% 'XTick',[1 2 3 4 5],...
% 'FontSize',14);
% end
% if SComp==6; axes1 = axes('Parent',figure2,...
% 'XTickLabel',{'Rigid','Flex','Pist','Flex/Pist','4-DOF', '6-DOF'},...
% 'XTick',[1 2 3 4 5 6],...
% 'FontSize',12); 
% end
% if IK_tasks == 1; ylim(axes1,[.5 1.02]); end
% if SComp==5;xlim(axes1,[0.5 5.5]);end
% if SComp==6;xlim(axes1,[0.5 6.5]);end
% box(axes1,'on');
% hold(axes1,'all');
%  
% % Create multiple lines using matrix input to bar
% bar1 = bar(normErrPref,'Parent',axes1);
% % set(bar1(1),'DisplayName','SR-0');
% % set(bar1(2),'DisplayName','SR-25');
% % set(bar1(3),'DisplayName','SR-50');
%  
% % Create ylabel
% ylabel('Normalized Avg. RMS','FontSize',13);
% if IK_tasks==1;daspect([10 1 1]);end
% if IK_tasks==2;daspect([250 1 1]);end
%  
% % Create title
% if IK_tasks ==1;
%     title('IK Model Marker Error for Pref Speed Trials','FontSize',14);
% end
% if IK_tasks ==2;
%     title('Pref. Speed Marker Error (socket/thigh tracking)','FontSize',14);
% end
%  
% % Create legend
% legend1 = legend(axes1,'show');
% 
% end
% 
% %% PREF SPEED Plot model coordinates comparing lockstates and models for each speed
% 
% 
% if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
%     for plots = 1:4
%         if plots == 1;tag = 'socket_ty';end
%         if plots == 2;tag = 'socket_flexion';end
%         if plots == 3;tag = 'socket_rotation';end
%         if plots == 4;tag = 'socket_adduction';end
%         
%         % tag = foot_flex; % change to coordinate you want to plot
% 
%         % find state 
%         for t = 1:size(tags,2)
%             if strcmp(tag, tags(t))
%                 state = t;
%             end
%         end
% 
%     clear t
% 
%     stance = 0:1:100;
% 
%     for speed = spFirst:spLast;
% 
%         figure;
% 
%         % Plot coordinate averages for speed and model
% %         for model = 1:3;
%         subplot(1,2,1);
%             for lockstate = 1:5;
%                 dataTemp = normData{speed,3}{lockstate,1}(:,state);
%                 if lockstate == 1; color = 'k'; end
%                 if lockstate == 2; color = 'b'; end
%                 if lockstate == 3; color = 'r'; end
%                 if lockstate == 4; color = 'c'; end
%                 if lockstate == 5; color = 'm'; end
%                 hold on
%                 plot(stance,dataTemp,color)
%             end
% %         if model==1;ylabel('SR1');end
% %         if model==2;ylabel('SR2');end
% %         if model==3;ylabel('SR3');end
%         stringTemp = ['Avg ',tag,' for Fast Trials'];
%         if speed==1;stringTemp = ['Avg ',tag,' for Fast Trials'];end
%         if speed==2;stringTemp = ['Avg ',tag,' for Pref Trials'];end
%         if speed==3;stringTemp = ['Avg ',tag,' for Slow Trials'];end
% %         if model==1;
%         title(stringTemp);
% %     end
%         % plot standard deviation
%         subplot(1,2,2);
%             for lockstate = 1:5;
%                 dataTemp = normData{speed,3}{lockstate,2}(:,state);
%                 if lockstate == 1; color = 'k'; end
%                 if lockstate == 2; color = 'b'; end
%                 if lockstate == 3; color = 'r'; end
%                 if lockstate == 4; color = 'c'; end
%                 if lockstate == 5; color = 'm'; end
%                 hold on
%                 plot(stance,dataTemp,color)
%             end
% %         if model==1
%             title('  Standard Deviation'); 
% %         end
% 
% 
% 
%         % Create legend
%         legend('All Locked','Flexion UL','Pistoning UL','Flex/Pist UL','Tx/Tz Locked');
% 
%         % legend1 = legend(subplot,'show');
%         set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         clear dataTemp
% %         end
%     end
%     end
% 
% 
%     fprintf('processing finished \n')
% 
% 
%     clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
% end
% 
% %% PREF SPEED Plot Coordinates for each model with 4 DoF socket
% 
% if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
%     
%     figure
%     
%     lockstate = 5;
%     
%     if lockstate ==1;LTag = 'Rigid';end
%     if lockstate ==2;LTag = 'Flexion';end
%     if lockstate ==3;LTag = 'Pistoning';end
%     if lockstate ==4;LTag = 'Flex/Pist';end
%     if lockstate ==5;LTag = '4-DOF';end
% 
%     for plots = 1:4
% 
%         if plots == 1;tag = 'socket_ty';end
%         if plots == 2;tag = 'socket_flexion';end
%         if plots == 3;tag = 'socket_rotation';end
%         if plots == 4;tag = 'socket_adduction';end
%         
% 
%         % tag = foot_flex; % change to coordinate you want to plot
% 
%         % find state 
%         for t = 1:size(tags,2)
%             if strcmp(tag, tags(t))
%                 state = t;
%             end
%         end
% 
%         clear t
% 
%         stance = 0:1:100;
% 
%         speed = 2;
%         
%         % fake plot to correct legend contents
%         if plots ==1;
%             for model = 1:3;
%                 subplot(4,1,plots);
%                 if model == 1; color = 'k'; end
%                 if model == 2; color = 'b'; end
%                 if model == 3; color = 'r'; end
%                 dataTemp = normData{speed,3}{lockstate,1}(:,state);
%                 hold on
%                 plot(stance,dataTemp.*1000,color)
%                 clear dataTemp
%             end
%         end
% 
%         % Plot coordinate averages for speed and model
% %         for model = 1:3;
%             subplot(4,1,plots);
%             if model == 1; color = 'k'; end
%             if model == 2; color = 'b'; end
%             if model == 3; color = 'r'; end
%             dataTemp = normData{speed,3}{lockstate,1}(:,state);
%             SDTemp = normData{speed,3}{lockstate,2}(:,state);
%             hold on
%             if plots ==1;boundedline(stance,dataTemp.*1000,SDTemp.*1000,color,'alpha');end
%             if plots ==2;boundedline(stance,-dataTemp,SDTemp,color,'alpha');end
%             if plots >2;boundedline(stance,dataTemp,SDTemp,color,'alpha');end
%             if plots ==1; ylabel(['Pistoning',sprintf('\n'),'(mm)'],'FontSize',12);end
%             if plots ==2; ylabel(['Flexion/',sprintf('\n'),'Extension (deg)'],'FontSize',12);end
%             if plots ==3; ylabel(['Axial',sprintf('\n'),'Rotation (deg)'],'FontSize',12);end
%             if plots ==4; ylabel(['Abduction/',sprintf('\n'),'Adduction (deg)'],'FontSize',12);end
%             box off
%             
%             if plots==1&&IK_tasks==1;title([LTag ' Socket Motion'],'FontSize',14);end
%             if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Motion (socket/thigh tracking)'],'FontSize',14);end
%             
%             clear dataTemp
% %         end
%         
% 
%         % Create legend
%         if plots ==1;
%             ylim([-30 20])
% %             legend('SR-0','SR-25','SR-50');
% %             set(legend,'Orientation','horizontal',...
% %             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         end
%         if plots ==2;
%             ylim([-20 20])
%         end
%         if plots ==3;
%             ylim([-20 20])
%         end
%         if plots ==4;
%             ylim([-20 20])
%             xlabel('% Gait')
%         end
%     end
%     box off
% 
%     clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
% end
% 
% %% PREF SPEED Plot socket kinematics for each trial and socket type
% 
% if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
%     
%     for lockstate = 2:5;
%         
%     figure
%     
%     if lockstate ==1;LTag = 'Rigid';end
%     if lockstate ==2;LTag = 'Flexion';end
%     if lockstate ==3;LTag = 'Pistoning';end
%     if lockstate ==4;LTag = 'Flex/Pist';end
%     if lockstate ==5;LTag = '4-DOF';end
% 
%     for plots = 1:4
% 
%         if plots == 1;tag = 'socket_ty';end
%         if plots == 2;tag = 'socket_flexion';end
%         if plots == 3;tag = 'socket_rotation';end
%         if plots == 4;tag = 'socket_adduction';end
%         
% 
%         % tag = foot_flex; % change to coordinate you want to plot
% 
%         % find state 
%         for t = 1:size(tags,2)
%             if strcmp(tag, tags(t))
%                 state = t;
%             end
%         end
% 
%         clear t
% 
%         stance = 0:1:100;
% 
%         speed = 2;
%         
%         % fake plot to correct legend contents
% %         if plots ==1;
% %             for model = 1:3;
% %                 subplot(4,1,plots);
% %                 if model == 1; color = 'k'; end
% %                 if model == 2; color = 'b'; end
% %                 if model == 3; color = 'r'; end
% %                 dataTemp = normData{speed,3}{lockstate,1}(:,state);
% %                 hold on
% %                 plot(stance,dataTemp.*1000,color)
% %                 clear dataTemp
% %             end
% %         end
% 
%         % Plot coordinate averages for speed and model
% %         for model = 1:3;
%             subplot(4,1,plots);
%             
%             color = 'b';
% 
%             for tr = 1:nTrials
%                 dataTemp(:,tr) = normData{speed,2}{lockstate,tr}(:,state);
%             end
% 
%             hold on
%             
%             if plots ==1;plot(stance,dataTemp, color);end
% %             if plots ==1;boundedline(stance,dataTemp.*1000,SDTemp.*1000,color,'alpha');end
%             if plots ==2;plot(stance,-dataTemp,color);end
% %             if plots ==2;boundedline(stance,-dataTemp,SDTemp,color,'alpha');end
%             if plots >2;plot(stance,dataTemp,color);end
%             if plots ==1; ylabel(['Pistoning',sprintf('\n'),'(mm)'],'FontSize',12);end
%             if plots ==2; ylabel(['Flexion/',sprintf('\n'),'Extension (deg)'],'FontSize',12);end
%             if plots ==3; ylabel(['Axial',sprintf('\n'),'Rotation (deg)'],'FontSize',12);end
%             if plots ==4; ylabel(['Abduction/',sprintf('\n'),'Adduction (deg)'],'FontSize',12);end
%             box off
%             
%             if plots==1&&IK_tasks==1;title([LTag ' Socket Motion'],'FontSize',14);end
%             if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Motion (socket/thigh tracking)'],'FontSize',14);end
%             
%             clear dataTemp
% %         end
%         
% 
%         % Create legend
%         if plots ==1;
% %             ylim([-30 20])
% %             legend('SR-0','SR-25','SR-50');
% %             set(legend,'Orientation','horizontal',...
% %             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         end
%         if plots ==2;
% %             ylim([-20 20])
%         end
%         if plots ==3;
% %             ylim([-20 20])
%         end
%         if plots ==4;
% %             ylim([-20 20])
%             xlabel('% Gait')
%         end
%     end
%     box off
%     
%     end
%     
%     clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
% 
% end
% 
% % fprintf('saving results \n')
% % save IK_analysis.mat
fprintf('program finished!')

save(normDataSaveName,'fullNormData');
save(errDataSaveName,'fullErrData');