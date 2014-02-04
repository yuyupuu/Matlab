function ETsearch(goalTest,matrix)
    currNode = startNode;
    reGrid = zeros(size(matrix));
    electrodegroups = 0;
    visitArr = [];%(array of visited nodes)
    
    for r = 1:size(matrix,1)
        for c = 1:size(matrix,2)
           
           if ismember(currNode,visitArr) %if currNode has already been visited, skip it
              continue;
           else if matrix(r,c)== 0
               visitArr = horzcat(visitArr,ETSearchNode([r,c],size(matrix)));%add the index of a zero element to the visited array so we don't look at it again
           else % if it is a 1 that we have not visited yet, then we need to expand it
               electrodegroups = electrodegroups + 1; %discovered new group!
               
               %start new search for breadth of group
               newStartNode = ETSearchNode([r,c],size(matrix));
               [added,ETGrpCoo] = getCurrGroup(visitArr,matrix,newStartNode);
               % add newly visited-labeled nodes to visitArr
               visitArr = added;
               
               %give corresponding new color ID(in form of integer 1, 2,3,
               %etc) to new electrode in grid
               reGrid = setGridColIDs(reGrid,ETGrpCoo,electrodegroups);
               
               %add currNode.rc to visited coordinates
               %visitArr = horzcat(visitArr,currNode);
           end
        end
    end
end

function [newVisited, groupCoords]= getCurrGroup(visited, matrixF, startNode2)
    newVisited = visited;
    groupCoords = [];%will be vertical array of pairs
    thisNode = startNode2;
    searchList = [];
    while true
        currChildren = thisNode.getChildren()
        checkResults = checkMembers(currChildren,newVisited);
        
        for 1:numels(currChildren)
        if checkResults{1}% if any of children nodes are 
            
        end
    end
    
    
end

function newgrid = setGridColIDs(newgrid,currgroup,colID)% currgroup will be vertical array of pairs
    for i = 1:size(currgroup,1) %number of rows, aka number of pairs
        newgrid(currgroup(i,1),currgroup(i,2)) = colID;
    end
end

function bool = checkMembers(nodeArray, compareArray)        % find if any children nodes are inside the visited array, True if they all are, false if any of them aren't
    for i = 1:numel(nodeArray)
        for j = 1:numel(compareArray)
            if nodeArray(i).isSameNodePos(compareArray(j))
                
            
end
%search until find a 1
    %conduct search around this one to get all touching ones
    %return the coordinates 
    %set all the numbers at thesese coordinates to current electrode group number
    %