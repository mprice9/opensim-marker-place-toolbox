%-------------------------------------------------------------------------
% AB_IK_Plots.m
%-------------------------------------------------------------------------

clear
clc
close all

%% Load data

% load('fullNormData.mat');
% load('fullErrData.mat');
% load('fullNormDataFiltered.mat');
% load('fullErrDataFiltered.mat');

load('fullNormDataNoTilt.mat');
load('fullErrDataNoTilt.mat');
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

errGenPref = zeros(2,5*numSubj);
errGenPrefMax = zeros(2,5*numSubj);
errGenSlow = zeros(2,5*numSubj);
errGenSlowMax = zeros(2,5*numSubj);
errGenFast = zeros(2,5*numSubj);
errGenFastMax = zeros(2,5*numSubj);



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

errGenPrefMean = mean(errGenPref,2);
errGenPrefMaxMean = mean(errGenPrefMax,2);
errGenPrefStd = std(errGenPref,0,2);
errGenPrefMaxStd = std(errGenPrefMax,0,2);

errGenFastMean = mean(errGenFast,2);
errGenFastMaxMean = mean(errGenFastMax,2);
errGenFastStd = std(errGenFast,0,2);
errGenFastMaxStd = std(errGenFastMax,0,2);

errGenSlowMean = mean(errGenSlow,2);
errGenSlowMaxMean = mean(errGenSlowMax,2);
errGenSlowStd = std(errGenSlow,0,2);
errGenSlowMaxStd = std(errGenSlowMax,0,2);

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

%% Plot Marker error RMS for manually vs autoplaced markers preferred speed

% Create figure
figure1 = figure;
 
% Create axes
axes1 = axes('Parent',figure1,...
'XTickLabel',{'Standard Placement','Auto-Placement'},'XTick',[1 2],...
'FontSize',14);
ylim(axes1,[0 0.017]);
xlim(axes1,[0.5 2.5]);
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to bar
bar1 = bar(errPref,'Parent',axes1);
for i = 1:numSubj
    set(bar1(i),'DisplayName',subjNames{i});
end

set(bar1,'BarWidth',1);    % The bars will now touch each other
% set(bar1(1),'FaceColor',[.5 .5 1]);

numgroups = size(errPref, 1); 
numbars = size(errPref, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errPref(:,i), errPrefStd(:,i), 'k', 'linestyle', 'none');
end
 
% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
 
% Create title
title('Preferred Speed Marker Error RMS','FontSize',14);
 
% Create legend
legend1 = legend(axes1,bar1);

%% PREF SPEED Plot Marker error RMS all subjects averaged
% Create figure
figure1 = figure;
 
% Create axes
axes1 = axes('Parent',figure1,...
'XTickLabel',{'Standard Placement','Auto-Placement'},'XTick',[1 2],...
'FontSize',14);
ylim(axes1,[0 0.015]);
xlim(axes1,[0.5 2.5]);
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to bar
bar1 = bar(errGenPrefMean,'Parent',axes1);

numgroups = size(errGenPrefMean, 1); 
numbars = size(errGenPrefMean, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errGenPrefMean(:,i), errGenPrefStd(:,i), 'k', 'linestyle', 'none');
end
 
% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
 
% Create title
title('Preferred Speed Marker Error RMS','FontSize',14);


%% FAST SPEED Plot Marker error RMS all subjects averaged
% Create figure
figure1 = figure;
 
% Create axes
axes1 = axes('Parent',figure1,...
'XTickLabel',{'Standard Placement','Auto-Placement'},'XTick',[1 2],...
'FontSize',14);
ylim(axes1,[0 0.015]);
xlim(axes1,[0.5 2.5]);
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to bar
bar1 = bar(errGenFastMean,'Parent',axes1);

numgroups = size(errGenFastMean, 1); 
numbars = size(errGenFastMean, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errGenFastMean(:,i), errGenFastStd(:,i), 'k', 'linestyle', 'none');
end
 
% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
 
% Create title
title('Fast Speed Marker Error RMS','FontSize',14);

%% SLOW SPEED Plot Marker error RMS all subjects averaged
% Create figure
figure1 = figure;
 
% Create axes
axes1 = axes('Parent',figure1,...
'XTickLabel',{'Standard Placement','Auto-Placement'},'XTick',[1 2],...
'FontSize',14);
ylim(axes1,[0 0.015]);
xlim(axes1,[0.5 2.5]);
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to bar
bar1 = bar(errGenSlowMean,'Parent',axes1);

numgroups = size(errGenSlowMean, 1); 
numbars = size(errGenSlowMean, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for i = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, errGenSlowMean(:,i), errGenSlowStd(:,i), 'k', 'linestyle', 'none');
end
 
% Create ylabel
ylabel('Avg. RMS (m)','FontSize',13);
% if IK_tasks==1;daspect([800 1 1]);end
 
% Create title
title('Slow Speed Marker Error RMS','FontSize',14);


%% Hip/knee/ankle kinematics both sides

% figure('OuterPosition',[20 20 850 850])
% labels = {'A)','B)','C)','D)','E)','F)','G)','H)','I)'};

for subj = 1:numSubj
    
    figure('OuterPosition',[100 100 850 300])
%     options.datasets{1} = [subjFolders{subj} '\IKResults\Rigid\'];
%     options.datasets{2} = [subjFolders{subj} '\IKResults\4DOF\'];
%     % load frames.mat
%     options.frames{1} = frames{subj};
%     options.frames{2} = frames{subj};
%     options.label{1} = 'Rigid';
%     options.label{2} = '4-DOF';
%     options.filter = 10;  % filter window size
%     options.outputLevel = 0;
%     options.dataType = 'IK';        
%     options.stitchData = 'n';   
%     options.norm2mass = 'no';


    for plots = 1:3

        
        if plots == 3;coord_tag = 'ankle_angle_r';end
        if plots == 2;coord_tag = 'knee_angle_r';end
        if plots == 1;coord_tag = 'hip_flexion_r';end


        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(fullTags{subj},2)
            if strcmp(coord_tag, fullTags{subj}(t))
                coord_state = t;
            end
        end

        clear t

        stance = 0:1:100;

        speed = 2;
        
        absPlotNum = subj + ((plots-1) * 3);
        subplot(1,3,plots)
        
        
%         options.removeOffset = 'no';
%         options.stitchData = 'y';
%         if plots == 2  
%             options.mirror = 'y';  
%         else
%             options.mirror = 'n';
%         end
%         options.tag = i_tag;
%         compareResults(options)
%         load compResults.mat
%         dataIntact = compResults;
%         options.removeOffset = 'n';
%         options.stitchData = 'n';
%         if plots == 2  
%             options.mirror = 'y';  
%         else
%             options.mirror = 'n';
%         end
%         options.tag = p_tag;  
%         compareResults(options)
%         load compResults.mat
%         dataPros = compResults;
            
            % Plot coordinate averages for speed and model
        if plots == 2    
            dataMan = -fullNormData{subj}{speed,3}{1,1}(:,coord_state);
            dataAuto = -fullNormData{subj}{speed,3}{2,1}(:,coord_state);
        else
            dataMan = fullNormData{subj}{speed,3}{1,1}(:,coord_state);
            dataAuto = fullNormData{subj}{speed,3}{2,1}(:,coord_state);
        end
        
        SDMan = fullNormData{subj}{speed,3}{1,2}(:,coord_state);
        SDAuto = fullNormData{subj}{speed,3}{2,2}(:,coord_state);
        
        colorMan = 'k';
        colorAuto = 'r';
                

%         maxDiffPros(plots,subj) = max(dataPros{2,3}(:,1)-dataPros{3,3}(:,1));
%         maxDiffIntact(plots,subj) = max(dataIntact{2,3}(:,1)-dataIntact{3,3}(:,1));

        hold on        
        boundedline(stance,dataMan,SDMan,colorMan,'alpha');
        boundedline(stance,dataAuto,SDAuto,colorAuto,'alpha');


%         plot([startSwing(subj) startSwing(subj)],[-100000 100000],'k--')
%         label = labels{absPlotNum};            
%         text(.05,.9,label,'Units','Normalized','FontSize',12)
%         ylabel('Angle (deg)', 'FontSize',14)
%         if plots == 1; title([subjNames{subj}], 'FontSize',14);end
        if plots == 3; title('Ankle', 'FontSize',14);end
        if plots == 2; title([subjNames{subj} newline 'Knee'], 'FontSize',14);end
        if plots == 1; title('Hip', 'FontSize',14);end
        
%         if plots ==1 && subj == 1; ylabel(['Ankle',sprintf('\n'),'Angle (deg)'],'FontSize',12);end
%         if plots ==2 && subj == 1; ylabel(['Knee Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
%         if plots ==3 && subj == 1; ylabel(['Hip Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        if plots ==1; ylabel('Angle (deg)','FontSize',12);end
%         if plots ==2; ylabel(['Knee Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
%         if plots ==3; ylabel(['Hip Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        
        if plots ==3
            ylim([-25 25])
        end       
        if plots ==2
            ylim([-10 80])
        end
        if plots ==1
            ylim([-30 40])
        end

        
        % Create legend
%         if absPlotNum ==9;
%             legend('ESR Rigid','Intact Rigid','ESR 4-DOF','Intact 4-DOF');
%             set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         end
%         if absPlotNum > 6 && absPlotNum < 10;
            xlabel('% Gait')
%         end
        
    end
    box off
 end

%% Hip/knee/ankle kinematics both sides all subjects averaged
    
    figure('OuterPosition',[100 100 850 300])
%     options.datasets{1} = [subjFolders{subj} '\IKResults\Rigid\'];
%     options.datasets{2} = [subjFolders{subj} '\IKResults\4DOF\'];
%     % load frames.mat
%     options.frames{1} = frames{subj};
%     options.frames{2} = frames{subj};
%     options.label{1} = 'Rigid';
%     options.label{2} = '4-DOF';
%     options.filter = 10;  % filter window size
%     options.outputLevel = 0;
%     options.dataType = 'IK';        
%     options.stitchData = 'n';   
%     options.norm2mass = 'no';


    for plots = 1:3

        
        if plots == 3;coord_tag = 'ankle_angle_r';end
        if plots == 2;coord_tag = 'knee_angle_r';end
        if plots == 1;coord_tag = 'hip_flexion_r';end


        % tag = foot_flex; % change to coordinate you want to plot

        % find state 
        for t = 1:size(fullTags{subj},2)
            if strcmp(coord_tag, fullTags{subj}(t))
                coord_state = t;
            end
        end

        clear t

        stance = 0:1:100;

        speed = 2;
        
        absPlotNum = subj + ((plots-1) * 3);
        subplot(1,3,plots)
        
        
%         options.removeOffset = 'no';
%         options.stitchData = 'y';
%         if plots == 2  
%             options.mirror = 'y';  
%         else
%             options.mirror = 'n';
%         end
%         options.tag = i_tag;
%         compareResults(options)
%         load compResults.mat
%         dataIntact = compResults;
%         options.removeOffset = 'n';
%         options.stitchData = 'n';
%         if plots == 2  
%             options.mirror = 'y';  
%         else
%             options.mirror = 'n';
%         end
%         options.tag = p_tag;  
%         compareResults(options)
%         load compResults.mat
%         dataPros = compResults;
            
            % Plot coordinate averages for speed and model
        if plots == 2    
            dataMan = -kinDataMean{speed,1,coord_state};
            dataAuto = -kinDataMean{speed,2,coord_state};
        else
            dataMan = kinDataMean{speed,1,coord_state};
            dataAuto = kinDataMean{speed,2,coord_state};
        end
        
        SDMan = kinDataStd{speed,1,coord_state};
        SDAuto = kinDataStd{speed,2,coord_state};
        
        colorMan = 'k';
        colorAuto = 'r';
                

%         maxDiffPros(plots,subj) = max(dataPros{2,3}(:,1)-dataPros{3,3}(:,1));
%         maxDiffIntact(plots,subj) = max(dataIntact{2,3}(:,1)-dataIntact{3,3}(:,1));

        hold on        
        boundedline(stance,dataMan,SDMan,colorMan,'alpha');
        boundedline(stance,dataAuto,SDAuto,colorAuto,'alpha');


%         plot([startSwing(subj) startSwing(subj)],[-100000 100000],'k--')
%         label = labels{absPlotNum};            
%         text(.05,.9,label,'Units','Normalized','FontSize',12)
%         ylabel('Angle (deg)', 'FontSize',14)
        if plots == 3; title('Ankle', 'FontSize',14);end
        if plots == 2; title(['All subjects' newline 'Knee'], 'FontSize',14);end
        if plots == 1; title('Hip', 'FontSize',14);end
        
%         if plots ==1 && subj == 1; ylabel(['Ankle',sprintf('\n'),'Angle (deg)'],'FontSize',12);end
%         if plots ==2 && subj == 1; ylabel(['Knee Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
%         if plots ==3 && subj == 1; ylabel(['Hip Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        if plots ==1; ylabel('Angle (deg)','FontSize',12);end
%         if plots ==2; ylabel(['Knee Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
%         if plots ==3; ylabel(['Hip Angle',sprintf('\n'),'(deg)'],'FontSize',12);end
        
        if plots ==3
            ylim([-25 25])
        end       
        if plots ==2
            ylim([-10 80])
        end
        if plots ==1
            ylim([-30 40])
        end

        
        % Create legend
%         if absPlotNum ==9;
%             legend('ESR Rigid','Intact Rigid','ESR 4-DOF','Intact 4-DOF');
%             set(legend,'Orientation','horizontal',...
%             'Position',[0.129689174705252 0.0212 0.77491961414791 0.02]);
%         end
%         if absPlotNum > 6 && absPlotNum < 10;
            xlabel('% Gait')
%         end
        
    end
    box off



