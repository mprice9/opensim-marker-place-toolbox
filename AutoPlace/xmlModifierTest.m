import org.opensim.modeling.*

genericSetupPath = ([pwd '\IKSetup\']);
genericSetupForIK = 'A03_Setup_IK.xml';
model_dir = ([pwd '\Models\AutoPlaced\']);
model = 'A03_passive_FULL_auto_marker_place_RIGID_7-Jul-2017_15.27.50.osim';

% Instantiate an IK tool      
ik = InverseKinematicsTool([genericSetupPath genericSetupForIK]);
        
% Get a reference to an abstract property of the object. It is equivalent 
% to having the XML tag name <factor> in an .osim file.
% ie AbstractProp  = Object.getPropertyByName(<factor>)
factorProp  = ik.getPropertyByName('model_file');
% get its value (it should be empty since we created a blank iktool)
path2model = PropertyHelper.getValueString(factorProp);
% Set the value for this string to the model path
PropertyHelper.setValueString([model_dir model],factorProp);
% print the setup file
ik.print('setup.xml')