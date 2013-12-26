function WindowKeyPressFcn(source, eventdata, handles)

% %Should we parse?
% if handles.pause_parsing,
%     return;
% end

% Was it a command string?
keypressed = eventdata.Key;
keymod = eventdata.Modifier;
keychar = eventdata.Character;
switch keypressed
    %Selection
    case 's'
        handles.cur_command = 1;
        guidata(hObject, handles);
        %Change grid
    case 'g'
        handles.cur_command = 0;
        handles.cur_grid = mod(handles.cur_grid, handles.num_grids) + 1;
        handles.cur_sel_row = []; handles.cur_sel_col = []; %clear selection
        UpdateAllAndSave(handles);
        guidata(hObject, handles);
        %Change electrode state
    case 'n'
        handles.cur_command = 0;
        NoisyRB_Callback(handles.NoisyRB, [], handles);
    case 'q'
        handles.cur_command = 0;
        QuietRB_Callback(handles.QuietRB, [], handles);
    case 'c'
        handles.cur_command = 0;
        CellsRB_Callback(handles.CellsRB, [], handles);
    case 'w'
        handles.cur_command = 0;
        wmRB_Callback(handles.wmRB, [], handles);
        
        %Move electrode(s)
    case 'uparrow'
        handles.cur_command = 0;
        %Move selection up
        handles = MoveSelection(handles, 1);
        UpdateAllAndSave(handles);
        guidata(hObject, handles);
    case 'downarrow'
        handles.cur_command = 0;
        handles = MoveSelection(handles, -1);
        UpdateAllAndSave(handles);
        guidata(hObject, handles);
    case 'pageup'
        handles.cur_command = 0;
        handles = MoveSelection(handles, handles.big_step);
        UpdateAllAndSave(handles);
        guidata(hObject, handles);
    case 'pagedown'
        handles.cur_command = 0;
        handles = MoveSelection(handles, -handles.big_step);
        UpdateAllAndSave(handles);
        guidata(hObject, handles);
        
        %Change current selection
    case 'numpad8'
        if isempty(handles.cur_sel_row) || isempty(handles.cur_sel_col),
            return;
        end
        handles.cur_sel_row = handles.cur_sel_row(1); handles.cur_sel_col = handles.cur_sel_col(1);
        valid_rows = sort(find(handles.grid_shape{handles.cur_grid}(:, handles.cur_sel_col)));
        cur_row_ind = find(valid_rows == handles.cur_sel_row);
        cur_row_ind = mod(cur_row_ind, length(valid_rows)) + 1;
        handles.cur_sel_row = valid_rows(cur_row_ind);
        UpdateAll(handles);
        guidata(hObject, handles);
    case 'numpad2'
        if isempty(handles.cur_sel_row) || isempty(handles.cur_sel_col),
            return;
        end
        handles.cur_sel_row = handles.cur_sel_row(1); handles.cur_sel_col = handles.cur_sel_col(1);
        valid_rows = sort(find(handles.grid_shape{handles.cur_grid}(:, handles.cur_sel_col)));
        cur_row_ind = find(valid_rows == handles.cur_sel_row);
        cur_row_ind = mod(cur_row_ind - 2, length(valid_rows)) + 1;
        handles.cur_sel_row = valid_rows(cur_row_ind);
        UpdateAll(handles);
        guidata(hObject, handles);
    case 'numpad4'
        if isempty(handles.cur_sel_row) || isempty(handles.cur_sel_col),
            return;
        end
        handles.cur_sel_row = handles.cur_sel_row(1); handles.cur_sel_col = handles.cur_sel_col(1);
        valid_cols = sort(find(handles.grid_shape{handles.cur_grid}(handles.cur_sel_row, :)));
        cur_col_ind = find(valid_cols == handles.cur_sel_col);
        cur_col_ind = mod(cur_col_ind - 2, length(valid_cols)) + 1;
        handles.cur_sel_col = valid_cols(cur_col_ind);
        UpdateAll(handles);
        guidata(hObject, handles);
    case 'numpad6'
        if isempty(handles.cur_sel_row) || isempty(handles.cur_sel_col),
            return;
        end
        handles.cur_sel_row = handles.cur_sel_row(1); handles.cur_sel_col = handles.cur_sel_col(1);
        valid_cols = sort(find(handles.grid_shape{handles.cur_grid}(handles.cur_sel_row, :)));
        cur_col_ind = find(valid_cols == handles.cur_sel_col);
        cur_col_ind = mod(cur_col_ind, length(valid_cols)) + 1;
        handles.cur_sel_col = valid_cols(cur_col_ind);
        UpdateAll(handles);
        guidata(hObject, handles);
    otherwise
        if (cur_char >= 'a') & (cur_char <= 'j'),
            %A letter was hit
            if handles.cur_command == 1,
                handles.cur_command = 2;
                handles.cur_command_row = cur_char - 'a' + 1;
            elseif handles.cur_command == 2,
                handles.cur_command = 0;
                handles.cur_sel_row = handles.cur_command_row;
                handles.cur_sel_col = sort(find(handles.grid_shape{handles.cur_grid}(handles.cur_sel_row, :)));
                handles.cur_sel_row = handles.cur_sel_row*ones(size(handles.cur_sel_col));
            end
        elseif (cur_char >= '0') & (cur_char <= '9'),
            %Move a '0' to 10
            if (cur_char == '0'),
                cur_char = cur_char + 10;
            end
            %A number was hit
            if handles.cur_command == 1,
                %After selection key
                handles.cur_command = 3;
                handles.cur_command_row = [];
                handles.cur_command_col = cur_char - '1' + 1;
            elseif handles.cur_command == 2,
                %After a letter key
                handles.cur_command = 0;
                handles.cur_sel_row = handles.cur_command_row;
                handles.cur_sel_col = cur_char - '1' + 1;
            elseif handles.cur_command == 3,
                %Two number keys in a row
                handles.cur_command = 0;
                if (cur_key - '1' + 1) == handles.cur_command_col,
                    handles.cur_sel_col = handles.cur_command_col;
                    handles.cur_sel_row = sort(find(handles.grid_shape{handles.cur_grid}(:, handles.cur_sel_col)));
                    handles.cur_sel_col = handles.cur_sel_col*ones(size(handles.cur_sel_row));
                end
            end
        end
        UpdateAll(handles);
        guidata(hObject, handles);
end

