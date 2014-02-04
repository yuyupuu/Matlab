classdef bloop < dynamicprops
    properties (SetAccess = protected,SetObservable)%only change through class methods
        currfile;
        currMat;
        currElecData;
        totalDepth;
        subjName = 'subject';
        experimentName = 'experiment';
        
        currentlyLoaded = false;
        
        levelArr;
        
    end
    properties (Dependent = true, SetAccess = protected)
        saveName;
    end
    properties (SetAccess = private, SetObservable)
        %addpaths if neccessary
        %addpath(genpath('C:\Users\Eunice\Documents\MATLAB\ElectrodeTracker v1.1\ETRACKER'))
        

        
        gridFigHandle;
        gFig_h;
        gfLRTB;
        gfP;
        
        lfLRTB;
        lfP;
        levelFigHandle;
        lFig_h;
        
        currdateText;

    end
    events
       switchElectrode
       changeGridOrientation
       valueChanged
    end
    methods
       %%%%%%%%%%%%%%%%
       function obj = bloop()
            if nargin == 0
                
            end
            %hide until ready
            obj.gridFigHandle.fig = figure('visible', 'off','Units','pixels');
            obj.levelFigHandle.fig = figure('visible', 'off','Units','pixels');
            set(obj.levelFigHandle.fig,'menubar','none');
            set(obj.gridFigHandle.fig,'menubar','none');
            
            %default values
            totalDepth = 108;
            obj.currfile = '';
            obj.currElecData = NaN;
            
            %% construct figures
            set(0,'Units','pixels');
            scrsz = get(0,'ScreenSize');
            lbpos = [0,30];
            figwh = [.75*scrsz(3),(scrsz(4)-3*lbpos(2))];
            set(obj.gridFigHandle.fig,'Position', [lbpos(1),lbpos(2),figwh(1),figwh(2)]);
            levFigpos = [lbpos(1)+figwh(1),lbpos(2)];
            levFigwh = [scrsz(3)-figwh(1),figwh(2)+lbpos(2)];
            set(obj.levelFigHandle.fig,'Position',[levFigpos(1),levFigpos(2),levFigwh(1),levFigwh(2)]);
            
            %for use in constructing
            gfPos = get(obj.gridFigHandle.fig,'position');
            lfPos = get(obj.levelFigHandle.fig,'position'); 
            obj.gfP = gfPos;
            obj.lfP = lfPos;
            [gfLeft,gfRight,gfTop,gfBott] = deal(gfPos(1),gfPos(1)+gfPos(3),gfPos(2)+gfPos(4),gfPos(2));
            obj.gfLRTB = [gfLeft,gfRight,gfTop,gfBott];
            
            %ResizeFunction for relative stuff 
            %/////////////still need to edit.........
            %set(obj.gridFigHandle, 'ResizeFcn', {@resizeCallback, gca, fixedMargins, {@myuiFunc, f, 40, 50}});
            %set(obj.levelFigHandle, 'ResizeFcn', {@resizeCallback, gca, fixedMargins, {@myuiFunc, f, 40, 50}});
            
            %% Build Figure without callbacks first, just positions
            %Menus
            obj.gridFigHandle.fileMenu = uimenu(obj.gridFigHandle.fig,'Label','File');
            obj.gridFigHandle.loadNewParamMenu = uimenu(obj.gridFigHandle.fileMenu,'Label','Load New Matrix','Callback',{@loadNewSession_callback});
%            createNewParamMenu = uimenu(fileMenu,'Label','Create New Electrode Matrix','Callback',{});
%            loadPrevSessMenu = uimenu(fileMenu,'Label','Load Previous Session','Callback',{});

%            editMenu = uimenu(obj.gridFigHandle,'Label','Edit');
%            addElectrodeMenu = uimenu(editMenu,'Label','Add Electrode to Current Matrix','Callback',{});
%             obj.menuHandles.loadParamMenu = uimenu(menuHandles.fileMenu,...
%                 'Label','Load Electrode Matrix',...
%                 'Callback',{handles.loadParamFunc,handles});
%             menuHandles.saveParamMenu = uimenu(menuHandles.fileMenu,...
%                 'Label','Save Current State',...
%                 'Callback',{handles.saveStateFunc,handles});
            grid = axes();
            
            %Current Electrode Display box
            offset = scrsz(4) * .3;
            obj.gridFigHandle.currElecAx = axes('parent',obj.gridFigHandle.fig,'Units','pixels','position',[gfRight-255,gfTop-offset,245,offset-10],'GridLineStyle', 'none');
            axis(obj.gridFigHandle.currElecAx,'off');
            obj.gridFigHandle.electrodeGrid = axes('parent',obj.gridFigHandle.fig,'Units','pixels','position',[(gfLeft +30),gfBott+30,(gfRight - gfLeft)*0.7,(gfTop - gfBott)*.85],'GridLineStyle', 'none');
            axis(obj.gridFigHandle.electrodeGrid,'off');
            
            %text fields
            texty = scrsz(4)*.07;
            obj.gridFigHandle.subjField = uicontrol(obj.gridFigHandle.fig,'style','edit','HorizontalAlignment','left','Units', 'pixels',...
                            'position',[gfRight-170,gfTop - texty-offset,150,25]);
            obj.gridFigHandle.expField = uicontrol(obj.gridFigHandle.fig,'style','edit','Units','pixels',...
                            'HorizontalAlignment','left','position',[gfRight-170,gfTop - 1.5*texty - offset,150,25]);
            obj.gridFigHandle.noteField = uicontrol(obj.gridFigHandle.fig,'style','edit','Units','pixels',...
                            'HorizontalAlignment','left','position',[gfRight-170,gfTop - 3.5*texty - offset,150,1.5*texty]...
                            ,'Max',10,'Min',1);
            %labels for text fields
            fieldpos = get(obj.gridFigHandle.subjField,'position');
            subjLabel = uicontrol(obj.gridFigHandle.fig,'style','text','String','Subject','Units', 'pixels',...
                            'position',[fieldpos(1)- 85,fieldpos(2),83,25],'FontSize', 12,'BackgroundColor', [0.8,0.8,0.8],'HorizontalAlignment','Right');
            fieldpos2 = get(obj.gridFigHandle.expField,'position');
            explabel = uicontrol(obj.gridFigHandle.fig,'style','text','String','Experiment','Units','pixels',...
                            'position',[fieldpos2(1)-85,fieldpos2(2),85,25],'FontSize', 12,'BackgroundColor', [0.8,0.8,0.8]); % will become gFig_h.expField
            fieldpos3 = get(obj.gridFigHandle.noteField,'position');
            notelabel = uicontrol(obj.gridFigHandle.fig,'style','text','String','Notes','Units','pixels',...
                            'position',[fieldpos3(1)-85,fieldpos3(2)+fieldpos3(4)/2,83,25],'FontSize', 12,...
                            'BackgroundColor', [0.8,0.8,0.8],'HorizontalAlignment','Right');
            
                        
            %Plus/Minus Buttons
            plusButtX = gfRight - gfPos(3)*0.2;% hahahahaha butt.
            plusButtsz = [gfPos(3)*.05,gfPos(4)*.05];
            obj.gridFigHandle.plusOne = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','+1','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.07,plusButtsz(1),plusButtsz(2)]);
            obj.gridFigHandle.plusFive = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','+5','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.12,plusButtsz(1),plusButtsz(2)]);
            obj.gridFigHandle.plusTen = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','+10','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.17,plusButtsz(1),plusButtsz(2)]);
            minusButtX = gfRight - gfPos(3)*0.1;
            minusButtsz = [gfPos(3)*.05,gfPos(4)*.05];
            obj.gridFigHandle.minusOne = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','-1','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.07,minusButtsz(1),minusButtsz(2)]);
            obj.gridFigHandle.minusFive = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','-5','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.12,minusButtsz(1),minusButtsz(2)]);
            obj.gridFigHandle.minusTen = uicontrol(obj.gridFigHandle.fig,'style','pushbutton','String','-10','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.17,minusButtsz(1),minusButtsz(2)]);

            %Radio Buttons
            buttPos = get(obj.gridFigHandle.minusTen,'position')
            obj.gridFigHandle.cellSelPanel = uibuttongroup(obj.gridFigHandle.fig,'Units','pixels','position',[plusButtX,10,gfRight - plusButtX-10,(buttPos(2) - gfBott -5)],...
                                                        'FontSize', 20);
            obj.gridFigHandle.infoText = uicontrol(obj.gridFigHandle.cellSelPanel,'Units','normalized','position',[0 .9 .97 .1],'style','text','String','*hover for more info',...
                                                'FontSize', 9,'HorizontalAlignment','right','ForegroundColor',[0.75,0.75,0.75]);
            obj.gridFigHandle.radButtsNoise = uicontrol(obj.gridFigHandle.cellSelPanel,'Units','normalized','position',[.1 .75 .85 .15],'style','radiobutton','String','Noisy',...
                                                'FontSize', 15, 'TooltipString','Ungrounded');
            obj.gridFigHandle.radButtsQuiet = uicontrol(obj.gridFigHandle.cellSelPanel,'Units','normalized','position',[.1 .75-.2 .85 .15],'style','radiobutton','String','Quiet',...
                                                'FontSize', 15, 'TooltipString','Grounded, No activity');
            obj.gridFigHandle.radButtsCells = uicontrol(obj.gridFigHandle.cellSelPanel,'Units','normalized','position',[.1 .75-2*.2 .85 .15],'style','radiobutton','String','Cells','FontSize', 15);
            obj.gridFigHandle.radButtsWMat = uicontrol(obj.gridFigHandle.cellSelPanel,'Units','normalized','position',[.1 .75-3*.2 .85 .15],'style','radiobutton','String','White Matter','FontSize', 15);
            
            
            set(obj.gridFigHandle.fig,  'closerequestfcn', @(src,event) Close_fcn(obj, src, event));
            set(obj.levelFigHandle.fig,  'closerequestfcn', @(src,event) Close_fcn(obj, src, event));
            
%             obj.gFig_h = guidata(obj.gridFigHandle.fig);
%             obj.lFig_h = guidata(obj.levelFigHandle.fig);
%             
%             disp(obj.gFig_h)
%             disp(obj.lFig_h)
            
            set(obj.gridFigHandle.fig,'visible','on');
            set(obj.levelFigHandle.fig,'visible','on');
       end
       
      %%%%%%%%%%%% SET / GET FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function obj = set.totalDepth(obj,newdepth)
            obj.totalDepth = newdepth;
       end
       function t = get.totalDepth(obj)
           t = obj.totalDepth;
       end
       function svenme = get.saveName(obj)
           svenme = strcat(obj.experimentName,'_',obj.subjName,'_', getDate('save'));
           
       end
    end
    methods (Access = private)
        function loadNewSession_callback(obj)
            disp('3');
        end
        
       function readInNewMatrix(obj,matrix)
                currID = 1
                %store matrix
                obj.currMat = matrix;
                for r = 1:size(matrix,1)
                    for c = 1:size(matrix,2)
                        if obj.currMat(r,c) == 1
                            [TF,nr,nc]=adjacenttoID(obj.currMat,r,c);
                            if TF %if there is an adjacent number that is a color ID
                                obj.currMat(r,c) = obj.currMat(nr,nc);
                            else
                                currID = currID +1;
                                obj.currMat(r,c) = currID;
                            end
                        end
                    end
                end
                
                %draw in grid
                obj.drawGrid();         
       end
       function obj = newSession(obj)
           fileInfo = questdlg('What type of file?', 'File Info','.mat','image','.mat');
           if strcmpi(fileInfo,'.mat')
                obj.currfile = uigetfile('load');
                obj.currdateText = uicontrol(obj.gridFigHandle.fig,'String', getDate('display'),'Units','Normalized', 'Position',[.95 .95 .4 .4]);
           end
       end
       function obj = loadSession(obj,filename)
              
              obj.currfile = filename 
              obj.saveName = sprintf('%s_%s.m',currfile,datestr(date,'mmddyy'));
       end
       function autosave()
              
       end
       
       %%%%%%%%%%%%%%%%%%%%LISTENER?
       function addButton()
       
       end
       %%%%%%%%%%%%%%%%%%%% CALL BACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
       function onebutton_callback(source, eventdata)
           
       end
       function plusFive(source, eventdata)
            
       end
       function plusTen(source, eventdata)
            
       end
       
       function radio_callback(src,event)% if use this type of callback have to make a function for each button
%             if (get(src,'Value') == get(src,'Max'))
%                 % Radio button is selected-take appropriate action
%             else
%                 % Radio button is not selected-take appropriate action
%             end 
       end
       
       
       %%%%%%%%%%%%% Figure Display Functions %%%%%%%%%%%%%%%%%%%%%%%%%5
       
       function drawGrid(obj)
           matrix = obj.currMat;
           figure(obj.gridFigHandle.fig);
           obj.testTable = uitable('Parent', obj.gridFigHandle.fig, 'Position', [25 25 500 500]);
           set(obj.testTable,'Data',matrix);
           
           obj.drawLevels();
       end
       function drawLevels(obj)
           
       end
       
       %%%%%%%%%%%%%%%%%%%%%
%        function saveAsStateFunc(source, eventdata, handles)
%             %uisave(obj.,saveName);
%        end
        function sobj = saveobj(obj)
            
        end
       function delete(obj, src, event)
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(obj.gridFigHandle.fig,  'closerequestfcn', '');
            set(obj.levelFigHandle.fig,  'closerequestfcn', '');
            %delete the figure
            delete(obj.gridFigHandle.fig);
            delete(obj.levelFigHandle.fig);
            %clear out the pointer to the figure - prevents memory leaks
            obj.gridFigHandle = [];
            obj.levelFigHandle = [];
        end
       function obj = Close_fcn(obj, src, event)
            delete(obj);
       end

    end
end





%%%%%%%%%%%%%%% used functions within class %%%%%%%%%%%%%%%%%%%%55
function today = getDate(option)
    if strcmpi(option, 'display')
        today = datestr(now, 'mm/dd/yy HH:MM:SS');
    elseif strcmpi(option, 'save')
        today = datestr(now, 'mmddyy');
    else 
        today = datestr(now, 'mmddyy');
    end
end



%%
function newx = clip(x, lo, hi)
    if x < lo
        newx = lo;
    elseif x > hi
        newx = hi;
    else
        newx = x;
    end
end
    
function [bool, newr, newc] = adjacenttoID(mat,currr,currc)
        newr = currr;
        newc = currc;
    if mat(clip(currr,1,size(mat,1)), clip(currc-1, 0,size(mat,2)))>1
        bool = true;
        newc = currc-1;
    elseif mat(clip(currr-1,1,size(mat,1)), clip(currc, 0,size(mat,2)))>1
        bool = true;
        newr = currr-1;
    else
        bool = false;
    end
end