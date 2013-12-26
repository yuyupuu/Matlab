function drawGridFunc(figurename,handles)
    handles.textG = uicontrol('Parent',figurename,'Style','text','String',handles.currfile,'Units','normalized','Position',[.5 .5 .1 .1]);
    guidata(figurename,handles)
end