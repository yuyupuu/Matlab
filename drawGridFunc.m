function drawGridFunc(figurename,handles)
    
    %handles.textG =uicontrol('Parent',figurename,'Style',...
    %'text','String',handles.currfile,'Units','normalized',...
    %'Position',[.5 .5 .1 .1]);%test to see if selectfile function is working
    
    handles.gridDim = size(handles.currElecData)%handles.gridDim = [rows,col]
    rows = handles.gridDim(1)
    cols = handlesgridDim(2)
    
    
    
    for r = 1:rows
       for c = 1:cols
           %disp(handles.currElecData(r,c))
    end
    guidata(figurename,handles)
end