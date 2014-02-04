function newMatrix = reGridFunc(matrix)
    currID = 1
    newMatrix = matrix;
    for r = 1:size(matrix,1)
        for c = 1:size(matrix,2)
            if newMatrix(r,c) == 1
                [TF,nr,nc]=adjacenttoID(newMatrix,r,c);
                if TF %if there is an adjacent number that is a color ID
                    newMatrix(r,c) = newMatrix(nr,nc);
                else
                    currID = currID +1;
                    newMatrix(r,c) = currID;
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
    else
        bool = false;
    end
end
        
        
        
        
% function recET(initr,initc):
%     row = r+1;
%     col = c-1;
%     if row <= size(matrix,1) && col > 0 && matrix(row,col) == 1
%         matrix(row,col) = currID;
%     end
%     col = c+1;
%     if row <= size(matrix,1) && col  <= size(matrix,1) && matrix(row,col) == 1
%         matrix(row,col) = currID;
%     end
%     row = r-1;
%     if row > 0 && col  <= size(matrix,1) && matrix(row,col) == 1;
%         matrix(row,col) = currID;
%     end
%     col = c-1;
%     if row > 0 && col  > 0 && matrix(row,col) == 1
%         matrix(row,col) = currID;
%     end
% end
                        