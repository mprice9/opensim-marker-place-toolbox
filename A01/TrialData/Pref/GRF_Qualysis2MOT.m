% -------------------------------------------------------------------------
% Qualysis GRF file (.tsv files) to .mot file structure.
% convert Qualysis output file (UMass Dept. of Kin Locomotion Lab) structure 
% to a .MOT file structure for input into OpenSIM.
% one input is required: (1) Five .tsv data files(Output from Qualysis)
%
% Note: There are 5 five force plates in the lab, which results in 5 ground
% reaction force output files. The output files from Qualysis already put
% the data in Lab Reference frame. However, it creates 5 separate ground
% reaction files that we need to consolidate into a two column GRF files
% (one column for each leg, not necessary but will help in setting up OpenSim 
% Inverse Dynamic analysis).
% 
% Created by: Leng-Feng Lee (contact: lengfenglee@gmail.com)
% University of Massachusetts Amherst, Dept. of Kinesiology.
% Copyright 2012.
% Date: Nov.2012.
% -------------------------------------------------------------------------

close all
clear all
clc

% Select the force plates for Left leg and Right leg (Total 5 force plates)
Left_plate = [0,1,0,0,0]; %plate 2 belong to left leg

% MOT file output filename:
% mot_filename = 'A01_T0015_GRF'
mot_filename = 'A01_T0017_GRF'
% mot_filename = 'A01_T0018_GRF'

f_cut = 5; % cut off force at 5N

%% The starting and ending time heel strike and toe off on each plate (Can read-in from file):
% % A01, Trial 0015.
% plate_cut_t = [.620, 4;       % plate 1 heel strike and toe off
%                0, .739;    % plate 2 heel strike and toe off
%                0, .22;    % plate 3 heel strike and toe off
%                4, 4;           % plate 4 heel strike and toe off
%                4, 4];          % plate 5 heel strike and toe off

% A01, Trial 0017.
plate_cut_t = [.601, 4;       % plate 1 heel strike and toe off
               0, .72;    % plate 2 heel strike and toe off
               0, .197;    % plate 3 heel strike and toe off
               4, 4;           % plate 4 heel strike and toe off
               4, 4];          % plate 5 heel strike and toe off
           
% % A01, Trial 0018.
% plate_cut_t = [.594, 4;       % plate 1 heel strike and toe off
%                0, .724;    % plate 2 heel strike and toe off
%                0, .208;    % plate 3 heel strike and toe off
%                4, 4;           % plate 4 heel strike and toe off
%                4, 4];          % plate 5 heel strike and toe off

           

% [filename,pathname] = uigetfile('*.tsv','Pick a ProAnalyst file to load.');
[file_input, pathname] = uigetfile( ...
{'*.tsv', 'Qualysis GRF Files (*.tsv)'},'Select files','MultiSelect', 'on');

%% Extract the XYZ forces, moments, & COP (ignore the first 24 columns)
% grfdata_raw = dlmread(filename,'\t',24,0); %Contain only Fx,Fy,Fz,Mx,My,Mz,COPx,COPy,COPz from 5 force plates, total 9 columns.
for i = 1:length(file_input),
    temp = dlmread(file_input{i},'\t',24,0); %Contain only Fx,Fy,Fz,Mx,My,Mz,COPx,COPy,COPz from 5 force plates, total 9 columns.
    grfdata_raw(:,9*(i-1)+1:9*(i-1)+9) = temp(:,1:9);
    fid = fopen(strcat(pathname,file_input{i}));
    c=textscan(fid,'%s%f',12,'Headerlines',9); 
    plate_corner(:,i) =c{1,2}; %Grab all the plate corner values.
    fclose(fid);
end

% get file info
freq = 2400; %Hz, from Qualisys

% Filtering the data:
% butterworth filter the data at 60 Hz
% [ b,a ] = butter(4, 2*60/freq, 'low'); % NEED TO VERIFY
% [ grf_raw ] = filtfilt(b,a,grfdata_raw); %Filtered GRF data.
grf_raw = grfdata_raw; %No Filtered GRF data.

% Calculate the total time:
frame = length(grf_raw);
time = frame/freq;    
num_plate = length(file_input); % # of force plates
% time = frame/1500;

%create the time stamp (used in MOT file)
t_old = linspace(0,time,frame)';

% -------------------------------------------------------------------------
% Plot the force plate locations, expressed in Lab reference frame (L}.
% Read from .tsv file directly.
% -------------------------------------------------------------------------
fig=figure(16);
    set(gcf,'Position',[50,50, 480,960]);set(fig,'color','w');
for i = 1:num_plate,
    platex = [plate_corner(1,i),plate_corner(4,i),plate_corner(7,i),plate_corner(10,i)];
    platey = [plate_corner(2,i),plate_corner(5,i),plate_corner(8,i),plate_corner(11,i)];
    platez = [plate_corner(3,i),plate_corner(6,i),plate_corner(9,i),plate_corner(12,i)];
    center(i,1) = mean(platex);
    center(i,2) = mean(platey);
    center(i,3) = mean(platez);
    fill(platex,platey,platez); hold on
    plot3(center(i,1),center(i,2),center(i,3),'*');
    plot(0,0,'o');
    text(center(i,1),center(i,2),center(i,3),strcat('Plate #',num2str(i)));
    axis equal
    axis([-300, 900, -1500, 2500]);
end
    
% -------------------------------------------------------------------------
% The resulting GRF from each plate(Shows that the columns in txt file
% corresponding to the correct axis).
for i = 1:length(file_input),
    fig = figure(i);
    set(gcf,'Position',[50,50, 480,960]);set(fig,'color','w');
    subplot(3,1,1)
    plot(t_old,grf_raw(:,9*(i-1)+1:9*(i-1)+3));
    legend('F_x','F_y','F_z');
    axis([0 time -inf inf])
    ylabel('Forces (N)');
    xlabel('Time, (sec)');
    title(strcat('Plate ', num2str(i), ' Ground Reaction Forces {Lab Reference Frame}'))
    subplot(3,1,2)
    plot(t_old,grf_raw(:,9*(i-1)+4:9*(i-1)+6))
    legend('M_x','M_y','M_z');
    axis([0 time -inf inf])
    ylabel('Moment (N mm)');
    xlabel('Time, (sec)');
    title(strcat('Plate ', num2str(i), ' Ground Reaction Moments {Lab Reference Frame}'))
    subplot(3,1,3)
    plot(t_old,grf_raw(:,9*(i-1)+7:9*(i-1)+9))
%    plot(grf_raw(:,9*(i-1)+7),grf_raw(:,9*(i-1)+8),'*'); hold on
    legend('COP_x','COP_y','COP_z');
%     axis([0 time -inf inf])
    ylabel('COP (mm)');
    xlabel('Time, (sec)');
%     xlabel('COP_x (mm)');
    title(strcat('Plate ', num2str(i), ' Ground Reaction COP {Lab Reference Frame}'))
end


%% Input Data from Qualysis is as follow
% input as: Fz,Fx,Fy; Mz,Mx,My, COP_x, COP_y, COP_z (zeroes not read in)

    %Fz = vertical
    %Fx = mediolateral
    %Fy = fore-aft

% assign forces and moments to individual plates plate1=A, plate2=B, plate3=C, plate4=D
% the southwest corner is the location of the COP [0,0] when using the equations below
%
%    ___    Human travel direction.  Force Plate reference frame {F}:
%   | 3 |   ||                      (Z pointing in)(x)----> X 
%   |.__|   ||                                      |
%    ___    \/                                      |
%   | 2 |                                           v
%   |.__|                                           Y
%    ___o  <--- Origin of GRF Coordinate. {F'} same as {F}, but translated here. 
%   |   |          
%   | 1 |    
%   |.__|   Lab reference frame {L}:        OpenSim reference frame {O}: 
%    ___          
%   | 4 |  X <----(.) Z (z pointing out)    Z <----(.) Y (Y pointing out) 
%   |.__|          |                                |  
%    ___           |                                |  
%   | 5 |          v                                v         
%   |.__|          Y                                X
%    

%% Convert from Lab Frame of reference to OpenSim Frame of Reference.

for i = 1:num_plate,
    
    %Forces convert from {F} -> {F'} -> {L} -> {OpemSim} frame:
    tempFx = -grf_raw(:,9*(i-1)+1); %Fx [N], translated from {F'} to {L} frame.
    tempFy =  grf_raw(:,9*(i-1)+2); %Fy [N], translated from {F'} to {L} frame.
    tempFz = -grf_raw(:,9*(i-1)+3); %Fz [N], translated from {F'} to {L} frame.
    
    grf(:,6*(i-1)+1) = tempFy; %Fx [N], converted from {L} to {OpenSim} frame.
    grf(:,6*(i-1)+2) = tempFz; %Fy [N], converted from {L} to {OpenSim} frame.
    grf(:,6*(i-1)+3) = tempFx; %Fz [N], converted from {L} to {OpenSim} frame.

    %Moments convert from {F} -> {F'} -> {L} -> {OpemSim} frame:
    tempMx = -grf_raw(:,9*(i-1)+4); %Mx [N], translated from {F'} to {L} frame.
    tempMy =  grf_raw(:,9*(i-1)+5); %My [N], translated from {F'} to {L} frame.
    tempMz = -grf_raw(:,9*(i-1)+6); %Mz [N], translated from {F'} to {L} frame.

    grf(:,6*(i-1)+4) = grf_raw(:,9*(i-1)+5); % Mx [N m], converted to OpenSim frame, Mx should be zeros.
    grf(:,6*(i-1)+5) = grf_raw(:,9*(i-1)+6); % My [N m], converted to OpenSim frame, My should have value.
    grf(:,6*(i-1)+6) = grf_raw(:,9*(i-1)+4); % Mz [N m], converted to OpenSim frame, Mz should be zeros.

    % Center of pressure convert from {F} -> {F'} -> {L} -> {OpemSim} frame:
    % First convert to lab frame {L}, followed by translation in {L} frame 
    % as plate centers are expressed in {L} frame. 
    tempPx = -grf_raw(:,9*(i-1)+7)+center(i,1);  %Px [N], translated from {F} to {F'} to {L} frame.
    tempPy =  grf_raw(:,9*(i-1)+8)+center(i,2);  %Py [N], translated from {F} to {F'} to {L} frame.
    tempPz = -grf_raw(:,9*(i-1)+9)+center(i,3);  %Pz [N], translated from {F} to {F'} to {L} frame.

    copx = tempPy;                  %COP-x [mm], converted from {L} to {OpenSim} frame.
    copy = zeros(length(tempPz),1); %COP-y [mm], converted from {L} to {OpenSim}, COPy should be zeros.
    copz = tempPx;                  %COP-z [mm], converted from {L} to {OpenSim} frame.

    COP(:,3*(i-1)+1:3*(i-1)+3) = [copx copy copz];
end
    

%% ------------------------------------------------------------------------
% Cleaning up the data: removed data noise + set everything else outside 
% heel strike and toe off = 0 for plate A and B; and plate C and D

% ** Remember grf() is in Fx,Fy,Fz sequence
% Get the average noise value by averaging first or last 100 points of the
% z-direction force (vertical).
% -------------------------------------------------------------------------
grf_clear = grf; %assigning values
for i = 1:num_plate,
    if (max(grf(1:25,6*(i-1)+3)) <= 5) % if the max of first 25 Fz ptns is less than threshold 5N
        noise_Fx = mean(grf(1:25,6*(i-1)+1));
        noise_Fy = mean(grf(1:25,6*(i-1)+2));
        noise_Fz = mean(grf(1:25,6*(i-1)+3));
        noise_Mx = mean(grf(1:25,6*(i-1)+4));
        noise_My = mean(grf(1:25,6*(i-1)+5));
        noise_Mz = mean(grf(1:25,6*(i-1)+6));
    elseif max(grf(end-25:end,6*(i-1)+3) <= 5) % if the max of first 25 Fz ptns is less than threshold 5N
        noise_Fx = mean(grf(end-25:end,6*(i-1)+1));
        noise_Fy = mean(grf(end-25:end,6*(i-1)+2));
        noise_Fz = mean(grf(end-25:end,6*(i-1)+3));
        noise_Mx = mean(grf(end-25:end,6*(i-1)+4));
        noise_My = mean(grf(end-25:end,6*(i-1)+5));
        noise_Mz = mean(grf(end-25:end,6*(i-1)+6));
    else
        disp('we got a problem here, cant remove signal base noise on plate');
        disp(i);
        noise_Fx = 0; noise_Fy = 0; noise_Fz = 0;
        noise_Mx = 0; noise_My = 0; noise_Mz = 0;        
    end
    grf_clear(:,6*(i-1)+1) = grf(:,6*(i-1)+1) - noise_Fx; %remove base signal noise
    grf_clear(:,6*(i-1)+2) = grf(:,6*(i-1)+2) - noise_Fy; %remove base signal noise
    grf_clear(:,6*(i-1)+3) = grf(:,6*(i-1)+3) - noise_Fz; %remove base signal noise
    grf_clear(:,6*(i-1)+4) = grf(:,6*(i-1)+4) - noise_Mx; %remove base signal noise
    grf_clear(:,6*(i-1)+5) = grf(:,6*(i-1)+5) - noise_My; %remove base signal noise
    grf_clear(:,6*(i-1)+6) = grf(:,6*(i-1)+6) - noise_Mz; %remove base signal noise
end
    
           
grf_clean = grf_clear;
for i = 1:num_plate, % Number of plates
for j = 1:length(grf(:,1)), % going through each row
    if t_old(j) <= plate_cut_t(i,1) || t_old(j) >= plate_cut_t(i,2),
        grf_clean(j,6*(i-1)+1:6*(i-1)+3) = [0 0 0]; %Replace them with zeros (forces) in OpenSim Frame
        grf_clean(j,6*(i-1)+4:6*(i-1)+6) = [0 0 0]; %Replace them with zeros (moments) in OpenSim Frame
        COP_clean(j,3*(i-1)+1:3*(i-1)+3) = [0 0 0]; %Replace them with zeros (moments) in OpenSim Frame
    else
        grf_clean(j,6*(i-1)+1:6*(i-1)+3) = grf_clear(j,6*(i-1)+1:6*(i-1)+3); % Fz, Fx, Fy in OpenSim Frame
        grf_clean(j,6*(i-1)+4:6*(i-1)+6) = grf_clear(j,6*(i-1)+4:6*(i-1)+6); % Mz, Mx, My in OpenSim Frame
        COP_clean(j,3*(i-1)+1:3*(i-1)+3) = COP(j,3*(i-1)+1:3*(i-1)+3);
    end
end
end

%% ------------------------------------------------------------------------
% Place the data in the correct orientation; the system coordinate in PA and OpenSim differ.
% output as: Fx,Fy,Fz; Mx,My,Mz

%Fx = force-aft
%Fy = vertical
%Fz = mediolateral

for i = 1:num_plate, %1,2,3,4,5
    % ------- Ground Reaction forces -------
    tempx = grf_clean(:,6*(i-1)+1); % in OpenSim frame 
    tempy = grf_clean(:,6*(i-1)+2); % in OpenSim frame
    tempz = grf_clean(:,6*(i-1)+3); % in OpenSim frame
    
    % Fill in 1-3,7-9,13-15,19-21:
    grf_new(:,6*(i-1)+1:6*(i-1)+3) = -[tempx,tempy,tempz]; % in OpenSim Frame, flipped to reaction force

    % ------- Center of Pressures (COP) -------
    tempPx = COP_clean(:,3*(i-1)+1)/1000;  %Convert mm (Qualysis) to meter, m (used in OpenSim)
    tempPy = zeros(length(COP_clean),1);   %Convert mm (Qualysis) to meter, m (used in OpenSim), COPy should be zeros.
    tempPz = COP_clean(:,3*(i-1)+3)/1000;  %Convert mm (Qualysis) to meter, m (used in OpenSim)
    
    % Fill in 4-6,10-12,16-18,22-24, 
    for j = 1:length(tempPx), %only fill out the COP where there are GRF values.
        if tempPx(j) ~= 0,
            grf_new(j,6*(i-1)+4:6*(i-1)+6) = [tempPx(j),tempPy(j),tempPz(j)]; %COP in OpenSim Frame (in meters, m)
        else
            grf_new(j,6*(i-1)+4:6*(i-1)+6) = [0 0 0]; %COP, OpenSim mot file can't read NaN.
        end
    end

    % -------- Ground Torques  ----------- 
    tempTx = grf_clean(:,6*(i-1)+4)*0;  % in OpenSim frame, Mx should be zeros.
    tempTy = grf_clean(:,6*(i-1)+5);    % in OpenSim frame, My should have value.
    tempTz = grf_clean(:,6*(i-1)+6)*0;  % in OpenSim frame, Mz should be zeros.
    
    % Fill in 1-3,4-6,7-9,10-12:
    mom_new(:,3*(i-1)+1:3*(i-1)+3) = -[tempTx,tempTy,tempTz]; % in OpenSim Frame, flipped to reaction moment

end

%% --------- Combining data from plate 1,3,5; and plate 2 and 4.-----------
grf_comb_L = zeros(length(grf(:,1)),6);
grf_comb_R = zeros(length(grf(:,1)),6);
mom_comb_L = zeros(length(grf(:,1)),3);
mom_comb_R = zeros(length(grf(:,1)),3);

for i = 1:num_plate,

    if Left_plate(i) == 1,
        grf_comb_L = grf_comb_L + grf_new(:,6*(i-1)+1:6*(i-1)+6);  % plate 1 + plate 3 + plate 5
        mom_comb_L = mom_comb_L + mom_new(:,3*(i-1)+1:3*(i-1)+3);  % plate 1 + plate 3 + plate 5
    else
        grf_comb_R = grf_comb_R + grf_new(:,6*(i-1)+1:6*(i-1)+6);   % plate 2 + plate 4
        mom_comb_R = mom_comb_R + mom_new(:,3*(i-1)+1:3*(i-1)+3);
    end

end

grf_comb = [grf_comb_L, grf_comb_R];
mom_comb = [mom_comb_L, mom_comb_R];

Combine_file = 1; %1 for yes, 0 for no


% %% --------- Down sampling the data ---------------------------------------
% if Combine_file == 0,
%     grf_down = grf_new(1:10:end-1,:); %Down sampling the data (Since marker data recorded at 150Hz, GRF recorded at 1500Hz)
%                                       %Still in volts.
%     mom_down = mom_new(1:10:end-1,:); 
%     disp('4 Force plate data will not be combined');
% elseif Combine_file == 1,
%     grf_down = grf_comb(1:10:end-1,:); %Down sampling the data (Since marker data recorded at 150Hz, GRF recorded at 1500Hz)
%                                      %Still in volts.
%     mom_down = mom_comb(1:10:end-1,:);              
%     disp('4 Force plate data will be combined into 2 (Left and Right)');
% else
%     disp('Please indicate if you want to combine the force plate data');
% end
% 
% % Calculate the new total time:
% frame = length(grf_down);
% % time = frame/freq;    
% time = frame/150 - 1/150;

%create the time stamp (used in MOT file)
t = linspace(0,time,frame)';

%% Data to be written to mot file. [time, grf1, COP1,...,grf4, COP4,moment1,...,moment4]
% DATA = [t, grf_new, mom_new];   % Keep all data in 5 plates
grf_down = grf_comb; mom_down =mom_comb; % Combined data to 2 plates
DATA = [t, grf_down, mom_down]; % Down sampling if needed

%Create a new mot file of the same name
if Combine_file == 1,
    mot_filename = [mot_filename '_2plates.mot'];
    %create column labels (Need more work as only two column allowed)
    labels = {
        'time'...
        'ground_force_vx','ground_force_vy','ground_force_vz','ground_force_px','ground_force_py','ground_force_pz'...
        '1_ground_force_vx','1_ground_force_vy','1_ground_force_vz','1_ground_force_px','1_ground_force_py','1_ground_force_pz'...
        'ground_torque_x','ground_torque_y','ground_torque_z',...
        '1_ground_torque_x','1_ground_torque_y','1_ground_torque_z'...
        };
elseif Combine_file == 0,
    mot_filename = [mot_filename '_5plates.mot'];
    labels = {
        'time'...
        '1_ground_force_vx','1_ground_force_vy','1_ground_force_vz','1_ground_force_px','1_ground_force_py','1_ground_force_pz',...
        '2_ground_force_vx','2_ground_force_vy','2_ground_force_vz','2_ground_force_px','2_ground_force_py','2_ground_force_pz',...    
        '3_ground_force_vx','3_ground_force_vy','3_ground_force_vz','3_ground_force_px','3_ground_force_py','3_ground_force_pz',...
        '4_ground_force_vx','4_ground_force_vy','4_ground_force_vz','4_ground_force_px','4_ground_force_py','4_ground_force_pz',...
        '5_ground_force_vx','5_ground_force_vy','5_ground_force_vz','5_ground_force_px','5_ground_force_py','5_ground_force_pz',...
        '1_ground_torque_x','1_ground_torque_y','1_ground_torque_z',...
        '2_ground_torque_x','2_ground_torque_y','2_ground_torque_z',...
        '3_ground_torque_x','3_ground_torque_y','3_ground_torque_z',...
        '4_ground_torque_x','4_ground_torque_y','4_ground_torque_z',...
        '5_ground_torque_x','5_ground_torque_y','5_ground_torque_z',...
        };
else
    disp('Please indicate if you want to combine the force plate data');
    mot_filename = [mot_filename '_MakeSelection.mot'];
end

%Build .mot file structure
fid = fopen(mot_filename,'w');

%Print the first four rows
%all in column 1
fprintf(fid,'%s\n', mot_filename);
fprintf(fid,'%s\n','version=1');
fprintf(fid,'%s%d\n','nRows=',size(grf_down,1));
fprintf(fid,'%s%d\n','nColumns=',size(grf_down,2)+size(mom_down,2)+1);
% fprintf(fid,'%s %f %f\n','range',t(1),t(end));
fprintf(fid,'%s\n','inDegrees=yes');
fprintf(fid,'%s\n','endheader');

%Print the column labels:
for i = 1:length(labels)
    texts = labels(i);
    fprintf(fid,'%s\t',char(texts) );
end

%End labels, start the data matrix 
fprintf(fid,'\n');
fclose(fid); 

%Write the matrix data to the file:
dlmwrite(mot_filename, DATA,'-append','delimiter','\t','newline','pc');

% ---------------------- DONE PROCESSING THE DATA -------------------------

disp('MOT File successfully created!');


%% 

% Plot GRF directions each component against 
% fig = figure(7);
% set(fig,'color','w');
% subplot(3,1,1)

%% The resulting GRF in OpenSim coordinate system:
fig = figure(6);
set(gcf,'Position',[50,50,480, 960]);set(fig,'color','w');
subplot(5,1,1)
plot(t_old,grf(:,13:15)); %Plate #3
vline(plate_cut_t(3,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 3 - GRF3, in OpenSim Frame')

subplot(5,1,2)
plot(t_old,grf(:,7:9)); %Plate #2
vline(plate_cut_t(2,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 2 - GRF3, in OpenSim Frame')

subplot(5,1,3)
plot(t_old,grf(:,1:3)); %Plate #1
vline(plate_cut_t(1,:));
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 1 - GRF3, in OpenSim Frame')

subplot(5,1,4)
plot(t_old,grf(:,19:21));
vline(plate_cut_t(4,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 4 - GRF3, in OpenSim Frame')

subplot(5,1,5)
plot(t_old,grf(:,25:27));
vline(plate_cut_t(5,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 5 - GRF3, in OpenSim Frame')

%% The resulting clear GRF (Removed Average Noise) in OpenSim coordinate system:
fig = figure(7);
set(gcf,'Position',[50,50,480, 960]);set(fig,'color','w');
subplot(5,1,1)
plot(t_old,grf_clear(:,13:15)); %Plate #3
vline(plate_cut_t(3,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 3 - GRF3, in OpenSim Frame')

subplot(5,1,2)
plot(t_old,grf_clear(:,7:9)); %Plate #2
vline(plate_cut_t(2,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 2 - GRF3, in OpenSim Frame')

subplot(5,1,3)
plot(t_old,grf_clear(:,1:3)); %Plate #1
vline(plate_cut_t(1,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 1 - GRF3, in OpenSim Frame')

subplot(5,1,4)
plot(t_old,grf_clear(:,19:21));
vline(plate_cut_t(4,:));
hline(f_cut)
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 4 - GRF3, in OpenSim Frame')

subplot(5,1,5)
plot(t_old,grf_clear(:,25:27));
hline(f_cut)
vline(plate_cut_t(5,:));
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 5 - GRF3, in OpenSim Frame')

%% The resulting clean GRF (Zero out) in OpenSim coordinate system:
fig = figure(8);
set(gcf,'Position',[50,50,480, 960]);set(fig,'color','w');
subplot(5,1,1)
plot(t_old,grf_clean(:,13:15)); %Plate #3
vline(plate_cut_t(3,:));
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 3 - GRF3, in OpenSim Frame')

subplot(5,1,2)
plot(t_old,grf_clean(:,7:9)); %Plate #2
vline(plate_cut_t(2,:));
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 2 - GRF3, in OpenSim Frame')

subplot(5,1,3)
plot(t_old,grf_clean(:,1:3)); %Plate #1
vline(plate_cut_t(1,:));
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 1 - GRF3, in OpenSim Frame')

subplot(5,1,4)
plot(t_old,grf_clean(:,19:21));
vline(plate_cut_t(4,:));
legend('x','y','z');
axis([0 time -inf inf]);
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 4 - GRF3, in OpenSim Frame')

subplot(5,1,5)
plot(t_old,grf_clean(:,25:27));
vline(plate_cut_t(5,:));
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
% xlabel('Time, (sec)');
title('Plate 5 - GRF3, in OpenSim Frame')

%% Combining the GRF into two plates (OpenSim Frame)
fig = figure(9);
set(fig,'color','w');
set(gcf,'Position',[50,50, 860,480]);
subplot(1,2,1)
plot(t_old,grf_comb(:,1:3));
vline(plate_cut_t(2,:));
vline(plate_cut_t(4,:));
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
xlabel('Time, (sec)');
title('plate 1, 3, & 5 (LEFT Side)- GRF')

subplot(1,2,2)
plot(t_old,grf_comb(:,7:9))
vline(plate_cut_t(1,:));
vline(plate_cut_t(3,:));
legend('x','y','z');
axis([0 time -inf inf])
ylabel('Force (N)');
xlabel('Time, (sec)');
title('plate 1 & 2 (RIGHT Side) - GRF')

%% Combining the Ground Reaction Moment into two plates (OpenSim Frame)
fig = figure(10);
set(fig,'color','w');
set(gcf,'Position',[50,50, 860,480]);
subplot(1,2,1)
plot(t_old,mom_comb_L);
vline(plate_cut_t(2,:));
vline(plate_cut_t(4,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('plate A & B (LEFT Side)- Moment (OpenSim Frame)')

subplot(1,2,2)
plot(t_old,mom_comb_R)
vline(plate_cut_t(1,:));
vline(plate_cut_t(3,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('plate C & D (RIGHT Side) - Moment (OpenSim Frame)')


%%
% Check the COP positions on plates A,B,C,D
fig = figure(11);
set(fig,'color','w');
set(gcf,'Position',[50,50, 720,640]);
% plot(grf_new(:,4),grf_new(:,5),grf_new(:,6),'*k'); hold on
% plot(grf_new(:,10),grf_new(:,11),grf_new(:,12),'*r');
% plot(grf_new(:,16),grf_new(:,17),grf_new(:,18),'*b');
% plot(grf_new(:,22),grf_new(:,23),grf_new(:,24),'*g');
plot(grf_new(:,16),grf_new(:,18),'*b');hold on %plate 3
plot(grf_new(:,10),grf_new(:,12),'*r');        %plate 2
plot(grf_new(:,4),grf_new(:,6),'*k');          %plate 1
plot(grf_new(:,22),grf_new(:,24),'*g');        %plate 4
plot(grf_new(:,28),grf_new(:,30),'*m');        %plate 5
legend('step 1','step 2','step 3','step 4','step 5');
% plot_origin(0.5)
title('COP - in OpenSim Reference Frame','fontsize',12)
grid on
axis equal
pause(0.1)

break
%% The resulting GR Moment voltage (Shows that the columns in txt file corresponding to the correct axis).
fig = figure(7);
set(fig,'color','w');
set(gcf,'Position',[50,50, 960,720]);
subplot(2,2,1)
plot(t_old,grf_raw(:,10:12));
legend('z','x','y');
axis([0 time -inf inf])
ylabel('Votage (Volts)');
xlabel('Time, (sec)');
title('Plate B - GR Moment raw volt in Plate Frame')
subplot(2,2,2)
plot(t_old,grf_raw(:,22:24))
legend('z','x','y');
axis([0 time -inf inf])
ylabel('Votage (Volts)');
xlabel('Time, (sec)');
title('Plate D - GR Moment raw volt in Plate Frame')
subplot(2,2,3)
plot(t_old,grf_raw(:,4:6))
legend('z','x','y');
axis([0 time -inf inf])
ylabel('Votage (Volts)');
xlabel('Time, (sec)');
title('Plate A - GR Moment raw volt in Plate Frame')
subplot(2,2,4)
plot(t_old,grf_raw(:,16:18))
legend('z','x','y');
axis([0 time -inf inf])
ylabel('Votage (Volts)');
xlabel('Time, (sec)');
title('Plate C - GR Moment raw volt in Plate Frame')

%% FIGURE 8 - The resulting GRF in plate coordinate system (and still in Fz, Fx, Fy sequence):
fig = figure(8);
set(gcf,'Position',[50,50, 960,720]);
set(fig,'color','w');
subplot(2,2,1)
plot(t_old,grf(:,10:12));
vline(plate_cut_t(2,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N cm)');
xlabel('Time, (sec)');
title('Plate B - GR Moment, volt2foce conversion, Plate Frame')

subplot(2,2,2)
plot(t_old,grf(:,22:24))
vline(plate_cut_t(4,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N cm)');
xlabel('Time, (sec)');
title('Plate D - GRF Moment, volt2foce conversion, Plate Frame')

subplot(2,2,3)
plot(t_old,grf(:,4:6))
vline(plate_cut_t(1,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N cm)');
xlabel('Time, (sec)');
title('Plate A - GRF Moment, volt2foce conversion, Plate Frame')

subplot(2,2,4)
plot(t_old,grf(:,16:18))
vline(plate_cut_t(3,:));
legend('z','x','y');% still in Fz, Fx, Fy sequence
axis([0 time -inf inf])
ylabel('Moment (N cm)');
xlabel('Time, (sec)');
title('Plate C - GRF Moment, volt2foce conversion, Plate Frame')


%% FIGURE 9 - The resulting GRF in OpenSim coordinate system :
fig = figure(9);
set(gcf,'Position',[50,50, 960,720]);
set(fig,'color','w');
subplot(2,2,1)
plot(t_old,mom_new(:,4:6));
vline(plate_cut_t(2,:));
legend('x','y','z');% OpenSim frame sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('Plate B - GR Moment, Transform to OpenSim Frame')

subplot(2,2,2)
plot(t_old,mom_new(:,10:12))
vline(plate_cut_t(4,:));
legend('x','y','z');% OpenSim frame sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('Plate D - GRF Moment, Transform to OpenSim Frame')

subplot(2,2,3)
plot(t_old,mom_new(:,1:3))
vline(plate_cut_t(1,:));
legend('x','y','z');% OpenSim frame sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('Plate A - GRF Moment, Transform to OpenSim Frame')

subplot(2,2,4)
plot(t_old,mom_new(:,7:9))
vline(plate_cut_t(3,:));
legend('x','y','z');% OpenSim frame sequence
axis([0 time -inf inf])
ylabel('Moment (N m)');
xlabel('Time, (sec)');
title('Plate C - GRF Moment, Transform to OpenSim Frame')


