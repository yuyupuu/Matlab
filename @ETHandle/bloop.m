classdef bloop < dynamicprops
   properties(SetAccess = protected,SetObservable)
       subjName = 'subject';
       experimentName = 'experiment';
       
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
   methods
       function obj = bloop()
           obj.gridFigHandle = figure();
           
       end
       
   end
    
end