function X = coarseMarkerSearch(options)
    
    global coord stepCount fileID

    
    % Choose which markers to optimize in options.bodySet
    % Get initial guess x0
    [x0, options] = getInitCond(options);  
    
    testCoords = options.testCoords;
    convThresh = options.convThresh;
    fixedMarkerCoords = options.fixedMarkerCoords;
    
    % Set output X equal to initial condition to start loop
    X = x0;
    
    % make log for X (in objective function)
    
    % Run initial IK to get initial obj function value
    F = ObjFun(X,options);
    xMin = X;
    fMin = F;
    
    convScore = ones(1,length(X))*10;
    % While loop - check convergence (auto fail first pass)    
    while max(abs(convScore)) > convThresh
        coordSkip = 0;
        for i = 1:(length(testCoords))
            convFlag = 0;
            searchDir = 1;
            numSteps = 0;
            convScore(i) = 0;
            oldSearchDir = 1;

            coord = testCoords{i};
            stepCount = 0;
            
            message = [coord ':'];
            disp(message)
            strFormat = '%s';
            fprintf(options.fileID, strFormat, message);
            fprintf(options.fileID,'\n');
            
            while convFlag < 1
                
                if max(strcmp(coord,fixedMarkerCoords))
                    coordSkip = coordSkip + 1;
                    message = ['Marker coordinate ' num2str(coord) ' is locked.'];                    
                    disp(message)
                    strFormat = '%s';
                    fprintf(options.fileID, strFormat, message);
                    fprintf(options.fileID,'\n');
                    break;
                end
                
                oldSearchDir = searchDir;
                oldF = F;
                
                if numSteps == 0
%                     f0 = F;
%                     fMin = F;
                    X = xMin;
                end
                
                % markerCoord + 1mm
                if strfind(coord,'ORIENT')
                    X(i-coordSkip) = X(i-coordSkip) + 0.005*searchDir;
                else
                    X(i-coordSkip) = X(i-coordSkip) + 0.001*searchDir;
                end
                
                
                convScore(i-coordSkip) = convScore(i-coordSkip) + searchDir;
                stepCount = convScore(i-coordSkip);
                
                % run IK
                F = ObjFun(X,options);
                

                
                % Check objFun gradient (pos or neg)
%                 if abs(searchDir) > 1 && numSteps == 1
%                     gradSign = sign(F - f0);
%                 else
%                     gradSign = sign(F - oldF);
%                 end

                gradSign = sign(F - fMin);            

                if(gradSign == 0) 
                    message = 'Marker coordinate has no effect on IK';                    
                    disp(message)
                    strFormat = '%s';
                    fprintf(options.fileID, strFormat, message);
                    fprintf(options.fileID,'\n');
                    break;
                end
                
                if (F < fMin)
                    fMin = F;
                    xMin = X;
                end
                
                if(gradSign == 1 && numSteps < 1)
                    searchDir = ((searchDir*-gradSign)/abs(searchDir*-gradSign))*2;
                else
                    searchDir = (searchDir*-gradSign)/abs(searchDir*-gradSign);
                end

                numSteps = numSteps + 1;
                
                convFlag = abs((numSteps > 1)*(sign(searchDir) - sign(oldSearchDir)));
                if convFlag > 0
                    message = [coord ' converged at ' num2str(stepCount + searchDir) ' mm from IC. Min obj: ' num2str(fMin)];
                    disp(message)
                    strFormat = '%s';
                    fprintf(options.fileID, strFormat, message);
                    fprintf(options.fileID,'\n');
                end

            end 
        end
        
    end
    
    tFinal = toc;
    message = ['Marker search complete. Time elapsed: ' num2str(tFinal) 's.'];

    disp(message)

    strFormat = '%s';
    fprintf(options.fileID, strFormat, message);
    fprintf(options.fileID,'\n');
   
end
    
