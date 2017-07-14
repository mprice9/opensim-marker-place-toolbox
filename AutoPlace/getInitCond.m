function x0 = getInitCond(options)

global testCoords

% modelFile = [options.modelFolder options.newName];
modelFile = options.model;
fixedMarkerCoords = options.fixedMarkerCoords;

% these guesses must have accompanying calculations in ModScaler.m

% global MODEL

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*
   
model = Model(modelFile);
model.initSystem();

markers = model.getMarkerSet;
m = Vec3(0,0,0);

% % determine amputation side
% joints = model.getJointSet();
% socketParent = joints.get('socket').getParentBody();

markerNames = options.markerNames;

% if strcmp(options.bodySet, 'ROB') % Note sternum not included - constrained to initial position
% %     if strcmp(char(socketParent),'tibia_l_amputated')
% %         markerNames = {'R_AC','L_AC','R_ASIS','L_ASIS','R_PSIS', ...
% %             'L_PSIS','R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
% %             'R_THIGH_DIST_POST','R_THIGH_DIST_ANT','R_SHANK_PROX_ANT', ...
% %             'R_SHANK_PROX_POST','R_SHANK_DIST_POST','R_SHANK_DIST_ANT', ...
% %             'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT','R_TOE','R_1ST_MET', ...
% %             'R_5TH_MET','C7'};
% %     else
% %         markerNames = {'R_AC','L_AC','R_ASIS','L_ASIS','R_PSIS','L_PSIS', ...
% %             'L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
% %             'L_THIGH_DIST_POST','L_THIGH_DIST_ANT','L_SHANK_PROX_ANT', ...
% %             'L_SHANK_PROX_POST','L_SHANK_DIST_POST','L_SHANK_DIST_ANT', ...
% %             'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT','L_TOE','L_1ST_MET', ...
% %             'L_5TH_MET','C7'};
% %     end
% elseif strcmp(options.bodySet, 'pros')
% %     if strcmp(char(socketParent),'tibia_l_amputated')
% %         markerNames = {'L_SHANK_PROX_POST', ...
% %             'L_SHANK_PROX_ANT','L_SHANK_DIST_ANT','L_SHANK_DIST_POST', ...
% %             'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT', ...
% %             'L_TOE','L_1ST_MET','L_5TH_MET'};
% %     else
% %         markerNames = {'R_SHANK_PROX_POST', ...
% %             'R_SHANK_PROX_ANT','R_SHANK_DIST_ANT','R_SHANK_DIST_POST', ...
% %             'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT', ...
% %             'R_TOE','R_1ST_MET','R_5TH_MET'};
% %     end
% %     if strcmp(char(socketParent),'tibia_l_amputated')
% %         markerNames = {'L_SHANK_PROX_POST', ...
% %             'L_SHANK_PROX_ANT','L_SHANK_DIST_ANT','L_SHANK_DIST_POST', ...
% %             'L_HEEL_SUP','L_HEEL_MED','L_HEEL_LAT', ...
% %             'L_TOE','L_1ST_MET','L_5TH_MET','L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
% %             'L_THIGH_DIST_POST','L_THIGH_DIST_ANT'};
% %     else
% %         markerNames = {'R_SHANK_PROX_POST', ...
% %             'R_SHANK_PROX_ANT','R_SHANK_DIST_ANT','R_SHANK_DIST_POST', ...
% %             'R_HEEL_SUP','R_HEEL_MED','R_HEEL_LAT', ...
% %             'R_TOE','R_1ST_MET','R_5TH_MET','R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
% %             'R_THIGH_DIST_POST','R_THIGH_DIST_ANT'};
% %     end
% elseif strcmp(options.bodySet, 'prosThigh')
% %     if strcmp(char(socketParent),'tibia_l_amputated')
% %         markerNames = {'L_THIGH_PROX_POST','L_THIGH_PROX_ANT', ...
% %             'L_THIGH_DIST_POST','L_THIGH_DIST_ANT'};
% %     else
% %         markerNames = {'R_THIGH_PROX_POST','R_THIGH_PROX_ANT', ...
% %             'R_THIGH_DIST_POST','R_THIGH_DIST_ANT'};
% %     end
% else
%     error('Invalid body set name')
% end
    
% x0 = zeros(1,length(markerNames)*3);
x0 = zeros(1,length(markerNames)*3 - length(fixedMarkerCoords));
testCoords = cell(1,length(markerNames)*3);

index = 1;
for i = 1:length(markerNames)
    m = Vec3(0,0,0);
    markers.get(markerNames(i)).getOffset(m);
    for j=1:3
        switch j
            case 1
                testCoords{3*(i-1) + j} = [markerNames{i} ' x'];
                if ~max(strcmp(fixedMarkerCoords,[markerNames{i} ' x']))
                    x0(index) = m.get(0);
                    index = index+1;
                end
            case 2
                testCoords{3*(i-1) + j} = [markerNames{i} ' y'];
                if ~max(strcmp(fixedMarkerCoords,[markerNames{i} ' y']))
                    x0(index) = m.get(1);
                    index = index+1;
                end                
            case 3
                testCoords{3*(i-1) + j} = [markerNames{i} ' z'];
                if ~max(strcmp(fixedMarkerCoords,[markerNames{i} ' z']))
                    x0(index) = m.get(2);
                    index = index+1;
                end
        end
    end
end

% for i = 1:length(markerNames)
%     markers.get(markerNames(i)).getOffset(m)
%     
%     if strcmp(markerNames{i},'L_HEEL_SUP')
%         x0(3*(i-1) + 1) = m.get(0);
% %         x0(3*(i-1) + 2) = m.get(1);
% %         x0(3*(i-1) + 3) = m.get(2);
%         
%         testCoords{3*(i-1) + 1} = [markerNames{i} ' x'];
%         testCoords{3*(i-1) + 2} = [markerNames{i} ' y'];
%         testCoords{3*(i-1) + 3} = [markerNames{i} ' z'];
%     elseif strcmp(markerNames{i},'L_TOE')
% %         x0(3*(i-1) + 1) = m.get(0);
% %         x0(3*(i-1) + 2) = m.get(1);
% %         x0(3*(i-1) + 3) = m.get(2);
%         
%         testCoords{3*(i-1) + 1} = [markerNames{i} ' x'];
%         testCoords{3*(i-1) + 2} = [markerNames{i} ' y'];
%         testCoords{3*(i-1) + 3} = [markerNames{i} ' z'];        
%     else
%         x0(3*(i-1) + 1) = m.get(0);
%         x0(3*(i-1) + 2) = m.get(1);
%         x0(3*(i-1) + 3) = m.get(2);
%         
%         testCoords{3*(i-1) + 1} = [markerNames{i} ' x'];
%         testCoords{3*(i-1) + 2} = [markerNames{i} ' y'];
%         testCoords{3*(i-1) + 3} = [markerNames{i} ' z'];
%     end
%       
% end

if strcmp(options.bodySet, 'prosThigh')

    sc = Vec3(); % create empty OpenSim vector for socket loc in parent 
    sp = Vec3();
    joints = model.getJointSet();
    joints.get('socket').getLocation(sc);
    joints.get('socket').getOrientation(sp);
    x0(end+1) = sc.get(0);
    testCoords{end+1} = 'SOCKET_JOINT_LOC_IN_BODY x';
    x0(end+1) = sc.get(1);
    testCoords{end+1} = 'SOCKET_JOINT_LOC_IN_BODY y';
    x0(end+1) = sc.get(2);
    testCoords{end+1} = 'SOCKET_JOINT_LOC_IN_BODY z';
    x0(end+1) = sp.get(0);
    testCoords{end+1} = 'SOCKET_JOINT_ORIENT x';
    x0(end+1) = sp.get(1);
    testCoords{end+1} = 'SOCKET_JOINT_ORIENT y';
    x0(end+1) = sp.get(2);
    testCoords{end+1} = 'SOCKET_JOINT_ORIENT z';

end

end
