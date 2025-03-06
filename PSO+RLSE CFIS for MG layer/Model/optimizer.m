function [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter)
addpath(".\Model\LossFunc\",".\Model\FIS\",".\Model\PSO\");
particleNum = 60;
baseVarFuzzyN = [2;2;2;2];
[ifParm, cnsqParm, lossAll] = PSO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN);

rmpath(".\Model\LossFunc\",".\Model\FIS\",".\Model\PSO\");
end