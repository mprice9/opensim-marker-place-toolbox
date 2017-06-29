
close all
clear all
clc

global myModel fileID markerScale divisor iteration


subject = 'A03';
prosType = 'passive';


import org.opensim.modeling.*

iteration = 1;
markerScale = 1;
divisor = 1;

% downSample the passive .trc file for speed
file_input = 'Passive_Pref0007.trc';
file_output = 'Chopped.trc';
downSampleTRC(divisor,file_input,file_output)



% create new file for log - ROB search
% fileID = fopen('coarseMarkerSearch_log_passive_ROB_unchopped.txt', 'w'); 
% myModel = 'A07_passive_coarseSearch_chopped.osim';
% newName = 'A07_passive_coarse_marker_search.osim';

% create new file for log - Socket search
fileID = fopen(['coarseMarkerSearch_log_' subject '_' prosType '_' char(datetime('now','TimeZone','local','Format','d-MMM-y_HH.mm.ss_Z')) '.txt'], 'w'); 
% myModel = 'A07_passive_manual_foot_markers.osim';
myModel = [subject '_' prosType '_pre_auto_marker_place.osim'];
newName = [subject '_' prosType '_ROB_auto_marker_place.osim'];

% model = Model(myModel);
% model.initSystem();
% model.print(newName);

% scale
options.modelFolder = [pwd '\Models\'];
options.IKsetup = 'Setup_IK_Passive_Pref0007.xml';
% options.limbScaleFactor = limbScaleFactor;  % segment scale factor
options.model = myModel;                    % generic model name
options.subjectMass = 67.3046;
options.newName = newName;

% Choose which set of bodies/markers is being placed. 'ROB' = Rest of
% body, 'pros' = Markers on the prosthesis, 'prosThigh' = Thigh markers on
% the prosthesis side and the socket joint center of rotation:
options.bodySet = 'ROB';

% List marker coordinates to be locked - algorithm cannot move them from
% hand-picked location:
options.fixedMarkerCoords = {'L_HEEL_SUP y','L_TOE x','L_TOE y','L_TOE z', 'L_THIGH_PROX_ANT x'};
% options.fixedMarkerCoords = {'L_HEEL_SUP y','L_HEEL_SUP z','L_TOE x','L_TOE y','L_TOE z'};
% options.fixedMarkerCoords = {'L_TOE x','L_TOE y','L_TOE z'};

% Specify frame from .trc file at which socket flexion should be minimized:
options.flexionZero = 94; 

% Specify marker search convergence threshold. All markers must move less 
% than convThresh mm from start position at each markerset iteration to 
% converge. If 1, a full pass with no marker changes must take place:
options.convThresh = 1; 

tic

X_ROB = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

myModel = newName;
newName = [subject '_' prosType '_PROS_auto_marker_place.osim'];
options.bodySet = 'pros';
X_pros = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

myModel = newName;
newName = [subject '_' prosType '_FULL_auto_marker_place.osim'];
options.bodySet = 'prosThigh';
X_prosThigh = coarseMarkerSearch(options);
model = Model('autoScaleWorker.osim');
model.initSystem();
model.print(newName);

fclose(fileID);