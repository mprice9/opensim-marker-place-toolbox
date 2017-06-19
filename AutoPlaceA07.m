
close all
clear all
clc

global myModel fileID markerScale divisor iteration

import org.opensim.modeling.*

iteration = 1;
markerScale = 1;
divisor = 1;

% downSample the passive .trc file for speed
file_input = 'Passive_Pref0002.trc';
file_output = 'Chopped.trc';
downSampleTRC(divisor,file_input,file_output)

% create new file for log
fileID = fopen('coarseMarkerSearch_log_passive_unchopped.txt', 'w'); 
myModel = 'A07_passive_coarseSearch_chopped.osim';
newName = 'A07_passive_coarse_marker_search.osim';

% model = Model(myModel);
% model.initSystem();
% model.print(newName);

% scale
options.modelFolder = [pwd '\Models\'];
% options.limbScaleFactor = limbScaleFactor;  % segment scale factor
options.model = myModel;                    % generic model name
options.subjectMass = 73.1637;
options.newName = newName;
options.bodySet = 'ROB';
options.convThresh = 2;

tic

X = coarseMarkerSearch(options);