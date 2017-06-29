function downSampleTRC(divisor,file_input,newFile)



% divisor = 12;
% file_input = 'Passive_Pref0002.trc';
% newFile = 'PassiveChopped.trc';
% pathName = pwd;

clear data

maxMarkers = 200;

% get first and last frame
% first = round(frames(trial,2)/10);
% last = round(frames(trial,3)/10);


%Get the header information
fileID = fopen(file_input);
n = 1;

% set up string fomat
strFormat = '%s';
while n<maxMarkers+1
    strFormat = strcat(strFormat, ' %s');
    n = n+1;
end
clear header data

% extract header
header = textscan(fileID,strFormat, 5,'Delimiter','\t');
fclose(fileID);

% extract data
% col = (49*3)+1;
% data = dlmread(file_input,'\t',[6 1 10 col]) %all are data
data = dlmread(file_input,'\t',5,0); %all are data

% cut the data up
oldRate = str2double(header{1,1}{3,1});
newRate = oldRate/divisor;
frame = 0;
row = 1;

while row < size(data,1)
    frame = frame + 1;
    newData(frame,:) = data(row,:);
    newData(frame,1) = frame;
    row = row + 240/newRate;
end

nFrames = num2str(frame);
RATE = num2str(newRate);

% create new files in write_folder and write headers
fileID = fopen(newFile, 'w');

% write header
for indx = 1:5
    n = 1;
    while n<maxMarkers+1
        temp{n} = char(header{1,n}(indx));
        n=n+1;
    end
    if indx == 3
        temp{1} = RATE;
        temp{2} = RATE;
        temp{3} = nFrames;
        temp{6} = RATE;
        temp{8} = nFrames;
    end
    n=1;
    strFormat = '%s';
    while n<maxMarkers+1
        n = n+1;
        if n<maxMarkers+1
            strFormat = strcat(strFormat, '\t%s');
        else
            strFormat = strcat(strFormat, '\n');
        end

    end
    fprintf(fileID, strFormat, temp{1:end});

end

fprintf(fileID,'\n');
fclose(fileID);

clear temp
temp = newData;

dlmwrite(newFile,temp,'-append','delimiter','\t', 'newline','pc')
save data.mat data
load data.mat
clear temp