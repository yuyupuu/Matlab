function ETGui
    %%addPaths of Callbacks
    %addpath(insert folder link(s) for callbacks, variables, mat files, etc)
    addpath('C:\Users\Eunice\Documents\MATLAB\ElectrodeTracker v1.1\ETRACKER');
    
    %% define handles to be used across figures
    %functions
    handles = createHandlesDraft();%set default and neccesary handles at first
%     handles.onebutton_callback = @plusOne
%     handles.keyPress_callback = @WindowKeyPressFcn
    %other variables
    
    
    %% create windows
    set(0,'Units','normalized')
    scrsz = get(0,'ScreenSize') %to create handle for something, do [inserthandle] = @[insert function name(without input parameters?) or figure/other handle]
    lbpos = [0,.05];%distance of gridfig from bottom left of screen
    figwh = [.75,(scrsz(4)-lbpos(2)-.1)];%gridfig is left side of screen, levelfig is right side of screen
    handles.gridFig = figure('Units','normalized',...
        'Position', [lbpos(1),lbpos(2),figwh(1),figwh(2)],...
        'Visible', 'on','KeyPressFcn',{@handles.keyPress_callback,handles});
    % in python to call on elements of array, use [], but here, use ()
    %also indexing starts from one
    
    %create figure for layer/electrode depth information
    %right next to gridFig
    levFigpos = [lbpos(1)+figwh(1),lbpos(2)];
    levFigwh = [scrsz(3)-figwh(1),figwh(2)];
    handles.levelFig = figure('Units','normalized',...
        'Position',[levFigpos(1),levFigpos(2),levFigwh(1),levFigwh(2)],...
        'Selected','off','KeyPressFcn',{@keyPress_callback});
    
    
    
    
    %% construct levelFig
    figure(handles.levelFig);
    
    %when no file is selected
    handles.textF = uicontrol('Style','text','String','0','Units','normalized','Position',[.5 .5 .1 .1]);%to test interaction between windows....:D
    handles.textH = uicontrol('Style','text','String','No File Selected Yet. (Also Function not ready yet)','Units','normalized','Position',[.65 .65 .15 .15]);
    
    %handles.levels = handles.drawLevels(handles)
    
    
    %% construct gridFig
    figure(handles.gridFig)%Makes active gridFig
    
    % File Menu
    handles.fileMenu = uimenu(handles.gridFig,'Label','File');
    handles.loadParamMenu = uimenu(handles.fileMenu,...
                'Label','Load Electrode Matrix',...
                'Callback',{handles.loadParamFunc,handles});
    handles.saveParamMenu = uimenu(handles.fileMenu,...
                'Label','Save Current State',...
                'Callback',{handles.saveStateFunc,handles});
            
    %make Grid Area
    handles.grid = axes('Units','normalized','Position',[.05,.05,.2,.2]);
    axis off;
    
    %construct add/subtract buttons
    handles.default = uipanel('Position',[0 0 .2 1]);
    handles.plusbuttons = uibuttongroup('parent',handles.default,'Position',[0 0 1 .25]);%units are normalized for button group position!
%     handles.textF = uicontrol('Style','text','String','0','Position',[300,300, 40,20])
    handles.onebutton = uicontrol('parent',handles.plusbuttons,'Style', 'pushbutton',...
                'Callback',{handles.onebutton_callback,handles}, ...
                'String','+1', 'Units','normalized');
	handles.fivebutton = uicontrol('parent',handles.plusbuttons,'Style', 'pushbutton',...
                 'Callback',{handles.fivebutton_callback,handles}, ...
                 'String','+5');
    handles.tenbutton = uicontrol('parent',handles.plusbuttons,'Style', 'pushbutton',...
                 'Callback',{handles.tenbutton_callback,handles}, ...
                 'String','+10');
    align([handles.tenbutton,handles.fivebutton,handles.onebutton],'Left','Fixed',.01);
    
    
    
    
end