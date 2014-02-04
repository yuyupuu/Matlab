classdef ETHandletwo < dynamicprops
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
       function obj = ETHandletwo()
            if nargin == 0
                
            end
            %hide until ready
            gridFigHandle = figure('visible', 'off','Units','pixels');
            levelFigHandle = figure('visible', 'off','Units','pixels');
            set(levelFigHandle,'menubar','none');
            set(gridFigHandle,'menubar','none');
            
            %default values
            totalDepth = 108;
            obj.currfile = '';
            obj.currElecData = NaN;
            
            %% construct figures
            set(0,'Units','pixels');
            scrsz = get(0,'ScreenSize');
            lbpos = [0,30];
            figwh = [.75*scrsz(3),(scrsz(4)-3*lbpos(2))];
            set(gridFigHandle,'Position', [lbpos(1),lbpos(2),figwh(1),figwh(2)]);
            levFigpos = [lbpos(1)+figwh(1),lbpos(2)];
            levFigwh = [scrsz(3)-figwh(1),figwh(2)+lbpos(2)];
            set(levelFigHandle,'Position',[levFigpos(1),levFigpos(2),levFigwh(1),levFigwh(2)]);
            
            %for use in constructing
            gfPos = get(gridFigHandle,'position');
            lfPos = get(levelFigHandle,'position'); 
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
            fileMenu = uimenu(obj.gridFigHandle,'Label','File');
            loadNewParamMenu = uimenu(fileMenu,'Label','Load New Matrix','Callback',{@loadNewSession_callback});
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
            grid = axes()
            
            %Current Electrode Display box
            offset = scrsz(4) * .3;
            currElecAx = axes('parent',gridFigHandle,'Units','pixels','position',[gfRight-255,gfTop-offset,245,offset-10],'GridLineStyle', 'none');
            axis(currElecAx,'off');
            electrodeGrid = axes('parent',gridFigHandle,'Units','pixels','position',[(gfLeft +30),gfBott+30,(gfRight - gfLeft)*0.7,(gfTop - gfBott)*.85],'GridLineStyle', 'none');
            axis(electrodeGrid,'off');
            
            %text fields
            texty = scrsz(4)*.07;
            subjField = uicontrol(gridFigHandle,'style','edit','HorizontalAlignment','left','Units', 'pixels',...
                            'position',[gfRight-170,gfTop - texty-offset,150,25]);
            expField = uicontrol(gridFigHandle,'style','edit','Units','pixels',...
                            'HorizontalAlignment','left','position',[gfRight-170,gfTop - 1.5*texty - offset,150,25]);
            noteField = uicontrol(gridFigHandle,'style','edit','Units','pixels',...
                            'HorizontalAlignment','left','position',[gfRight-170,gfTop - 3.5*texty - offset,150,1.5*texty]...
                            ,'Max',10,'Min',1);
            %labels for text fields
            fieldpos = get(subjField,'position');
            subjLabel = uicontrol(gridFigHandle,'style','text','String','Subject','Units', 'pixels',...
                            'position',[fieldpos(1)- 85,fieldpos(2),83,25],'FontSize', 12,'BackgroundColor', [0.8,0.8,0.8],'HorizontalAlignment','Right');
            fieldpos2 = get(expField,'position');
            explabel = uicontrol(gridFigHandle,'style','text','String','Experiment','Units','pixels',...
                            'position',[fieldpos2(1)-85,fieldpos2(2),85,25],'FontSize', 12,'BackgroundColor', [0.8,0.8,0.8]); % will become gFig_h.expField
            fieldpos3 = get(noteField,'position');
            notelabel = uicontrol(gridFigHandle,'style','text','String','Notes','Units','pixels',...
                            'position',[fieldpos3(1)-85,fieldpos3(2)+fieldpos3(4)/2,83,25],'FontSize', 12,...
                            'BackgroundColor', [0.8,0.8,0.8],'HorizontalAlignment','Right');
            
                        
            %Plus/Minus Buttons
            plusButtX = gfRight - gfPos(3)*0.2;% hahahahaha butt.
            plusButtsz = [gfPos(3)*.05,gfPos(4)*.05];
            plusOne = uicontrol(gridFigHandle,'style','pushbutton','String','+1','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.07,plusButtsz(1),plusButtsz(2)]);
            plusFive = uicontrol(gridFigHandle,'style','pushbutton','String','+5','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.12,plusButtsz(1),plusButtsz(2)]);
            plusTen = uicontrol(gridFigHandle,'style','pushbutton','String','+10','Position',[plusButtX,fieldpos3(2) - gfPos(4)*.17,plusButtsz(1),plusButtsz(2)]);
            minusButtX = gfRight - gfPos(3)*0.1;
            minusButtsz = [gfPos(3)*.05,gfPos(4)*.05];
            minusOne = uicontrol(gridFigHandle,'style','pushbutton','String','-1','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.07,minusButtsz(1),minusButtsz(2)]);
            minusFive = uicontrol(gridFigHandle,'style','pushbutton','String','-5','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.12,minusButtsz(1),minusButtsz(2)]);
            minusTen = uicontrol(gridFigHandle,'style','pushbutton','String','-10','Position',[minusButtX,fieldpos3(2) - gfPos(4)*.17,minusButtsz(1),minusButtsz(2)]);

            %Radio Buttons
            buttPos = get(minusTen,'position')
            cellSelPanel = uibuttongroup(gridFigHandle,'Units','pixels','position',[plusButtX,10,gfRight - plusButtX-10,(buttPos(2) - gfBott -5)],...
                                                        'FontSize', 20);
            infoText = uicontrol(cellSelPanel,'Units','normalized','position',[0 .9 .97 .1],'style','text','String','*hover for more info',...
                                                'FontSize', 9,'HorizontalAlignment','right','ForegroundColor',[0.75,0.75,0.75]);
            radButtsNoise = uicontrol(cellSelPanel,'Units','normalized','position',[.1 .75 .85 .15],'style','radiobutton','String','Noisy',...
                                                'FontSize', 15, 'TooltipString','Ungrounded');
            radButtsQuiet = uicontrol(cellSelPanel,'Units','normalized','position',[.1 .75-.2 .85 .15],'style','radiobutton','String','Quiet',...
                                                'FontSize', 15, 'TooltipString','Grounded, No activity');
            radButtsCells = uicontrol(cellSelPanel,'Units','normalized','position',[.1 .75-2*.2 .85 .15],'style','radiobutton','String','Cells','FontSize', 15);
            radButtsWMat = uicontrol(cellSelPanel,'Units','normalized','position',[.1 .75-3*.2 .85 .15],'style','radiobutton','String','White Matter','FontSize', 15);
            
            
            set(gridFigHandle,  'closerequestfcn', @(src,event) Close_fcn(obj, src, event));
            set(levelFigHandle,  'closerequestfcn', @(src,event) Close_fcn(obj, src, event));
            
            obj.gFig_h = guihandles(gridFigHandle)
            obj.lFib_h = guihandles(levelFigHandle)
            
            set(gridFigHandle,'visible','on');
            set(levelFigHandle,'visible','on');
       end
       
      %%%%%%%%%%%% SET / GET FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function obj = set.totalDepth(obj,newdepth)
            obj.totalDepth = newdepth
       end
       function t = get.totalDepth(obj)
           t = obj.totalDepth
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
                obj.currdateText = uicontrol(obj.gFig_h.gridFigHandle,'String', getDate('display'),'Units','Normalized', 'Position',[.95 .95 .4 .4]);
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
           figure(obj.gFig_h.gridFigHandle);
           obj.testTable = uitable('Parent', gridFigHandle, 'Position', [25 25 500 500]);
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
            set(obj.gFig_h.gridFigHandle,  'closerequestfcn', '');
            set(obj.lFig_h.levelFigHandle,  'closerequestfcn', '');
            %delete the figure
            delete(obj.gFig_h.gridFigHandle);
            delete(obj.lFig_h.levelFigHandle);
            %clear out the pointer to the figure - prevents memory leaks
            obj.gFig_h = [];
            obj.lFig_h = [];
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