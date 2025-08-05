function [T, X] = getData(path)
    data=importdata(path);
    T = data(:,1);
    X = data(:,2);
end

