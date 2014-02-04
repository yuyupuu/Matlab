classdef ETHandle < dynamicprops
    properties (SetAccess = protected,SetObservable)%only change through class methods
        currfile;%file containing matrix and any other necessary variables
        currMat;%edited matrix after reading in ElecData
        currElecData; %matrix of 0s and 1s
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
        
        numElectrodes;
        
        IDPos;
        
        elecInfo;
        
        gridFigHandle;
        gFig_h;
        gfLRTB;
        gfP;
        
        lfLRTB;
        lfP;
        levelFigHandle;
        lFig_h;
        
        currdateText;

        %% electrode Colors
%         electrodeColors{1} = [1 0 0];%[red yellow green blue white black purple]
%         electrodeColors{2} = [1 1 0];%yellow
%         electrodeColors{3} = [0 1 0];%green
%         electrodeColors{4} = [0 0 1];%blue
%         electrodeColors{5} = [1 1 1];%white
%         electrodeColors{6} = [0 0 0];%black

    end
    events
       switchElectrode
       changeGridOrientation
       valueChanged
    end
    methods
       %%%%%%%%%%%%%%%%
       function obj = ETHandle()
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
            obj.numElectrodes = 0;
            
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
            obj.gridFigHandle.loadNewParamMenu = uimenu(obj.gridFigHandle.fileMenu,'Label','Load New Matrix');
            set(obj.gridFigHandle.loadNewParamMenu,'callback', @(src, event) loadNewSession_callback(obj, src, event));
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
            
            %Current Electrode Display box
            offset = scrsz(4) * .3;
            obj.gridFigHandle.currElecAx = axes('parent',obj.gridFigHandle.fig,'Units','pixels','position',[gfRight-255,gfTop-offset,245,offset-10],'GridLineStyle', 'none');
            axis(obj.gridFigHandle.currElecAx,'off');
            obj.gridFigHandle.electrodeGrid = axes('parent',obj.gridFigHandle.fig,'Units','pixels', 'HitTest', 'off','position',[(gfLeft +30),gfBott+30,(gfRight - gfLeft)*0.7,(gfTop - gfBott)*.85],'GridLineStyle', 'none');
            axis(obj.gridFigHandle.electrodeGrid,'off');
            set(obj.gridFigHandle.electrodeGrid,'ButtonDownFcn','disp(''axis callback'')');
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
%         function isLoadedBool = checkLoaded(obj)
%             if ~strcmpi(obj.currfile, ''),
%                 button = questdlg('There is already a file loaded.  Replace?', 'Replace existing?', 'Yes', 'No', 'No');
%                 if ~strcmpi(button, 'yes'),
%                     %do nothing
%                     return ;
%                 end
%             end
%             [FileName,PathName] = uigetfile('../*.mat', 'Select Electrode Matrix...');
%             if ~isstr(FileName) & (FileName == 0),
%                 %do nothing
%                 warndlg('No file selected.');
%                 return;
%             end
%             obj.currfile = sprintf('%s\\%s', PathName, FileName) 
%         end
        function obj = loadNewSession_callback(obj,src,event)
            disp('Testing.....');
            if ~strcmpi(obj.currfile, ''),
                button = questdlg('There is already a file loaded.  Replace?', 'Replace existing?', 'Yes', 'No', 'No');
                if ~strcmpi(button, 'yes'),
                    %do nothing
                    return ;
                end
            end
            [FileName,PathName] = uigetfile('../*.mat', 'Select Electrode Matrix...');
            if ~isstr(FileName) & (FileName == 0),
                %do nothing
                warndlg('No file selected.');
                return;
            end
            obj.currfile = sprintf('%s\\%s', PathName, FileName) 
            
            matdata = load(obj.currfile);
            fileVars = whos('-file',obj.currfile);
            matName = 'electrodeMat';
            if ismember(matName,{fileVars.name}) == 1 && isinteger(matdata.electrodeMat)
                obj.currElecData = matdata.electrodeMat;
            else        
                display('''electrodeMat'' is not in File')
                matName = inputdlg('What is the name of your electrode matrix variable?', 'Variable ''electrodeMat'' is not in loaded file or unusable' );
                while ~ismember(matName{1},{fileVars.name}) 
                    %until the entered name othe matrix exists in the file and is a matrix containing integers
                    matName = inputdlg('What is the name of your electrode matrix variable?', ['Variable ' matName{1} ' is not in loaded file or unusable'] );
                    try 
                        if isinteger(matdata.(matName{1}))
                            break
                        end
                    catch err
                        continue
                    end
                end
                display(matName{1});
                obj.currElecData = load(obj.currfile,matName{1});%matrix of zeroes and ones
            end
            obj.currElecData = obj.currElecData.(matName{1});
            
            obj.readInNewMatrix(obj.currElecData);
    
        end
        
       function readInNewMatrix(obj,matrix)
                currID = 1;
                %store matrix
                obj.currMat = matrix;
                for r = 1:size(matrix,1)
                    for c = 1:size(matrix,2)
                        if obj.currMat(r,c) == 1
                            [TF,nr,nc]=adjacenttoID(obj.currMat,r,c);
                            if TF %if there is an adjacent number that is a color ID
                                obj.currMat(r,c) = obj.currMat(nr,nc);
                                %then check for any 1s around it and change nums too

                            else
                                currID = currID +1;
                                obj.currMat(r,c) = currID;
                                if obj.currMat(clip(r+1,1,size(obj.currMat,1)),c) == 1
                                    obj.currMat(r+1,c) = obj.currMat(r,c);
                                end
                                if obj.currMat(r,clip(c+1,1,size(obj.currMat,2))) == 1
                                    obj.currMat(r,c+1) = obj.currMat(r,c);
                                end
                            end
                            obj.IDPos.x(currID)= obj.IDPos.x(currID)+c;
                            obj.IDPos.y(currID)= obj.IDPos.y(currID)+r;
                        end
                    end
                end
                obj.numElectrodes = currID-1;
                
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
           axis(obj.gridFigHandle.electrodeGrid);
           cla(gca);
           axMeasurements = get(gca,'position');
           %a = [1,2,3,4,5,6,7,8,9,10;11,12,13,14,15,16,17,18,19,20;21,22,23,24,25,26,27,28,29,30;31,32,33,34,35,36,37,38,39,40;41,42,43,44,45,46,47,48,49,50;51,52,53,54,55,56,57,58,59,60]
           a = obj.currMat;
           xInc = axMeasurements(3)/size(a,2);%length of x axis/number of columns = increment between columns
           yInc = axMeasurements(4)/size(a,1);%length of yaxis/number of rows = increment between rows
           
           figure(obj.gridFigHandle.fig);
%            obj.testTable = uitable('Parent', obj.gridFigHandle.fig, 'Position', [25 25 500 500]);
%            set(obj.testTable,'Data',matrix);
           axTop = axMeasurements(4);
           [x,y] = meshgrid(1:size(a,2),1:size(a,1));
           x = axMeasurements(1)+x*xInc;
           y = axTop - y*yInc;
           for i = 1:numel(x)
               if a(i) ~= 0
                    b = text(x(i),y(i),num2str(a(i)),'horizontalalignment','center','HitTest', 'off','tag','b');
               end
           end
           set(gca,'xlim',[min(x(:))-1 max(x(:))+1],'ylim',[min(y(:))-1 max(y(:))+1]);
%            set(b,'buttondownfcn','get(gco,''position'')')
           
           obj.drawLevels();
           
       end
       function drawLevels(obj)
           figure(obj.levelFigHandle.fig);
           
       end
       function setElecInfo(obj, elecID, value)
           obj.elecInfo(elecID) = value;
       end
       function [centerCoordX,centerCoordY] = findCenterMass(obj, giveID)
            for                                                                                                                                                                                                                                                            &"
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
    elseif mat(clip(currr+1,1,size(mat,1)), clip(currc, 0,size(mat,2)))>1
        bool = true;
        newr = currr+1;
    elseif mat(clip(currr,1,size(mat,1)), clip(currc+1, 0,size(mat,2)))>1
        bool = true;
        newc = currc+1;
    else
        bool = false;
    end
end

