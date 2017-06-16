function X = coarseMarkerSearch(options)
    
    global coord testCoords stepCount fileID

    convThresh = options.convThresh;
    
    % Choose which markers to optimize in options.bodySet
    % Get initial guess x0
    x0 = getInitCond(options);     
    
    % Set output X equal to initial condition to start loop
    X = x0;
    
    % make log for X (in objective function)
    
    % Run initial IK to get initial obj function value
    F = ObjFun(X,options);
    
    convScore = ones(1,length(X))*10;
    % While loop - check convergence (auto fail first pass)    
    while max(abs(convScore)) > convThresh
        
        
        for i = 1:length(X)

            convFlag = 0;
            searchDir = 1;
            numSteps = 0;
            convScore(i) = 0;
            oldSearchDir = 1;
            
            coord = testCoords{i};
            stepCount = 0;
            
            while convFlag < 1
                
                convFlag = abs((numSteps > 1)*(sign(searchDir) - sign(oldSearchDir)));
                
                oldSearchDir = searchDir;
                oldF = F;
                
                if numSteps == 0
                    f0 = F;
                end
                
                % markerCoord + 1mm
                X(i) = X(i) + 0.001*searchDir;
                
                convScore(i) = convScore(i) + searchDir;
                stepCount = convScore(i);
                
                % run IK
                F = ObjFun(X,options);
                
                % Check objFun gradient (pos or neg)
                if abs(searchDir) > 1 && numSteps == 1
                    gradSign = sign(F - f0);
                else
                    gradSign = sign(F - oldF);
                end
            
                if(gradSign == 0) 
                    message = 'Marker has no effect on IK';
                    
                    disp(message)

                    strFormat = '%s';
                    fprintf(fileID, strFormat, message);
                    fprintf(fileID,'\n');
    
                    break;
                end
                
                if(gradSign == 1 && numSteps < 1)
                    searchDir = ((searchDir*-gradSign)/abs(searchDir*-gradSign))*2;
                else
                    searchDir = (searchDir*-gradSign)/abs(searchDir*-gradSign);
                end

                numSteps = numSteps + 1;

            end 
        end
        
    end
    
    message = 'Marker search complete.';

    disp(message)

    strFormat = '%s';
    fprintf(fileID, strFormat, message);
    fprintf(fileID,'\n');
   
end
    
