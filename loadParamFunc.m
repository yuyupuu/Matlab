function loadParamFunc(source, eventdata,handles)
    if ~strcmpi(handles.currfile, ''),
        button = questdlg('There is already a file loaded.  Replace?', 'Replace existing?', 'Yes', 'No', 'No');
        if ~strcmpi(button, 'yes'),
            %do nothing
            return;
        end
    end
    [FileName,PathName] = uigetfile('../*.mat', 'Select Electrode Matrix...');
    if ~isstr(FileName) & (FileName == 0),
        %do nothing
        warndlg('No file selected.');
        return;
    end
    handles.currfile = sprintf('%s\\%s', PathName, FileName)
    handles.getHandlesFunc(handles.currfile,handles);
    handles.drawGrid(handles.gridFig,handles);
    guidata(source, handles);
end