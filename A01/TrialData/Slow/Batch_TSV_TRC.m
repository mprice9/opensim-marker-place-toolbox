%--------------------------------------------------------------------------
% Description: Convert .TSV file to .TRC file format. Qualysis can output
% .TSV file, containing all the markers trajectory. However OpenSim only
% reads in .TRC file. Hence this script convert .TSV file to .TRC file
% according to the requirements of .TRC file.
% Usage: Change MATLAB working directory to where this file locate. Read 
% STEP 1 and STEP 2 below to proceed. The resulting .TRC file will be
% in in the current working directory.
% Update: 
% - Ver 3.0 add an option to export every markers available in TSV file;
% - Ver 2.0 now allow to export selected markers from a text file.
% 
% Author: Leng-Feng (contact: lengfenglee@gmail.com)
% University of Massachusetts Amherst, Dept. of Kinesiology.
% Copyright 2012.
% Date: 11/02/2011.
% -------------------------------------------------------------------------
% Modified Jan 2016 by Andrew LaPre
% Modifications allow batch processing of files
% Modifications not complete

close all
clear all
clc

%--------------------------------------------------------------------------
% STEP 1:
%--------------------------------------------------------------------------
% Modify this directory for folder containing the tsv files 

data_folder = 'D:\Cloud Storage\Eyes_Only\MRRL\OpenSim Project\OpenSim Shared Drive\A01_SocketModelPaper\A01 Processed Data\Marker_TSV_files\';
trials = dir(fullfile(data_folder, '*.tsv'));
nTrials = size(trials);
pathname = data_folder;



%--------------------------------------------------------------------------
% STEP 2:
%--------------------------------------------------------------------------
% Output TRC file
% You will need to copy and paste the generated .trc files from this
% directory to the desired directory once they are generated. 

for trial = 1:nTrials;

    % Get the name of the file for this trial
    file_input = trials(trial).name;
    
    % Create name from .tsv file
    name = regexprep(file_input,'.tsv','');
    trc_filename = [name '.trc'];
    
    foldname = {[name '_TSV_TRC']}; % Folder to save figures, change accordingly.


% ------------------ BEGINING PROCESSING THE DATA -------------------------

%extract the marker x,y,z data only
data = dlmread(strcat(pathname,file_input),'',10,0); %all are data

%Get the header information
% [names, info] = textread(file_input,'%s %d',6);
[names, info] = textread(strcat(pathname,file_input),'%s %d',6);

frame = info(1);          % # of frames
num_marker_old = info(3); % # of markers
freq = info(4);           % # Frame rates (should be 240Hz, default in lab)
% calculate the total time (TSV file doesn't have time stamp):
time = frame/freq;    
% create the time stamp (used in TRC file)
t = linspace(0,time,frame)';
% create the frame stamp (used in TRC file)
f = linspace(1,frame,frame)';

% Grab the marker names in the TSV file header
fid = fopen(strcat(pathname,file_input));
c=textscan(fid,'%s',num_marker_old+1,'Headerlines',9); %num_marker+1 b'cos first marker is 'MARKER_NAMES'
temp=c{1}; %Grab the markers names used
label_header = temp(2:end); %remove the first entry, "MARKER_NAME"
fclose(fid);

% -------------------------------------------------------------------------
% Process the data to place it at the correct Frame of Reference and
% Export all markers (do the selection in OpenSim.
% -------------------------------------------------------------------------


% Export all markers available in TSV file:
labels = label_header;
num_marker = num_marker_old; % # of markers
for i = 1:num_marker_old,  %Loop through all markers available in TSV file
        tempx = data(:,3*(i-1)+1);
        tempy = data(:,3*(i-1)+2);
        tempz = data(:,3*(i-1)+3);
        data_new(:,(3*(i-1)+1):(3*(i-1)+3)) = [tempy,tempz,tempx];
end
% Replace no data with NaN (Optionally this step can be perform in Qualisys)
for i = 1:num_marker*3,
    for j = 1:frame,
    if (data_new(j,i) == 0 )
        data_new(j,i) = NaN;
    end
    end
end

%% -------------------------- Filtering -----------------------------------
% Perform filtering on the data. 
% input: data_new ; output: data_fil
% -------------------------------------------------------------------------
% Create directory for saving figures if not exist
dir_c = exist(char(strcat('Figures_',foldname,date)), 'dir'); 
if dir_c == 0,
    mkdir(char(strcat('Figures_',foldname,date)));
end

data_fil = data_new; % fill out the data.
% data_fil = data_interp;
Fs = freq;
Fc = 6; 

for j = 1:length(labels), % loop through each markers.
    k = 3*(j-1)+1;        % index of marker in data_new
    ind = find(~isnan(data_new(:,k)));       % locate the row indices that have values
    ind_NaN = find(isnan(data_new(:,k)));    % row indices that is NaN (no value)
    split_ind = SplitVec(ind,'consecutive'); % split the indices that contain values
    
    % Filter the data for:
    % - Have missing points, Not empty;
    if (length(ind) ~= length(data_new(:,k)) && isempty(ind) == 0  ); 
        first_ind(1) = ind(1); % first row indices that have value, assuming the first chunk of data always usable
        last_ind(1) = ind(end);% last row indices that have value
        do_inter = 0;          % reset the check value.
        for m = 1:length(split_ind), %filter chunk by chunk gap in between chunks
            chunk = split_ind{m,1};
            if length(chunk(:,1)) > 6,%6 data points is the minumum data points needed to perform filter.
                first_ind = chunk(1,1);
                last_ind = chunk(end,1);            
                data_fil(first_ind:last_ind,k)  = bw_filter(data_new(first_ind:last_ind,k),Fs,Fc,'low');
                data_fil(first_ind:last_ind,k+1)= bw_filter(data_new(first_ind:last_ind,k+1),Fs,Fc,'low');
                data_fil(first_ind:last_ind,k+2)= bw_filter(data_new(first_ind:last_ind,k+2),Fs,Fc,'low');
            end

        end
        filter_chunk_labels{j,1} = labels(j); %Save the markers that done filtering
        % ----------- Plotting --------------------------------------------
        figure(j)
        subplot(3,1,1)
        plot(t,data_new(:,k),'k'); hold on
        plot(t,data_fil(:,k),'b');
        ylabel('x-pos','fontweight','bold');
        legend('Original','Filtered',4);
        title(strcat('Data Filtered (in chunks) for marker .', labels(j)),'fontweight','bold');
        subplot(3,1,2)
        plot(t,data_new(:,k+1),'k'); hold on
        plot(t,data_fil(:,k+1),'b');
        ylabel('y-pos','fontweight','bold');
        legend('Original','Filtered',4);
        subplot(3,1,3)
        plot(t,data_new(:,k+2),'k'); hold on
        plot(t,data_fil(:,k+2),'b');
        ylabel('z-pos','fontweight','bold');
        legend('Original','Filtered',4);
        print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\Filtered_by_chunks_',num2str(j))));
    % Filter the data for:
    % - Have complete data points;
    elseif (length(ind) == length(data_new(:,k))) %Have complete data points
        filter_full_labels{j,1} = labels(j); %Save the markers that done interpolation
        data_fil(:,k) = bw_filter(data_new(:,k),Fs,Fc,'low');
        data_fil(:,k+1)=bw_filter(data_new(:,k+1),Fs,Fc,'low');
        data_fil(:,k+2)=bw_filter(data_new(:,k+2),Fs,Fc,'low');
        % ----------- Plotting --------------------------------------------
        figure(j)
        subplot(3,1,1)
        plot(t(ind,1),data_new(ind,k),'k'); hold on
        plot(t(ind,1),data_fil(ind,k),'b');
        ylabel('x-pos','fontweight','bold');
        legend('Original','Filtered',4);
        title(strcat('Data Filtered (complete) for marker .', labels(j)),'fontweight','bold');
        subplot(3,1,2)
        plot(t(ind,1),data_new(ind,k+1),'k'); hold on
        plot(t(ind,1),data_fil(ind,k+1),'b');
        ylabel('y-pos','fontweight','bold');
        legend('Original','Filtered',4);
        subplot(3,1,3)
        plot(t(ind,1),data_new(ind,k+2),'k'); hold on
        plot(t(ind,1),data_fil(ind,k+2),'b');
        ylabel('z-pos','fontweight','bold');
        legend('Original','Filtered',4);
        print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\Filtered_full_',num2str(j))));
    else %what left is empty data
        Nofilter_empty_labels{j,1} = labels(j); %Save the markers that done interpolation
        % ----------- Plotting --------------------------------------------
        figure(j)
        subplot(3,1,1)
        plot(t,data_new(:,k),'o'); hold on
        ylabel('x-pos','fontweight','bold');
        title(strcat('No need for filtering (empty data) for marker .', labels(j)),'fontweight','bold');
        subplot(3,1,2)
        plot(t,data_new(:,k+1),'o');hold on
        ylabel('y-pos','fontweight','bold');
        subplot(3,1,3)
        plot(t,data_new(:,k+2),'o');hold on
        ylabel('z-pos','fontweight','bold');
        print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\NoFilter_Data_Empty_',num2str(j))));
        
    end
end

close all

%% -------------------- Interpolation -------------------------------------
% Interpolation strategy: Interpolate anything smaller than a threshold
% value, thres_gap. 
% input: data_fil ; output: data_interp
% -------------------------------------------------------------------------
thres_gap = 25; %Gap size to determine if a interpolation should be perform.
% data_interp = NaN(size(data_new)); %set up the matrix size
% data_interp = data_new; %set up the matrix size
data_interp = data_fil; %set up the matrix size

for j = 1:length(labels),
% for j = 1:1,
    k = 3*(j-1)+1; %index of marker in data_new
    ind = find(~isnan(data_new(:,k))); %locate the row indices that have values
    ind_NaN = find(isnan(data_new(:,k))); % row indices that is NaN (no value)
    split_ind = SplitVec(ind,'consecutive'); %split the indices that contain values

    % If length of row of indices and row of data are same (i.e. no missing data) - no need interpolation;
    % If all marker data is missing, empty ind - no need interpolation;
    % If only 1 chunk of data exist (missing data at the begining or the end), no interpolation needed.
    % Data exist, not complete, and have more than 1 chunk - interpolate if gap is less than 25 points;
    if (length(ind) ~= length(data_new(:,k)) && isempty(ind) == 0 && length(split_ind) > 1 ); 
        first_ind(1) = ind(1); %first row indices that have value, assuming the first chunk of data always usable
        last_ind(1) = ind(end);%last row indices that have value
        do_inter = 0; 
        %Loop through each chunks of data to determine if the gap is small enough to interpolate.
        for m = 1:length(split_ind)-1, %Evaluate gap in between chunks
            chunk1 = split_ind{m,1};
            chunk2 = split_ind{m+1,1};
%                 inter_ind_start = chuck1(1,1); %save the first ind to be interpolated
            if (chunk2(1,1) - chunk1(end,1)) <= thres_gap && length(chunk1(:,1)) > 3 && length(chunk2(:,1)) > 3, %the gap allowed, %the gap allowed
                first_ind(m) = chunk1(1,1);        %Starting indices of data used for interpolation;
                last_ind(m) = chunk2(end,1);       %End indices of data used for interpolation;
                first_interp(m) = chunk1(end,1)+1; %Starting indices of the gap;
                last_interp(m) = chunk2(1,1)-1;    %Ending indices of the gap;
                do_inter(m) = 1;
            else
                do_inter(m) = 0; %do no do interpolation between chunks
            end
        end
%         end
        
        if sum(do_inter) > 0, % Gap are within threshold to do interpolation.
            Interp_labels{j,1} = labels(j); %Save the markers that done interpolation
            for i = 1:length(do_inter),
                if do_inter(i) == 1,
%                 x_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k),   t(first_interp(i):last_interp(i),1), 'spline');
%                 y_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k+1), t(first_interp(i):last_interp(i),1), 'spline');
%                 z_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k+2), t(first_interp(i):last_interp(i),1), 'spline');
                x_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k),   t(first_ind(i):last_ind(i),1), 'spline');
                y_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k+1), t(first_ind(i):last_ind(i),1), 'spline');
                z_interp = interp1(t(first_ind(i):last_ind(i),1), data_fil(first_ind(i):last_ind(i),k+2), t(first_ind(i):last_ind(i),1), 'spline');
            
%                 data_interp(first_interp(i):last_interp(i),k:k+2) =[x_interp,y_interp,z_interp]; %Replace the interpolated values to the gap.
                data_interp(first_ind(i):last_ind(i),k:k+2) =[x_interp,y_interp,z_interp]; %Replace the interpolated values to the gap.
                end
            end
            % ----------- Plotting --------------------------------------------
            figure(j)
            subplot(3,1,1)
            plot(t,data_fil(:,k),'o',t,data_interp(:,k)); hold on
            ylabel('x-pos','fontweight','bold');
            title(strcat('Data Interpolation for marker .', labels(j)),'fontweight','bold');
            subplot(3,1,2)
            plot(t,data_fil(:,k+1),'o',t,data_interp(:,k+1));hold on
            ylabel('y-pos','fontweight','bold');
            subplot(3,1,3)
            plot(t,data_fil(:,k+2),'o',t,data_interp(:,k+2));hold on
            ylabel('z-pos','fontweight','bold');
            print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\Data_interpolated_',num2str(j))));
        else  % Gap are more than threshold to do interpolation, no interpolation.
            GapTooBigPtnTooFewToInterp_labels{j,1} = labels(j); %Save the markers that gap is too big to do interpolation
            % ----------- Plotting --------------------------------------------
            figure(j)
            subplot(3,1,1)
            plot(t,data_fil(:,k),'o'); hold on
            ylabel('x-pos','fontweight','bold');
            title(strcat('Gap too big for interpolation for marker .', labels(j)),'fontweight','bold');
            subplot(3,1,2)
            plot(t,data_fil(:,k+1),'o');hold on
            ylabel('y-pos','fontweight','bold');
            subplot(3,1,3)
            plot(t,data_fil(:,k+2),'o');hold on
            ylabel('z-pos','fontweight','bold');
            print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\Data_GapTooBig_ToInterpolate_',num2str(j))));
        end
    else % data are complete, no need to do interpolation.
        NoNeedToInterp_labels{j,1} = labels(j); %Save the markers that are no need for interpolation
        % ----------- Plotting --------------------------------------------
        figure(j)
        subplot(3,1,1)
        plot(t,data_fil(:,k),'o'); hold on
        ylabel('x-pos','fontweight','bold');
        title(strcat('No need for interpolation (empty, complete, or 1 chunk) for marker .', labels(j)),'fontweight','bold');
        subplot(3,1,2)
        plot(t,data_fil(:,k+1),'o');hold on
        ylabel('y-pos','fontweight','bold');
        subplot(3,1,3)
        plot(t,data_fil(:,k+2),'o');hold on
        ylabel('z-pos','fontweight','bold');
        print('-djpeg','-r200',char(strcat('Figures_',foldname,date,'\Data_Complete_Empty_1Chunk_',num2str(j))));
    end

end


close all % Close all figures

%% Collect all data ready to be written to TRC file:
% DATA = [f, t, data_new]; % without filtering.
% DATA = [f, t, data_fil]; % with filtering.
DATA = [f, t, data_interp]; % with filtering + Interpolation.

% DATA = [f, t, data]; %Without changing the coordinate(use original data);

% % Plot to see the markers trajectory
% [X,Y,Z] = sphere;
% for i = 1:1:num_marker,
% %     plot3(data_new(:,i),data_new(:,i+1),data_new(:,i+2),'*'); hold on
% %     plot3(data(:,i),data(:,i+1),data(:,i+2),'*r'); hold on
%     surf(X*15+data_new(1,i),Y*15+data_new(1,i+1),Z*15+data_new(1,i+2),'facecolor','r','edgecolor','none'); hold on
%     txt = labels(i);
%     text(data_new(1,i),data_new(1,i+1),data_new(1,i+2),txt);
%     ylabel('y-position','fontweight','bold');
%     zlabel('z-position','fontweight','bold');
%     grid on
% % %     pause
% end
% plot_origin(10);
% axis([0 340 0 340 0 340])

%Print the TRC File headers:
fid = fopen(trc_filename,'w');
fprintf(fid,'%s\t%d\t%s\t%s\n','PathFileType', 4, '(x/y/z)',trc_filename);
fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','DataRate', 'CameraRate','NumFrames','NumMarkers','Units','OrigDataRate','OrigDataStartFrame','OrigNumFrames');
fprintf(fid,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n',freq, freq, frame,num_marker, 'mm', freq, 1, frame); % <-- Note the unit used here.
fprintf(fid,'%s\t%s\t','Frame#','Time');

%Print the markers labels:
for i = 1:length(labels)
    txt = labels(i);
    fprintf(fid, '%s\t\t\t',char(txt) );
end
fprintf(fid,'\n\t\t'); %print an additional empty line (as in sample TRC file)
%Print the markers x, y, z labels:
for i = 1:length(labels),
    x_txt = strcat('X',num2str(i));
    y_txt = strcat('Y',num2str(i));
    z_txt = strcat('Z',num2str(i));
    fprintf(fid, '%s\t%s\t%s\t', x_txt, y_txt, z_txt);
end
fprintf(fid,'\n\n');
fclose(fid);

% Temporary solution: replace cevical spine data marker in Calibration file
% [m,n]=size(DATA)
% cevical_spine=[linspace(212.263,212.263,m)',linspace(1532.8,1532.8,m)',linspace(292.2285,292.2285,m)'];
% DATA(:,165:167)=cevical_spine; %For "Carl_NormalMarkerNamelist.txt"
% DATA(:,105:107)=cevical_spine; %For "Carl_LeftMedialMarkerNamelist.txt"
% DATA(:,156:158)=cevical_spine; %For "Carl_FullMarkerNamelist.txt"

% % Write the matrix data to the file:
dlmwrite(trc_filename, DATA,'-append','delimiter','\t','newline','pc');

% ---------------------- DONE PROCESSING THE DATA -------------------------

disp('TRC File successfully created!');
clear ans c chunk data DATA data_fil data_interp data_new dir_c do_inter...
    f Fc fid file_input filter_chunk_labels filter_full_labels first_ind...
    foldname frame freq Fs i ind ind_NaN info j k label_header labels...
    last_ind m name names NoNeedToInterp_labels num_marker num_marker_old...
    split_ind t temp tempx tempy tempz thres_gap time txt x_txt y_txt z_txt




end

disp('Batch processing complete.');
