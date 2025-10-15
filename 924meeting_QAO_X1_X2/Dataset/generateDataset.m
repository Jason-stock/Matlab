function [T,H,Y] = generateDataset(data,startIdx,numOfDataset)
T = zeros(numOfDataset, 1);
H = zeros(numOfDataset, 4);
Y = zeros(numOfDataset, 1);

%generate dataset
for i = startIdx:(startIdx+numOfDataset-1)
    H(i-startIdx+1,1) = data(i-18);
    H(i-startIdx+1,2) = data(i-12);
    H(i-startIdx+1,3) = data(i-6);
    H(i-startIdx+1,4) = data(i);
    Y(i-startIdx+1,1) = data(i+6);
    T(i-startIdx+1,1) = i+6;
end
end