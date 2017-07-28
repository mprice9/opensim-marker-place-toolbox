function cost = ObjFun(x,options)

global  rmsCOST avgRMS divisor COST fileID iteration markerScale loop coord stepCount
     
% override variables
% divisor = 1;

genericSetupForIK = options.IKsetup;
% genericSetupForIK = 'markerOptIKSetup.xml';

% X = x0;
X = x;
% disp(x)
% newName = 'autoScaleWorker.osim';
newName = options.modelWorker;
% newName = newPassiveModel;

% markerScale
markerPlacer(X, newName,options);


try
    % run OpenSim IK executable through DOS
    [~, log_mes] = dos(['ik -S ' genericSetupForIK]);

    lines = strsplit(log_mes,'\n');
%     disp(lines)
    nLines = size(lines,2)-3;
%     disp(nLines)

    % Actually line 19, but unknown error, this cuts off first few frames
    % Revisit this, it can be cleaned up
    TSE = zeros(nLines-23,1); 
    RMS = zeros(nLines-23,1);
    for line = 22:nLines-2

        frame = strsplit(lines{line},{'\t', ' ',',','='});
        TSE(line-21,1) = str2double(frame{1,8});
        RMS(line-21,1) = str2double(frame{1,12});
        
    end
    
    TSEcost = sum((TSE.*1000).^2);
    RMScost = sum((RMS.*1000).^2);
%     disp(RMScost)
catch
    % if IK fails, it means the guess was VERY wrong
    RMScost = 10000000;
    TSEcost = 10000000;
end

IKresults = options.motionWorker;
% data = dlmread(IKresults,'\t',11,0);
data = importdata(IKresults,'\t',11);
tags = data.colheaders;
% frames = round(302/divisor*.1);


% penalize the average pelvis tilt
% TILTcost = abs(mean(data(1:end,2).^2))*10;
TILTcost = abs(mean(data.data(1:end,strcmp('pelvis_tilt',tags)).^2))*10;

% penalize non-zero socket coordinates at the zero position
% data = importdata('Chopped_ik.mot','\t',11);
% tags = data.colheaders;


if strcmp(options.bodySet, 'prosThigh')

%     flexionTag = find(strcmp('socket_flexion',tags));
%     pistonTag = find(strcmp('socket_ty',tags));
    socketFlexion = data.data(options.flexionZero,strcmp('socket_flexion',tags));
    socketPiston = data.data(1,strcmp('socket_ty',tags));

    % socketFlexion = data(1,19);
%     socketFlexion = data(options.flexionZero,19); % Trying 0 flexion at mid-stance when horiz GRF crosses 0.
    socketFlexion = socketFlexion.^2 * 20;
%     socketAdduction = data(1,20);
%     socketRotation = data(1,21);
%     socketPiston = data(1,23);
    socketPiston = (socketPiston*1000).^2 * 10;
    % SOCKETcost = (socketFlexion.^2 + socketPiston.^2) .* 50;
    SOCKETcost = socketFlexion + socketPiston;

    % total cost
    cost = TSEcost + TILTcost + SOCKETcost;
    % cost = TSEcost;

    COST = cost;

    rmsCOST = RMScost;

    avgRMS = mean(RMS.*1000);

    message = [' Iter: ' num2str(iteration)...
    ' Obj: ' num2str(cost) ' Marker cost: ' num2str(TSEcost) ' Tilt cost: ' ...
    num2str(TILTcost) ' Socket cost: ' num2str(SOCKETcost) ' Flexion cost: ' ...
    num2str(socketFlexion) ' Piston cost: ' num2str(socketPiston) ' Avg RMS: ' ...
    num2str(avgRMS) ' Marker coordinate: ' coord ' Steps from IC (mm): ' ...
    num2str(stepCount) ' time: ' num2str(toc)];

else
    cost = TSEcost + TILTcost;

    COST = cost;

    rmsCOST = RMScost;

    avgRMS = mean(RMS.*1000);
    
    message = [' Iter: ' num2str(iteration)...
    ' Obj: ' num2str(cost) ' Marker cost: ' num2str(TSEcost) ' Tilt cost: ' ...
    num2str(TILTcost) ' Avg RMS: ' num2str(avgRMS) ' Marker coordinate: ' ...
    coord ' Steps from IC (mm): ' num2str(stepCount) ' time: ' num2str(toc)];
end

disp(message)

strFormat = '%s';
fprintf(fileID, strFormat, message);
fprintf(fileID,'\n');

iteration = iteration + 1;


