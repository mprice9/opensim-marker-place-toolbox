

clc
clear all
close all

%% Calculate and store data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get frames
clc
forceFolder = [pwd '\TrialData\Pref\'];
frames = frameFinder(forceFolder);

%% get GRF 
options.datasets{1} = [pwd '\ExtForces\'];
options.label{1} = 'Prefered';
options.Frames{1} = frames;
options.outputLevel = 5;
options.filter = 20;
options.subjectMass{1} = 104.3;
options.norm2mass = 'yes';


combineGRF(options);
% clear 
load combinedGRF.mat

%% IK
options.datasets{1} = 'IKResults\Rigid\';
options.datasets{2} = 'IKResults\4DOF\';
% load frames.mat
options.frames{1} = frames;
options.frames{2} = frames;
options.label{1} = 'Rigid';
options.label{2} = '4-DOF';
options.filter = 10;  % filter window size
options.outputLevel = 1;
options.dataType = 'IK';        
options.stitchData = 'n';   
options.norm2mass = 'no';


% ankle and foot prosthesis kinematics
options.removeOffset = 'no';
options.stitchData = 'y';
options.mirror = 'n';  
options.tag = 'ankle_angle_r';
compareResults(options)
load compResults.mat
data.IK.AnkleFlex = compResults;
options.removeOffset = 'n';
options.stitchData = 'n';
options.mirror = 'n';
options.tag = 'foot_flex';  
compareResults(options)
load compResults.mat
data.IK.ProsFootFlex = compResults;

% knee kinematics
options.mirror = 'y';
options.removeOffset = 'no';
options.stitchData = 'y';
options.tag = 'knee_angle_r';
compareResults(options)
load compResults.mat
data.IK.KneeFlexionR = compResults;
options.mirror = 'y';
options.removeOffset = 'no';
options.stitchData = 'n';
options.tag = 'knee_angle_l';  
compareResults(options)
load compResults.mat
data.IK.KneeFlexionL = compResults;

% hip kinematics
options.mirror = 'n';
options.removeOffset = 'no';
options.stitchData = 'y';
options.tag = 'hip_flexion_r';  
compareResults(options)
load compResults.mat
data.IK.HipFlexionR = compResults;
options.removeOffset = 'no';
options.stitchData = 'n'; 
options.tag = 'hip_flexion_l';  
compareResults(options)
load compResults.mat
data.IK.HipFlexionL = compResults;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ID
options.datasets{1} = 'IDResults\Rigid_SR2\';
options.datasets{2} = 'IDResults\4DOF_SR2\';
% load frames.mat
options.frames{1} = frames;
options.frames{2} = frames;
options.label{1} = 'Rigid';
options.label{2} = '4-DOF';
options.filter = 20;  % filter window size
options.outputLevel = 1; 
options.dataType = 'ID';         
options.stitchData = 'n';
options.norm2mass = 'y';
options.subjectMass{1} = 104.3;
options.subjectMass{2} = 104.3;

% % socket dynamics
% options.removeOffset = 'no';
% options.stitchData = 'n';
% options.tag = 'socket_flexion_moment'; 
% compareResults(options)
% load compResults.mat
% data.ID.SocketFlexMom = compResults;
% options.removeOffset = 'no';
% options.stitchData = 'n';
% options.tag = 'socket_ty_force'; 
% compareResults(options)
% load compResults.mat
% data.ID.SocketPistF = compResults;

% ankle and foot prosthesis dynamics
options.mirror = 'y';
options.removeOffset = 'no';
options.stitchData = 'y';
options.tag = 'ankle_angle_r_moment';
compareResults(options)
load compResults.mat
data.ID.AnkleFlexMom = compResults;
options.removeOffset = 'no';
options.stitchData = 'n';
options.tag = 'foot_flex_moment';  
compareResults(options)
load compResults.mat
data.ID.ProsFootFlexMom = compResults;

% knee dynamics
options.mirror = 'n';
options.removeOffset = 'no';
options.stitchData = 'y';
options.tag = 'knee_angle_r_moment';  
compareResults(options)
load compResults.mat
data.ID.KneeFlexMomR = compResults;
options.removeOffset = 'no';
options.stitchData = 'n'; 
options.tag = 'knee_angle_l_moment';  
compareResults(options)
load compResults.mat
data.ID.KneeFlexMomL = compResults;

% hip dynamics
options.mirror = 'y';
options.removeOffset = 'no';
options.stitchData = 'y';
options.tag = 'hip_flexion_r_moment';  
load compResults.mat
data.ID.HipFlexionMomR = compResults;
compareResults(options)
options.removeOffset = 'no';
options.stitchData = 'n'; 
options.tag = 'hip_flexion_l_moment';  
compareResults(options)
load compResults.mat
data.ID.HipFlexionMomL = compResults;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % power
% options.datasets{1} = 'POW\Passive\';
% options.datasets{2} = 'POW\Active2\';
% load frames.mat
% options.frames{1} = frames.passive;
% options.frames{2} = frames.active2;
% options.label{1} = 'Passive Pref AutoScaled';
% options.label{2} = 'Active Pref AutoScaled';
% options.filter = 10;  
% options.outputLevel = 1; 
% options.dataType = 'POW';        
% options.stitchData = 'n';
% options.subjectMass{1} = 73.16;
% options.subjectMass{2} = 74.28;
% options.norm2mass = 'yes';
% 
% % socket power
% options.removeOffset = 'no';
% options.stitchData = 'y';
% options.tag = 'socket_flexion_power';
% compareResults(options)
% load compResults.mat
% data.POW.SocketFlexPow = compResults;
% options.removeOffset = 'no';
% options.stitchData = 'n';
% options.tag = 'socket_ty_power';  
% compareResults(options)
% load compResults.mat
% data.POW.SocketPistPow = compResults;
% 
% % ankle and foot prosthesis power
% options.removeOffset = 'no';
% options.stitchData = 'y';
% options.tag = 'ankle_angle_r_power';
% compareResults(options)
% load compResults.mat
% data.POW.AnklePow = compResults;
% options.removeOffset = 'no';
% options.stitchData = 'n';
% options.tag = 'foot_flex_power';  
% compareResults(options)
% load compResults.mat
% data.POW.ProsFootPow = compResults;
% 
% % knee power
% options.removeOffset = 'no';
% options.stitchData = 'y';
% options.tag = 'knee_angle_r_power';  
% compareResults(options)
% load compResults.mat
% data.POW.KneePowR = compResults;
% options.removeOffset = 'no';
% options.stitchData = 'n'; 
% options.tag = 'knee_angle_l_power';  
% compareResults(options)
% load compResults.mat
% data.POW.KneePowL = compResults;
% 
% % hip power
% options.removeOffset = 'no';
% options.stitchData = 'y';
% options.tag = 'hip_flexion_r_power';  
% compareResults(options)
% load compResults.mat
% data.POW.HipPowR = compResults;
% options.removeOffset = 'no';
% options.stitchData = 'n'; 
% options.tag = 'hip_flexion_l_power';  
% compareResults(options)
% load compResults.mat
% data.POW.HipPowL = compResults;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% COM
% options.datasets{1} = 'Analyses\Results\Passive\';
% options.datasets{2} = 'Analyses\Results\Active2\';
% options.filter = 5;  
% options.outputLevel = 1;
% options.dataType = 'COM';        
% options.stitchData = 'n';
% options.norm2mass = 'no';
% options.zeroCOM = 'yes';
% 
% % torso and combined
% options.tag = 'torso_Y'; 
% compareResults(options)
% load compResults.mat
% data.COM.TorsoCOM = compResults;
% options.tag = 'center_of_mass_Y'; 
% compareResults(options)
% load compResults.mat
% data.COM.CombinedCOM = compResults;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% pressure 
% load pressureData.mat
% data.Pressure = pressure;
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GRF
load combinedGRF.mat
data.GRF = GRFdata;


%%
save A07_Data_Complete.mat data

%% load subject data
clear all
close all
clc

load A01_Data_Complete.mat

%% WB grid plot
% left and right overlaid, no SD bounds
% put peaks and SD in table
clc
close all

stance = 0:1:100;

figure('OuterPosition',[20 20 1500 850])
% ankle/foot IK
subplot(2,3,1)
hold on
plot(stance,data.IK.ProsFootFlex{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.IK.AnkleFlex{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.IK.ProsFootFlex{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.IK.AnkleFlex{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
title('Ankle/Prosthetic Foot', 'FontSize',20)
ylabel('Angle (deg)', 'FontSize',18)
% knee IK
subplot(2,3,2)
hold on
plot(stance,data.IK.KneeFlexionL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.IK.KneeFlexionR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.IK.KneeFlexionL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.IK.KneeFlexionR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
title('Knee', 'FontSize',20)
% hip IK
subplot(2,3,3)
hold on
plot(stance,data.IK.HipFlexionL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.IK.HipFlexionR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.IK.HipFlexionL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.IK.HipFlexionR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
title('Hip', 'FontSize',20)

% ankle/foot ID
subplot(2,3,4)
hold on
plot(stance,data.ID.ProsFootFlexMom{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.ID.AnkleFlexMom{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.ID.ProsFootFlexMom{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.ID.AnkleFlexMom{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
ylabel('Moment (N-m/kg)', 'FontSize',18)
% knee ID
subplot(2,3,5)
hold on
plot(stance,data.ID.KneeFlexMomL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.ID.KneeFlexMomR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.ID.KneeFlexMomL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.ID.KneeFlexMomR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
% hip ID
subplot(2,3,6)
hold on
plot(stance,data.ID.HipFlexionMomL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
plot(stance,data.ID.HipFlexionMomR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
plot(stance,data.ID.HipFlexionMomL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
plot(stance,data.ID.HipFlexionMomR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
legend('ESR Rigid','Intact Rigid','ESR 4-DOF','Intact 4-DOF','Location','northeast')

% % ankle/foot POW
% subplot(3,3,7)
% hold on
% plot(stance,-data.POW.ProsFootPow{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,-data.POW.AnklePow{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
% plot(stance,-data.POW.ProsFootPow{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% plot(stance,-data.POW.AnklePow{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
% ylabel('Power (W/kg)', 'FontSize',18)
% legend('ESR','Intact ESR','AAP','Intact AAP','Location','northwest')
% % knee POW
% subplot(3,3,8)
% hold on
% plot(stance,-data.POW.KneePowL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,-data.POW.KneePowR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
% plot(stance,-data.POW.KneePowL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% plot(stance,-data.POW.KneePowR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
% % hip POW
% subplot(3,3,9)
% hold on
% plot(stance,-data.POW.HipPowL{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,-data.POW.HipPowR{2,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5],'LineStyle',':')
% plot(stance,-data.POW.HipPowL{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% plot(stance,-data.POW.HipPowR{3,3}(:,1),'LineWidth',3,'Color',[0.5, 0.5, 0.5])
% %% socket grid plot
% clc
% close all
% 
% stance = 0:1:100;
% 
% figure('OuterPosition',[20 20 1500 850])
% % socket flexion IK
% subplot(3,2,1)
% hold on
% plot(stance,data.IK.SocketFlex{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.IK.SocketFlex{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% title('Socket Flexion', 'FontSize',20)
% ylabel('Angle (deg)', 'FontSize',18)
% % socket pistoning IK
% subplot(3,2,2)
% hold on
% plot(stance,data.IK.SocketPist{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.IK.SocketPist{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% title('Socket Pistoning', 'FontSize',20)
% ylabel('Translation (m)', 'FontSize',18)
% 
% % socket flexion ID
% subplot(3,2,3)
% hold on
% plot(stance,data.ID.SocketFlexMom{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.ID.SocketFlexMom{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Moment (N-m/kg)', 'FontSize',18)
% % socket pistoning ID
% subplot(3,2,4)
% hold on
% plot(stance,data.ID.SocketPistF{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.ID.SocketPistF{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Force (N/kg)', 'FontSize',18)
% 
% % socket flexion POW
% subplot(3,2,5)
% hold on
% plot(stance,-data.POW.SocketFlexPow{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,-data.POW.SocketFlexPow{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Power (W/kg)', 'FontSize',18)
% legend('ESR','AAP','Location','southeast')
% % socket pistoning ID
% subplot(3,2,6)
% hold on
% plot(stance,-data.POW.SocketPistPow{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,-data.POW.SocketPistPow{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Power (W/kg)', 'FontSize',18)
% 
% %% COM plot
% 
% close all
% 
% % Torso
% figure('OuterPosition',[20 20 1500 850])
% hold on
% plot(stance,data.COM.TorsoCOM{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.COM.TorsoCOM{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Y Coordinate (m)', 'FontSize',18)
% title('Torso COM trajectory', 'FontSize',20)
% legend('ESR','AAP','Location','northeast')
% 
% figure('OuterPosition',[20 20 1500 850])
% hold on
% plot(stance,data.COM.CombinedCOM{2,3}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.COM.CombinedCOM{3,3}(:,1),'LineWidth',3,'Color',[0 0 0])
% ylabel('Y Coordinate (m)', 'FontSize',18)
% title('Combined COM trajectory', 'FontSize',20)
% legend('ESR','AAP','Location','northeast')


%% GRF grid plot
stance = 0:1:100;

figure('OuterPosition',[20 20 1500 850])

subplot(2,2,1)
hold on
plot(stance,data.GRF{2,5}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.GRF{3,5}(:,1),'LineWidth',3,'Color',[0 0 0])
title('Left', 'FontSize',20)
ylabel('Vertical GRF (N/kg)', 'FontSize',18)
subplot(2,2,2)
hold on
plot(stance,data.GRF{2,9}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.GRF{3,9}(:,1),'LineWidth',3,'Color',[0 0 0])
title('Right', 'FontSize',20)
legend('ESR','AAP','Location','northeast')

subplot(2,2,3)
hold on
plot(stance,data.GRF{2,4}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.GRF{3,4}(:,1),'LineWidth',3,'Color',[0 0 0])
ylabel('Horizontal GRF (N/kg)', 'FontSize',18)
subplot(2,2,4)
hold on
plot(stance,data.GRF{2,8}(:,1),'LineWidth',3,'Color',[0 0 0],'LineStyle',':')
% plot(stance,data.GRF{3,8}(:,1),'LineWidth',3,'Color',[0 0 0])



