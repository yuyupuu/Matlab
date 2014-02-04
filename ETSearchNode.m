classdef ETSearchNode
    properties
        rc;%(row, col)
        parent;
        maxrc;%(max row, max col)
    end
    methods
        function obj = ETSearchNode(currrc,matrixsize, parentNode)%ETSearchNode((row, col), ETSearchNode Instance, (maximumrow, maximum col))
            if nargin == 2:
                obj.parent = '';
            else
                obj.parent = parentNode;
            end
            obj.rc = currrc;
            obj.maxrc = matrixsize;
        end
        function childList = getChildren(obj) % return array of search nodes
           childList = [];
           
           for i = -1:2:1
               r = obj.rc(1) + i;% so we will go from r-1 to r+1
               for j = -1:2:1
                   c = obj.rc(2) + j;
                   if r > 0 && r <= maxrc(1) && c > 0 && c<=maxrc(2)
                        childList(end+1) = ETSearchNode((r,c),obj.maxrc,obj);
                   end
               end
           end
           
        end
        function path = getPath(obj)
            if obj.parent == ''
                path = [obj];
                return
            else
                path = horzcat(obj.getPath(),[obj]);
            end
        function bool = isSameNodePos(obj,node2)%returns true if node1.rc = node2.rc
            bool = (obj.rc==node2.rc);
        end
    end
end