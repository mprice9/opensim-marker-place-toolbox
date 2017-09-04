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

% list trial number labels manually in the corresponding array as they 
% appear in the file name
% don't delete an array if you don't want the data, it will be detected
FAST = {'T0021', 'T0022', 'T0024'};
PREF = {'0002', '0003', '0005','00005','00006','00011','0000001','0000006','0000007'};
SLOW = {'T0026', 'T0027', 'T0029'};

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

%% load data
fprintf('loading data\n');

% point to folders where data is located
ik_data_folder = ([pwd '\IKResults']);
ik_error_folder = ([pwd '\IKErrors']);

IKtrials = dir(fullfile(ik_data_folder, '*.mot'));
IKerrors = dir(fullfile(ik_error_folder, '*.sto'));

nTrials = size(IKtrials);

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

errData = cell(3,3);
errData{1,1} = 'fast';
errData{1,2} = cell(6,3);  % trial error
errData{1,3} = cell(6,3);  % trial error stats
errData{2,1} = 'pref';
errData{2,2} = cell(6,3);  % trial error
errData{2,3} = cell(6,3);  % trial error stats
errData{3,1} = 'slow';
errData{3,2} = cell(6,3);  % trial error
errData{3,3} = cell(6,3);  % trial error stats

fprintf('data loaded\n');

%% separate trials
fprintf('separating trials, normalizing to percent stance, storing new data\n')
for trial = 1:nTrials

    % Get the name of the file for this trial
    kinFile = IKtrials(trial).name;
    errFile = IKerrors(trial).name;
    
    % Create name of trial from .mot file name
    kinName = regexprep(kinFile,'.mot','');
    fullkinpath = ([ik_data_folder '\' kinFile]);
    fullerrpath = ([ik_error_folder '\' errFile]);
    
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
    for i = 1:size(FAST,2)
        if(strcmp(C{3},FAST{i}));Sp = 1; Tr = i;end
    end
    for i = 1:size(PREF,2)
        if(strcmp(C{3},PREF{i}));Sp = 2; Tr = i;end
    end
    for i = 1:size(SLOW,2)
        if(strcmp(C{3},SLOW{i}));Sp = 3; Tr = i;end
    end
    
    % label socket reference
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
    normData{Sp,2}{LS,Tr} = zeros(101,size(data.data,2)); 
    errData{Sp,2}{LS,Tr} = zeros(size(error.data,1),size(error.data,2));
    
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
%         temp = dynWindFilt(20,temp);
        x = norm2stance(temp);
        
        % store in appropriate cell
        normData{Sp,2}{LS,Tr}(:,row) = x;
    end
    
    % store error appropriately
    for row = 1:size(error.data,2)
        temp = error.data(:,row);
        % store in appropriate cell
        errData{Sp,2}{LS,Tr}(:,row) = temp;
    end    
    
    fprintf(['working on trial ' num2str(trial) ' out of ' num2str(nTrials(1)) '\n']);
    
    clear temp P Q x  Avg SD temp temp2 peak row
    
end

fprintf('complete\n')

clear trial nTrials LS kinFile kinName data delimiterIn errFile errName...
    error FAST PREF SLOW Tr SR Sp i fullerrpath fullkinpath headerlinesIn...
    ik_data_folder ik_error_folder IKerrors IKtrials 

%% calculate and store statistics
fprintf('calculating kinematic statistics\n')

for speed = spFirst:spLast
    for lockstate = 1:6
%         for model = 1:3
            for var = 1:size(normData{speed,2}{lockstate,1},2)
                for samp = 1:101
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

fprintf('complete\n')
clear speed lockstate model var samp  trial

%% calculate marker error averages, stdevs and maximums for each speed
fprintf('calculating marker error statistics\n')
nTrials = size(errData{2,2},2);
error = cell(nTrials,3);

for speed = spFirst:spLast
    for lockstate = 1:6
%         for model = 1:3
            for var = 1:size(errData{speed,2}{lockstate,1},2)
                % individual trials
                for trial = 1:nTrials
                    error{trial,speed} = errData{speed,2}{lockstate,trial}(:,var);
                    A = error{trial,speed};
                    if var == 2;A = sqrt(A);end     % take sqrt to get total error
                    errData{speed,3}{lockstate,trial}(1,var) = mean(A);   % average 
                    errData{speed,3}{lockstate,trial}(2,var) = std(A);    % standard deviation
                    errData{speed,3}{lockstate,trial}(3,var) = max(A);    % max 
                    clear A
                end
                
                % combined across trials
                A = error{1,speed};
                for n = 2:nTrials
                    A = cat(1,A,error{n,speed});
                end
                if var == 2;A = sqrt(A);end         % take sqrt to get total error
                errData{speed,4}{lockstate}(1,var) = mean(A);   % average
                errData{speed,4}{lockstate}(2,var) = std(A);    % standard deviation
                errData{speed,4}{lockstate}(3,var) = max(A);    % max
                
                clear A

                % combined across trials using individual trial averages
                for trial = 1:nTrials
                    A(trial) = errData{speed,3}{lockstate,trial}(2,var);                   
                end
                errData{speed,5}{lockstate}(2,var) = std(A);    % standard deviation
                
            end
%         end
    end
end

fprintf('complete\n')

% clear error lockstate model n nTrials speed trial var ans

%% Error comparison setup
fprintf('parsing error statistics\n')
if FAST_flag == 1
    speed=1;
    errFast = zeros(6,1);
    for lockstate = 1:6;
        for model = 1:3
            errFast(lockstate) = errData{speed,4}{lockstate}(1,3);
        end
    end
end

if PREF_flag == 1
    speed=2;
    errPref = zeros(6,1);
    errStd = zeros(6,1);
    for lockstate = 1:6;
%         for model = 1:3
            errPref(lockstate) = errData{speed,4}{lockstate}(1,3);
            errStd(lockstate) = errData{speed,5}{lockstate}(2,3);
%         end
    end
end

if SLOW_flag == 1;
    speed=3;
    errSlow = zeros(6,1);
    for lockstate = 1:6;
        for model = 1:3
            errSlow(lockstate) = errData{speed,4}{lockstate}(1,3);
        end
    end
end



% model=1;
% errSR1 = zeros(6,3);
% for lockstate = 1:6
%     for speed = spFirst:spLast
%         errSR1(lockstate, speed) = errData{speed,4}{model,lockstate}(1,3);
%     end
% end
% model=2;
% errSR2 = zeros(6,3);
% for lockstate = 1:6
%     for speed = spFirst:spLast
%         errSR2(lockstate, speed) = errData{speed,4}{model,lockstate}(1,3);
%     end
% end
% model=3;
% errSR3 = zeros(6,3);
% for lockstate = 1:6
%     for speed = spFirst:spLast
%         errSR3(lockstate, speed) = errData{speed,4}{model,lockstate}(1,3);
%     end
% end
fprintf('complete\n')
clear lockstate speed model

%% ALL SPEEDS Plot Marker errors comparing socket reference and lock state for each speed
if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
    fprintf('generating plots\n')
    Marker_Error = figure;
    errMin = .11;
    errMax = .145;

    % name('Average Total Marker Error')

    % Create subplot
    subplot1 = subplot(3,1,1,'Parent',Marker_Error,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
    ylim(subplot1,[errMin errMax]);
    box(subplot1,'on');
    hold(subplot1,'all');

    % Create multiple lines using matrix input to bar
    bar(errFast,'Parent',subplot1);

    % Create ylabel
    ylabel('Fast', 'fontsize', 14);
    % Create title
    title('Average Total Marker Error','fontsize',16);

    % Create subplot
    subplot2 = subplot(3,1,2,'Parent',Marker_Error,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
    ylim(subplot2,[errMin errMax]);
    box(subplot2,'on');
    hold(subplot2,'all');

    % Create multiple lines using matrix input to bar
    bar(errPref,'Parent',subplot2);

    % Create ylabel
    ylabel('Preferred', 'fontsize', 14);

    % Create subplot
    subplot3 = subplot(3,1,3,'Parent',Marker_Error,...
        'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},...
        'XTick',[1 2 3 4 5]);
    ylim(subplot3,[errMin errMax]);
    box(subplot3,'on');
    hold(subplot3,'all');

    % Create multiple lines using matrix input to bar
    bar(errSlow,'Parent',subplot3);

    % Create ylabel
    ylabel('Slow', 'fontsize', 14);

    % Create legend
    legend('SR1','SR2','SR3');

    legend1 = legend(subplot3,'show');
    set(legend1,'Orientation','horizontal',...
        'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
    
end

%% ALL SPEEDS Plot Marker errors comparing lock state and speed for each socket reference 
if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
    Marker_ErrorSR = figure;
    errMin = .11;
    errMax = .145;

    % name('Average Total Marker Error')

    % Create subplot
    subplot1 = subplot(3,1,1,'Parent',Marker_ErrorSR,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
    ylim(subplot1,[errMin errMax]);
    box(subplot1,'on');
    hold(subplot1,'all');

    % Create multiple lines using matrix input to bar
    bar(errSR1,'Parent',subplot1);

    % Create ylabel
    ylabel('SR1', 'fontsize', 14);
    % Create title
    title('Average Total Marker Error','fontsize',16);

    % Create subplot
    subplot2 = subplot(3,1,2,'Parent',Marker_ErrorSR,'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},'XTick',[1 2 3 4 5]);
    ylim(subplot2,[errMin errMax]);
    box(subplot2,'on');
    hold(subplot2,'all');

    % Create multiple lines using matrix input to bar
    bar(errSR2,'Parent',subplot2);

    % Create ylabel
    ylabel('SR2', 'fontsize', 14);

    % Create subplot
    subplot3 = subplot(3,1,3,'Parent',Marker_ErrorSR,...
        'XTickLabel',{'All Locked','Flex UL','Pist UL','Pist/Flex UL','Tx/Tz Locked'},...
        'XTick',[1 2 3 4 5]);
    ylim(subplot3,[errMin errMax]);
    box(subplot3,'on');
    hold(subplot3,'all');

    % Create multiple lines using matrix input to bar
    bar(errSR3,'Parent',subplot3);

    % Create ylabel
    ylabel('SR3', 'fontsize', 14);

    % Create legend
    legend('Fast','Preferred','Slow');

    legend1 = legend(subplot3,'show');
    set(legend1,'Orientation','horizontal',...
        'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);

    clear errMax errMin
    
end

%% ALL SPEEDS Plot model coordinates comparing lockstates and models for each speed
% set tag = to state you want to plot
if FAST_flag==1&&PREF_flag==1&&SLOW_flag==1
    for plots = 1:2

        if plots == 1;tag = 'socket_ty';end
        if plots == 2;tag = 'socket_flexion';end

        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(tags,2)
            if strcmp(tag, tags(t))
                state = t;
            end
        end

    clear t

    stance = 1:1:100;

    for speed = 1:3;

        figure;

        % Plot coordinate averages for speed and model
        for model = 1:3;
        subplot(3,2,model*2-1);
            for lockstate = 1:5;
                dataTemp = normData{speed,3}{model, lockstate,1}(:,state);
                if lockstate == 1; color = 'k'; end
                if lockstate == 2; color = 'b'; end
                if lockstate == 3; color = 'r'; end
                if lockstate == 4; color = 'c'; end
                if lockstate == 5; color = 'm'; end
                hold on
                plot(stance,dataTemp,color)
            end
        if model==1;ylabel('SR1');end
        if model==2;ylabel('SR2');end
        if model==3;ylabel('SR3');end
        stringTemp = ['Avg ',tag,' for Fast Trials'];
        if speed==1;stringTemp = ['Avg ',tag,' for Fast Trials'];end
        if speed==2;stringTemp = ['Avg ',tag,' for Pref Trials'];end
        if speed==3;stringTemp = ['Avg ',tag,' for Slow Trials'];end
        if model==1;title(stringTemp);end
        % plot standard deviation
        subplot(3,2,model*2);
            for lockstate = 1:5;
                dataTemp = normData{speed,3}{model, lockstate,2}(:,state);
                if lockstate == 1; color = 'k'; end
                if lockstate == 2; color = 'b'; end
                if lockstate == 3; color = 'r'; end
                if lockstate == 4; color = 'c'; end
                if lockstate == 5; color = 'm'; end
                hold on
                plot(stance,dataTemp,color)
            end
        if model==1;title('  Standard Deviation'); end



        % Create legend
        legend('All Locked','Flexion UL','Pistoning UL','Flex/Pist UL','Tx/Tz Locked');

        % legend1 = legend(subplot,'show');
        set(legend,'Orientation','horizontal',...
            'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        clear dataTemp
        end
    end
    end


    fprintf('processing finished!')


    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
    
end

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
if IK_tasks == 1; ylim(axes1,[0.004 0.010]); end
if SComp==5;xlim(axes1,[0.5 5.5]);end
if SComp==6;xlim(axes1,[0.5 6.5]);end
box(axes1,'on');
hold(axes1,'all');
 
% Create multiple lines using matrix input to bar
bar1 = bar(errPref,'Parent',axes1,'FaceColor',[.5 .5 1]);
errbar1 = errorbar(errPref,errStd,'k.');
% set(bar1(1),'DisplayName','SR1');
% set(bar1(2),'DisplayName','SR2');
% set(bar1(3),'DisplayName','SR3');
 
% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
if IK_tasks==1;daspect([800 1 1]);end
if IK_tasks==2;daspect([250 1 1]);end
 
% Create title
if IK_tasks ==1;
    title('Preferred Speed Marker Error RMS','FontSize',14);
end
if IK_tasks ==2;
    title('Pref. Speed Marker Error RMS (socket/thigh tracking)','FontSize',14);
end
 
% Create legend
legend1 = legend(axes1,'show');

end

%% PREF SPEED Plot Normalized Marker error RMS comparing socket reference and lock state 
if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0

    % Create figure
figure2 = figure;
 
% normalize the data
normErrPref = zeros(size(errPref));
for ls=1:size(errPref,1)
   for mod = 1:size(errPref,2) 
       normErrPref(ls,mod) = errPref(ls,mod)/errPref(1,1);
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
if IK_tasks == 1; ylim(axes1,[.5 1.02]); end
if SComp==5;xlim(axes1,[0.5 5.5]);end
if SComp==6;xlim(axes1,[0.5 6.5]);end
box(axes1,'on');
hold(axes1,'all');
 
% Create multiple lines using matrix input to bar
bar1 = bar(normErrPref,'Parent',axes1);
% set(bar1(1),'DisplayName','SR-0');
% set(bar1(2),'DisplayName','SR-25');
% set(bar1(3),'DisplayName','SR-50');
 
% Create ylabel
ylabel('Normalized Avg. RMS','FontSize',13);
if IK_tasks==1;daspect([10 1 1]);end
if IK_tasks==2;daspect([250 1 1]);end
 
% Create title
if IK_tasks ==1;
    title('IK Model Marker Error for Pref Speed Trials','FontSize',14);
end
if IK_tasks ==2;
    title('Pref. Speed Marker Error (socket/thigh tracking)','FontSize',14);
end
 
% Create legend
legend1 = legend(axes1,'show');

end

%% PREF SPEED Plot model coordinates comparing lockstates and models for each speed


if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
    for plots = 1:4
        if plots == 1;tag = 'socket_ty';end
        if plots == 2;tag = 'socket_flexion';end
        if plots == 3;tag = 'socket_rotation';end
        if plots == 4;tag = 'socket_adduction';end
        
        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(tags,2)
            if strcmp(tag, tags(t))
                state = t;
            end
        end

    clear t

    stance = 0:1:100;

    for speed = spFirst:spLast;

        figure;

        % Plot coordinate averages for speed and model
%         for model = 1:3;
        subplot(1,2,1);
            for lockstate = 1:5;
                dataTemp = normData{speed,3}{lockstate,1}(:,state);
                if lockstate == 1; color = 'k'; end
                if lockstate == 2; color = 'b'; end
                if lockstate == 3; color = 'r'; end
                if lockstate == 4; color = 'c'; end
                if lockstate == 5; color = 'm'; end
                hold on
                plot(stance,dataTemp,color)
            end
%         if model==1;ylabel('SR1');end
%         if model==2;ylabel('SR2');end
%         if model==3;ylabel('SR3');end
        stringTemp = ['Avg ',tag,' for Fast Trials'];
        if speed==1;stringTemp = ['Avg ',tag,' for Fast Trials'];end
        if speed==2;stringTemp = ['Avg ',tag,' for Pref Trials'];end
        if speed==3;stringTemp = ['Avg ',tag,' for Slow Trials'];end
%         if model==1;
        title(stringTemp);
%     end
        % plot standard deviation
        subplot(1,2,2);
            for lockstate = 1:5;
                dataTemp = normData{speed,3}{lockstate,2}(:,state);
                if lockstate == 1; color = 'k'; end
                if lockstate == 2; color = 'b'; end
                if lockstate == 3; color = 'r'; end
                if lockstate == 4; color = 'c'; end
                if lockstate == 5; color = 'm'; end
                hold on
                plot(stance,dataTemp,color)
            end
%         if model==1
            title('  Standard Deviation'); 
%         end



        % Create legend
        legend('All Locked','Flexion UL','Pistoning UL','Flex/Pist UL','Tx/Tz Locked');

        % legend1 = legend(subplot,'show');
        set(legend,'Orientation','horizontal',...
            'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        clear dataTemp
%         end
    end
    end


    fprintf('processing finished \n')


    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
end

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

        if plots == 1;tag = 'socket_ty';end
        if plots == 2;tag = 'socket_flexion';end
        if plots == 3;tag = 'socket_rotation';end
        if plots == 4;tag = 'socket_adduction';end
        

        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(tags,2)
            if strcmp(tag, tags(t))
                state = t;
            end
        end

        clear t

        stance = 0:1:100;

        speed = 2;
        
        % fake plot to correct legend contents
        if plots ==1;
            for model = 1:3;
                subplot(4,1,plots);
                if model == 1; color = 'k'; end
                if model == 2; color = 'b'; end
                if model == 3; color = 'r'; end
                dataTemp = normData{speed,3}{lockstate,1}(:,state);
                hold on
                plot(stance,dataTemp.*1000,color)
                clear dataTemp
            end
        end

        % Plot coordinate averages for speed and model
%         for model = 1:3;
            subplot(4,1,plots);
            if model == 1; color = 'k'; end
            if model == 2; color = 'b'; end
            if model == 3; color = 'r'; end
            dataTemp = normData{speed,3}{lockstate,1}(:,state);
            SDTemp = normData{speed,3}{lockstate,2}(:,state);
            hold on
            if plots ==1;boundedline(stance,dataTemp.*1000,SDTemp.*1000,color,'alpha');end
            if plots ==2;boundedline(stance,-dataTemp,SDTemp,color,'alpha');end
            if plots >2;boundedline(stance,dataTemp,SDTemp,color,'alpha');end
            if plots ==1; ylabel(['Pistoning',sprintf('\n'),'(mm)'],'FontSize',12);end
            if plots ==2; ylabel(['Flexion/',sprintf('\n'),'Extension (deg)'],'FontSize',12);end
            if plots ==3; ylabel(['Axial',sprintf('\n'),'Rotation (deg)'],'FontSize',12);end
            if plots ==4; ylabel(['Abduction/',sprintf('\n'),'Adduction (deg)'],'FontSize',12);end
            box off
            
            if plots==1&&IK_tasks==1;title([LTag ' Socket Motion'],'FontSize',14);end
            if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Motion (socket/thigh tracking)'],'FontSize',14);end
            
            clear dataTemp
%         end
        

        % Create legend
        if plots ==1;
            ylim([-30 20])
%             legend('SR-0','SR-25','SR-50');
%             set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        end
        if plots ==2;
            ylim([-20 20])
        end
        if plots ==3;
            ylim([-20 20])
        end
        if plots ==4;
            ylim([-20 20])
            xlabel('% Gait')
        end
    end
    box off

    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR
end

%% PREF SPEED Plot socket kinematics for each trial and socket type

if FAST_flag==0&&PREF_flag==1&&SLOW_flag==0
    
    for lockstate = 2:5;
        
    figure
    
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
        for t = 1:size(tags,2)
            if strcmp(tag, tags(t))
                state = t;
            end
        end

        clear t

        stance = 0:1:100;

        speed = 2;
        
        % fake plot to correct legend contents
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

        % Plot coordinate averages for speed and model
%         for model = 1:3;
            subplot(4,1,plots);
            
            color = 'b';

            for tr = 1:nTrials
                dataTemp(:,tr) = normData{speed,2}{lockstate,tr}(:,state);
            end

            hold on
            
            if plots ==1;plot(stance,dataTemp, color);end
%             if plots ==1;boundedline(stance,dataTemp.*1000,SDTemp.*1000,color,'alpha');end
            if plots ==2;plot(stance,-dataTemp,color);end
%             if plots ==2;boundedline(stance,-dataTemp,SDTemp,color,'alpha');end
            if plots >2;plot(stance,dataTemp,color);end
            if plots ==1; ylabel(['Pistoning',sprintf('\n'),'(mm)'],'FontSize',12);end
            if plots ==2; ylabel(['Flexion/',sprintf('\n'),'Extension (deg)'],'FontSize',12);end
            if plots ==3; ylabel(['Axial',sprintf('\n'),'Rotation (deg)'],'FontSize',12);end
            if plots ==4; ylabel(['Abduction/',sprintf('\n'),'Adduction (deg)'],'FontSize',12);end
            box off
            
            if plots==1&&IK_tasks==1;title([LTag ' Socket Motion'],'FontSize',14);end
            if plots==1&&IK_tasks==2;title(['Pref. Speed ' LTag ' Socket Motion (socket/thigh tracking)'],'FontSize',14);end
            
            clear dataTemp
%         end
        

        % Create legend
        if plots ==1;
%             ylim([-30 20])
%             legend('SR-0','SR-25','SR-50');
%             set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
        end
        if plots ==2;
%             ylim([-20 20])
        end
        if plots ==3;
%             ylim([-20 20])
        end
        if plots ==4;
%             ylim([-20 20])
            xlabel('% Gait')
        end
    end
    box off
    
    end
    
    clear dataTemp color legend1 lockstate Marker_Error Marker_ErrorSR

end

% fprintf('saving results \n')
% save IK_analysis.mat
fprintf('program finished!')
