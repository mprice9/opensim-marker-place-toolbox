
function plot_origin(scale)

arrow([0 0 0],[1*scale 0 0]); % Show the Frame {F} - x-direction
arrow([0 0 0],[0 1*scale 0]); % Show the Frame {F} - y-direction
arrow([0 0 0],[0 0 1*scale]); % Show the Frame {F} - z-direction

text(1.2*scale,0,'X');
text(0,1.2*scale,'Y');
text(0,0,1.2*scale,'Z');

return
