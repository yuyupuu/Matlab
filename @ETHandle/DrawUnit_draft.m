function DrawUnit(x_pos, y_pos, rot, grid_rot, col, unit_shape, sel, cur_loc, cur_state, elec_nums)

%Create unit variables (with main centered at zero
angs = [0:pi/20:2*pi]';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
                                                
%Main circle
x_vals = sin(angs).*unit_shape(1);
y_vals = cos(angs).*unit_shape(1);

%Rotate it within itself
M = makehgtform('zrotate', rot);
pos = zeros(length(x_vals), 4);
pos(:,1) = x_vals; pos(:,2) = y_vals;
pos = pos*M;

%Move it to our absolute location
pos(:,1) = pos(:,1) + x_pos;
pos(:,2) = pos(:,2) + y_pos;

%Do absolute rotation
M = makehgtform('zrotate', grid_rot);
pos = pos*M;
center_pos = [x_pos y_pos 0 0];
center_pos = center_pos*M;

%Plot it and fill it
fill(pos(:,1), pos(:,2), col);
hold on;

%If selected, highlight it
if sel,
    plot(pos(:, 1), pos(:,2), 'Color', [1 1 0], 'LineWidth', 3);
end

%Add location information
loc_state_str = sprintf('%3.0f', cur_loc);
switch cur_state
    case 0
        loc_state_str = sprintf('%s\n(N)', loc_state_str);
    case 1
        loc_state_str = sprintf('%s\n(Q)', loc_state_str);
    case 2
        loc_state_str = sprintf('%s\n(C)', loc_state_str);
    case 3
        loc_state_str = sprintf('%s\n(WM)', loc_state_str);
end
text(center_pos(1), center_pos(2), loc_state_str, 'HorizontalAlignment', 'center');


%Now loop through unit shape to
num_aux_circ = (length(unit_shape) - 1)/3;
for i = 1:num_aux_circ,
    cur_shape = unit_shape((i-1)*3 + 1 + [1:3]);
    x_vals = sin(angs).*cur_shape(3) + cur_shape(1);
    y_vals = cos(angs).*cur_shape(3) + cur_shape(2);
    
    %Rotate it
    M = makehgtform('zrotate', rot);
    pos = zeros(length(x_vals), 4);
    pos(:,1) = x_vals; pos(:,2) = y_vals;
    pos = pos*M;
    
    %Move it to our absolute location
    pos(:,1) = pos(:,1) + x_pos;
    pos(:,2) = pos(:,2) + y_pos;
    
    %Do absolute rotation
    M = makehgtform('zrotate', grid_rot);
    pos = pos*M;
    
    %Plot it and fill it
    fill(pos(:,1), pos(:,2), col);
    hold on;
    
    %If selected, highlight it
    if sel,
        plot(pos(:, 1), pos(:,2), 'Color', [1 1 0], 'LineWidth', 3);
    elseif (cur_loc < 0),
        switch cur_state,
            case 1
                plot(pos(:, 1), pos(:,2), 'Color', [1 0.3 0.3], 'LineWidth', 3);
            case 2
                plot(pos(:, 1), pos(:,2), 'Color', [0 1 0.2], 'LineWidth', 3);
            case 3
                plot(pos(:, 1), pos(:,2), 'Color', [0.2 0.8 0.8], 'LineWidth', 3);
            otherwise
                plot(pos(:, 1), pos(:,2), 'Color', [0.7 0 1], 'LineWidth', 3);
        end
    end                                                                                                                                                                                             
    
    %If possible, put electrode number in the circle
    if ~isempty(elec_nums) & ~isnan(elec_nums(i)),
        text(mean(pos(:,1)), mean(pos(:,2)), num2str(elec_nums(i)), 'HorizontalAlignment', 'center');
    end
end
