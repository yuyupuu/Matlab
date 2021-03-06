function [handles] = createHandlesDraft()
    %addpaths if neccessary
    addpath(genpath('C:\Users\Eunice\Documents\MATLAB\ElectrodeTracker v1.1\ETRACKER'))
    
    %% callback functions
    %default buttons/fields
    handles.onebutton_callback = @plusOne;
    handles.fivebutton_callback = @plusFive;
    handles.tenbutton_callback = @plusTen;
    
    handles.loadParamFunc = @loadParamFunc;
    handles.drawGrid = @drawGridFunc
    handles.saveStateFunc = @saveAsStateFunc;
    
    handles.getHandlesFunc = @getHandles;
    
    handles.keyPress_callback = @WindowKeyPressFcn;
    
    %% other variables
    handles.totalDepth = 108;
    
    handles.currfile = '';
    
    %default colors
    handles.electrodeColors{1} = [1 0 0];%[red yellow green blue white black purple]
    handles.electrodeColors{2} = [1 1 0];%yellow
    handles.electrodeColors{3} = [0 1 0];%green
    handles.electrodeColors{4} = [0 0 1];%blue
    handles.electrodeColors{5} = [1 1 1];%white
    handles.electrodeColors{6} = [0 0 0];%black
    
    
    %Perhaps list out all other handles in comments, to keep track/make
    %changes easier
    %
    %
    %
end