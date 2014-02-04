function saveStateFunc(source, eventdata, handles)
    if exist(handles.currFileName) == 2 %if there is a .m file with currFileName in current path
        dialog
        dlmwrite(sprintf('%s_%s.m',handles.currFileName,datestr(date,'mmddyy')),[handles],'\n')
    elseif exist(handles.currFileName) == 1 || exist(handles.currFileName == 0 %if there is not a same name file
        uisave()
            
    end
end