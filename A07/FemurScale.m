%-------------------------------------------------------------------------% 
% FemurScale.m
%
% not done yet
%
% will not yet work with OpenSim 4.0
%
% Written by Andrew LaPre 4/2017
% Last Modified 4/2017
%
% example function call:
% options.modelFolder = 'Models\';
% options.limbRatio = 1.01;                            % amputated/intact-limb length ratio
% options.model = 'TTAmp_Left_passive.osim';          % generic model name
% options.newName = 'A03_passive_prescaled2.osim';    % new model name 
% FemurScale(options);  
%-------------------------------------------------------------------------% 

function FemurScale(ScaleOptions)

global myModel

% ScaleOptions.modelFolder;
modelFile = [ScaleOptions.modelFolder ScaleOptions.model];
limbScaleFactor = ScaleOptions.limbScaleFactor;
newName = ScaleOptions.newName;
subjectMass = ScaleOptions.subjectMass;

import org.opensim.modeling.*

model = Model(modelFile);

state = model.initSystem();

% ver = modelNew.getVersion()
bodies = model.getBodySet();
joints = model.getJointSet();

% determine amputation side and get scale factors
socketParent = joints.get('socket').getParentBody();
if strcmp(char(socketParent),'tibia_l_amputated')
    segNames = {'pelvis','femur_r','tibia_r','talus_r','calcn_r','toes_r',...
        'femur_l','tibia_l_amputated','pylon_socket','foot1','foot2','torso'};
else
    segNames = {'pelvis','femur_r','tibia_l','talus_l','calcn_l','toes_l',...
        'femur_l','tibia_r_amputated','pylon_socket','foot1','foot2','torso'};
end


SCALE(1,:)=[1,1,1];
SCALE(2,:)=[limbScaleFactor,limbScaleFactor,limbScaleFactor];
SCALE(3,:)=[1,1,1];
SCALE(4,:)=[1,1,1];
SCALE(5,:)=[1,1,1];
SCALE(6,:)=[1,1,1];
SCALE(7,:)=[limbScaleFactor,limbScaleFactor,limbScaleFactor];
SCALE(8,:)=[1,1,1];
SCALE(9,:)=[1,1,1];
SCALE(10,:)=[1,1,1];
SCALE(11,:)=[1,1,1];
SCALE(12,:)=[1,1,1];

newScaleSet = ScaleSet();

for i = 1:length(segNames)
    segScale(i) = Scale();
    segScale(i).setSegmentName(segNames{i});
    segScale(i).setScaleFactors(SCALE(i,:));
    segScale(i).setApply(true);
    newScaleSet.cloneAndAppend(segScale(i));
end

% scale the model
state = model.initSystem;
model.scale(state,newScaleSet, subjectMass, true);

model.setName(['A07_passive_', num2str(limbScaleFactor)])
model.initSystem();

% model.print([ScaleOptions.modelFolder newName]);
model.print([newName]);

myModel = newName;
