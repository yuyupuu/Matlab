function getHandles(filemat,handles)
%to get handles/data stored in files
    data = load(filemat);
    disp(filemat)
    fileVars = whos('-file',filemat);
    matName = 'electrodeMat';
    if ismember(matName,{fileVars.name}) == 1 && isinteger(data.electrodeMat)
        handles.currElecData = data.electrodeMat;
    else        
        display('''electrodeMat'' is not in File')
        matName = inputdlg('What is the name of your electrode matrix variable?', 'Variable ''electrodeMat'' is not in loaded file or unusable' );
        while ~ismember(matName{1},{fileVars.name}) 
            %until the entered name othe matrix exists in the file and is a matrix containing integers
            matName = inputdlg('What is the name of your electrode matrix variable?', ['Variable ' matName{1} ' is not in loaded file or unusable'] );
            try 
                if isinteger(data.(matName{1}))
                    break
                end
            catch err
                continue
            end
        end
        display(matName{1})
        handles.currElecData = load(filemat,matName{1});
    end
    
    addedVars = [matName];
    %varsNames = *see below
    
    %% store other variables in handles as well
    % !!!! need to figure out how to cycle through variable names AND values in a file
    % regardless of type(i.e. struct, array, etc.)
    
end