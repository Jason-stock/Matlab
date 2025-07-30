function [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter)
addpath("C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\LossFunc","C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\FIS","C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\PSO");
particleNum = 200;
baseVarFuzzyN = [3;3];
[ifParm, cnsqParm, lossAll] = PSO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN);

rmpath("C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\LossFunc","C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\FIS","C:\Users\Jason\Matlab\PSO+RLSE CFIS for StarBrightness\Model\PSO");
end