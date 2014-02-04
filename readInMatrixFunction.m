%function for reading in a new electrode matrix. Will also be functions for creating 
%a new electrode array within gui and 
%function for loading previously read in/modified 
function newMatrix = readInMatrixFunction(matrix)
    currID = 1
    newMatrix = matrix;
    for r = 1:size(matrix,1)
        for c = 1:size(matrix,2)
            if newMatrix(r,c) == 1
                [TF,nr,nc]=adjacenttoID(newMatrix,r,c);
                if TF %if there is an adjacent number that is a color ID
                    newMatrix(r,c) = newMatrix(nr,nc);
                    %then check for any 1s around it and change nums too
                    
                else
                    currID = currID +1;
                    newMatrix(r,c) = currID;
                    if newMatrix(clip(r+1,1,size(newMatrix,1)),c) == 1
                        newMatrix(r+1,c) = newMatrix(r,c);
                    end
                    if newMatrix(r,clip(c+1,1,size(newMatrix,2))) == 1
                        newMatrix(r,c+1) = newMatrix(r,c);
                    end
                end
                
            end
        end
    end
    
end
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


% function newMatrix = readInMatrixFunction(matrix)
%     currID = 1
%     newMatrix = matrix;
%     for r = 1:size(matrix,1)
%         for c = 1:size(matrix,2)
%             if newMatrix(r,c) == 1
%                 [TF,nr,nc]=adjacenttoID(newMatrix,r,c);
%                 if TF %if there is an adjacent number that is a color ID
%                     newMatrix(r,c) = newMatrix(nr,nc);
%                 else
%                     currID = currID +1;
%                     newMatrix(r,c) = currID;
%                 end
%                 
%             end
%         end
%     end
%     
% end