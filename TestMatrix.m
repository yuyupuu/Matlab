row = [0 0 0 0 1 0 0 0 1 0 0 0 0 0 ];
matrix = zeros(50,55);
electrodes = randperm(numel(matrix), 15);%fifteen ones placed randomly throughout matrix
matrix(electrodes(1:numel(electrodes)))= 1
save('C:\Users\Eunice\Documents\MATLAB\ElectrodeTracker v1.1\ETRACKER\randMat.mat','matrix')

