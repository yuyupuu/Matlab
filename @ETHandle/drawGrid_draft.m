%Draw the grid figure
function DrawGrid(ax, handles)

axes(ax);
cla;
%Loop through the electrodes, drawing each on in place
[num_rows, num_cols] = size(handles.grid_shape{handles.cur_grid});
for cur_row = 1:num_rows,
    for cur_col = 1:num_cols,
        if handles.grid_shape{handles.cur_grid}(cur_row, cur_col),
            %Draw it to our figure
            DrawUnit(handles.grid_col_spacing(handles.cur_grid)*(cur_col - (num_cols+1)/2), ...
                handles.grid_row_spacing(handles.cur_grid)*(cur_row - (num_rows+1)/2), ...
                handles.unit_rot{handles.cur_grid}(cur_row, cur_col), ...
                handles.grid_rot(handles.cur_grid), ...
                handles.wrap_colors{handles.grid_colors{handles.cur_grid}(cur_row, cur_col)}, ...
                handles.unit_shape, ismember(cur_row, handles.cur_sel_row) & ismember(cur_col, handles.cur_sel_col), ...
                handles.grid_loc{handles.cur_grid}(cur_row, cur_col),...
                handles.grid_state{handles.cur_grid}(cur_row, cur_col), ...
                squeeze(handles.grid_elec_numbers{handles.cur_grid}(cur_row, cur_col, :)));
        end
    end
end
hold on;
%Draw the row/column markers
M = makehgtform('zrotate', handles.grid_rot(handles.cur_grid));
for cur_row = 1:num_rows,
    text_pos = [handles.grid_col_spacing(handles.cur_grid)*((num_cols+1)/2), ...
        handles.grid_row_spacing(handles.cur_grid)*(cur_row - (num_rows+1)/2) 0 0];
    text_pos = text_pos*M;
    text(text_pos(1), text_pos(2), ...
        sprintf('%c', 'A' + cur_row - 1), 'FontName', 'Arial', 'FontSize', 24, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    text_pos = [handles.grid_col_spacing(handles.cur_grid)*(-(num_cols+1)/2), ...
        handles.grid_row_spacing(handles.cur_grid)*(cur_row - (num_rows+1)/2) 0 0];
    text_pos = text_pos*M;
    text(text_pos(1), text_pos(2), ...
        sprintf('%c', 'A' + cur_row - 1), 'FontName', 'Arial', 'FontSize', 24, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end
for cur_col = 1:num_cols,
    text_pos = [handles.grid_col_spacing(handles.cur_grid)*(cur_col - (num_cols+1)/2), ...
        handles.grid_row_spacing(handles.cur_grid)*((num_rows+1)/2), 0 0];
    text_pos = text_pos*M;
    text(text_pos(1), text_pos(2), ...
        num2str(cur_col), 'FontName', 'Arial', 'FontSize', 24, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    text_pos = [handles.grid_col_spacing(handles.cur_grid)*(cur_col - (num_cols+1)/2), ...
        handles.grid_row_spacing(handles.cur_grid)*(-(num_rows+1)/2) 0 0];
    text_pos = text_pos*M;
    text(text_pos(1), text_pos(2), ...
        num2str(cur_col), 'FontName', 'Arial', 'FontSize', 24, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end
%Find extreme position
corner_pos = [handles.grid_col_spacing(handles.cur_grid)*(num_cols/2+1) handles.grid_row_spacing(handles.cur_grid)*(num_rows/2+1) 0 0; ...
    -handles.grid_col_spacing(handles.cur_grid)*(num_cols/2+1) handles.grid_row_spacing(handles.cur_grid)*(num_rows/2+1) 0 0; ...
    handles.grid_col_spacing(handles.cur_grid)*(num_cols/2+1) -handles.grid_row_spacing(handles.cur_grid)*(num_rows/2+1) 0 0; ...
    -handles.grid_col_spacing(handles.cur_grid)*(num_cols/2+1) -handles.grid_row_spacing(handles.cur_grid)*(num_rows/2+1) 0 0];
%Rotate it, take maximums to define axis
corner_pos = max(abs(corner_pos*M), [], 1);
axis([corner_pos(1)*[-1 1] corner_pos(2)*[-1 1]]);
axis square
axis off;

%Check to see if Ant/Pos need to be reversed
if handles.grid_is_right_side(handles.cur_grid),
    set(handles.Posterior_label, 'String', 'Pos.');
    set(handles.Anterior_label, 'String', 'Ant.');
else
    set(handles.Posterior_label, 'String', 'Ant.');
    set(handles.Anterior_label, 'String', 'Pos.');
end