function saveAsStateFunc(source, eventdata, handles)
    uisave(handles,sprintf('%s_%s.m',handles.currFileName,datestr(date,'mmddyy')))
end