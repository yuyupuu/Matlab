classdef blup < handle  
    
    %class properties - access is private so nothing else can access these
    %variables. Useful in different sitionations
    properties (Access = private)
        
        density = 0;
        volume = 0;
        
        gui_h;
        tmpgui_h;
        tmpFig;
        tempFig;
    end
    
    %Open class methods - in this case, it is restricted to the class
    %constructor. These functions can be accessed by calling the class
    %name. 
    %Ex M = gui_class_example(); calls the class contructor
    %
    %M.sub_function() would call the function sub_fnction, in this example,
    %there is no such function defined.
    methods
        
        %function - class constructor - creates and init's the gui
        function this = blup()
            
            %make the gui handle and store it locally
            this.gui_h.tempFig = figure();
            this.gui_h.tmpFig = figure();
            this.gui_h.textD = uicontrol('style','text','string', this.density,...
                                'position',[200,200,50,50]);
            this.gui_h.butt = uicontrol('style','pushbutton','string','+1');
            this.gui_h.plusmen = uimenu(this.gui_h.tmpFig,'Label','+1')
            set(this.gui_h.plusmen, 'callback', @(src, event) butt_callback(this, src, event));
            set(this.gui_h.butt, 'callback', @(src, event) butt_callback(this, src, event));
                                    
                                    
            disp(this.gui_h);
%             
%             %set the callback functions to the two edit text box's
%             set(this.gui_h.density_box, 'callback', @(src, event) Edit_density(this, src, event));
%             set(this.gui_h.volume_box , 'callback', @(src, event) Edit_volume(this, src, event));
%             
%             %set the callback functions to the two buttons (calculate &
%             %reset)
%            
%             set(this.gui_h.reset_btn,     'callback', @(src, event) Reset_callback   (this, src, event));
%             
%             %Set the selection change Fcn for the radio button box. This
%             %function will be called when the selection changes within the
%             %box
%             set(this.gui_h.unitgroup, 'selectionchangefcn', @(src, event) Ui_callback      (this, src, event));
%             
%             %sets the figure close function. This lets the class know that
%             %the figure wants to close and thus the class should cleanup in
%             %memory as well
%             set(this.gui_h.figure1,  'closerequestfcn', @(src,event) Close_fcn(this, src, event));
%             
%             %reset the gui (not needed, but this is used to duplicate the
%             %functionality of the matlab example)
%             this = Reset(this);
            
        end
        
    end
    
    
    %Private Class Methods - these functions can only be access by the
    %class itself.
    methods (Access = private)
        
        %class deconstructor - handles the cleaning up of the class &
        %figure. Either the class or the figure can initiate the closing
        %condition, this function makes sure both are cleaned up
        function delete(this)
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(this.tempFig,  'closerequestfcn', '');
            set(this.tmpFig,  'closerequestfcn', '');
            %delete the figure
            delete(this.tempFig);
            delete(this.tmpFig);
            %clear out the pointer to the figure - prevents memory leaks
            this.gui_h = [];
            this.tmpgui_h = [];
        end
        
        %function - Close_fcn
        %
        %this is the closerequestfcn of the figure. All it does here is
        %call the class delete function (presented above)
        function this = Close_fcn(this, src, event)
            delete(this);
        end
        
        
        function this = butt_callback(this, src,event)
            this.density = this.density+1;
            set(this.gui_h.textD, 'string', this.density);
        end
        
        
        %function - Reset
        %
        %resets the gui to initial values. Called from the Reset_btn
        %callback and when the gui init's.
        %This function is mainly kept to mirror the functionality of the
        %MATLAB guide example
        function this = Reset(this)
            
            this.density = 0;
            this.volume  = 0;
            
            set(this.gui_h.density_box, 'String', this.density);
            set(this.gui_h.volume_box,  'String', this.volume);
            set(this.gui_h.mass_box, 'String', 0);
            
            set(this.gui_h.unitgroup, 'SelectedObject', this.gui_h.english_radio_btn);
            
            set(this.gui_h.text4, 'String', 'lb/cu.in');
            set(this.gui_h.text5, 'String', 'cu.in');
            set(this.gui_h.text6, 'String', 'lb');
        end
        
        %function - Reset_callback
        %
        %the callback function for the reset button. This simply calls
        %Reset function directly
        function this = Reset_callback(this, src, event)
            this = Reset(this);
        end
        
        %function - calculate_callback
        %
        %calulates the mass based on the volume & density - displayes the
        %result to the screen
        function this = Calculate_callback(this, src, event)
            mass = this.density * this.volume;
            set(this.gui_h.mass_box, 'String', mass);
        end
        
        %function - Edit_volume
        %
        %callback to the Volume edit box - when the value within the box is
        %changed, this function is called.
        function this = Edit_volume(this, src, event)
            %read in the value from the edit box.
            vol = str2double(get(this.gui_h.volume_box, 'String'));
            %check to see if the value is a number
            if isnan(vol)
                %if not, reset the volume value 
                this.volume = 0;
                set(this.gui_h.volume_box, 'String', 0);
                errordlg('Input must be a number','Error');
            else
                %else, the value is a number, store it
                this.volume = vol;
            end
        end
        
        %function - Edit_density
        %
        %callback to the density edit box - when the value within the box is
        %changed, this function is called.
        function this = Edit_density(this, src, event)
            %read in the value from the edit box
            den = str2double(get(this.gui_h.density_box, 'String'));
            %check to see if the value is a number
            if isnan(den)
                %if not, reset the value
                this.density = 0;
                set(this.gui_h.density_box, 'String', 0);
                errordlg('Input must be a number','Error');
            else
                %else, the value is a number, store it
                this.density = den;
            end
            
        end
        
        %function - ui_callback
        %
        % Callback for the unitcontrol box. This function is called when
        % one of the radio buttons is pushed. The events of this function
        % mirror the effects of the default MATLAB gui example
        function this = Ui_callback(this, src, event)
            
            %obtain the value of the selected radio button
            selected_btn = event.NewValue;
            
            %set us a switch/case to handle the two current possible choises
            switch selected_btn
                case this.gui_h.english_radio_btn
                    set(this.gui_h.text4, 'String', 'lb/cu.in');
                    set(this.gui_h.text5, 'String', 'cu.in');
                    set(this.gui_h.text6, 'String', 'lb');
                case this.gui_h.si_radio_btn
                    set(this.gui_h.text4, 'String', 'kg/cu.m');
                    set(this.gui_h.text5, 'String', 'cu.m');
                    set(this.gui_h.text6, 'String', 'kg');
            end
        end
        
    end
    
end