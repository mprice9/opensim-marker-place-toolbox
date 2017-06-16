% get marker sets (HAT, intact leg, pros thigh, pros shank, socket, foot segments)
% load walking trial data
% min residuals for IK of walking trial, modify non pros side marker placements
% next: pros foot and socket - fix pos of some markers?
% next: thigh cluster

% look into global opt methods

% study effects of femur length on IK


% downsample marker data
% open log
% load walking data
% scale?
% set x0 for ROB and scale
% optimize for ROB
% set fixed markers for pros foot/socket
% set x0 for pros foot and socket
% optimize for pros foot and socket
% set fixed markers for thigh cluster (x coord)
% set x0 for thigh cluster
% optimize for thigh cluster
% set frame for socket zero
% calculate knee pos from pylon angle, known segment lengths

% Note: may need to scale femur after this. Can we determine current length
% of femur? May need to reopt after scaling. Numerically determine femur
% length after autoplace?

close all
clear all
clc


%% load model and set variables
global myModel iteration fileID markerScale divisor loop

markerScale = 1*10^-2;
divisor = 10;


% downSample the passive .trc file for speed
file_input = 'Passive_Pref0002.trc';
newFile = 'Chopped.trc';
downSampleTRC(divisor,file_input,newFile)

limbScaleFactor = 0.95;  % vary this in the outermost loop
% testNumber=1;
% iteration = 1;
% loop = 1;
tic

% create new file for log
fileID = fopen('autoplaceMarker_log_passive.txt', 'w'); 


myModel = 'A07_passive_autoScaled_longrun20.osim';

% scale
options.modelFolder = [pwd '\Models\'];
options.limbScaleFactor = limbScaleFactor;                            % segment scale factor
options.model = myModel;            % generic model name
options.newName = ['A07_passive_',num2str(limbScaleFactor) ,'.osim'];    % new model name  
options.subjectMass = 73.1637;
options.bodySet = 'ROB';
% FemurScale(options);

% autoplace markers
x0Rob = getInitCond(options);          % get marker original positions
% disp(x0)
x0Rob(1:end) = x0Rob(1:end).* markerScale;

% optimization options
A = [];
b = [];
Aeq = [];
beq = [];
lb(1:size(x0Rob,2)) = x0Rob(1:size(x0Rob,2)) - (0.1 * markerScale);
ub(1:size(x0Rob,2)) = x0Rob(1:size(x0Rob,2)) + (0.1 * markerScale);
nonlcon = [];
% options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
% options = optimoptions('fmincon','Display','iter','UseParallel',true);
% options = optimoptions('fmincon','Display','iter','Algorithm','sqp','UseParallel',true);
%     optOptions = optimoptions('fmincon','Display','iter','Algorithm','sqp');
optOptions = optimoptions('fmincon','Display','iter');

% set cost function
fun = @ObjFun;

% run optimization iteration
XRob = fmincon(fun,x0Rob,A,b,Aeq,beq,lb,ub,nonlcon,optOptions);

options.bodySet = 'pros';
x0Pros = getInitCond(options);          % get marker original positions
x0Pros(1:end) = x0Pros(1:end).* markerScale;

lb(1:size(x0Pros,2)) = x0Pros(1:size(x0Pros,2)) - (0.1 * markerScale);
ub(1:size(x0Pros,2)) = x0Pros(1:size(x0Pros,2)) + (0.1 * markerScale);

XPros = fmincon(fun,x0Rob,A,b,Aeq,beq,lb,ub,nonlcon,optOptions);

options.bodySet = 'prosThigh';
x0Thigh = getInitCond(options);          % get marker original positions
x0Thigh(1:end) = x0Thigh(1:end).* markerScale;

lb(1:size(x0Thigh,2)) = x0Thigh(1:size(x0Thigh,2)) - (0.1 * markerScale);
ub(1:size(x0Thigh,2)) = x0Thigh(1:size(x0Thigh,2)) + (0.1 * markerScale);

XThigh = fmincon(fun,x0Rob,A,b,Aeq,beq,lb,ub,nonlcon,optOptions);

% save results
resultsName = ['A07_passive_',num2str(limbScaleFactor)  '_X.mat']
save resultsName X

%     % build final model and save (i think it does this in the objective
%     % function)
%     markerPlacer(X, options.newName)
% 


%% IK for 3 different datasets used in my dissertation for 4 DoF socket

%% plot pistoning flexion and knee angle and save results


% end of outer loop