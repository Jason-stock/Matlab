function [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer01(H_train, Y_train, tIter)
addpath("C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\LossFunc","C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\FIS","C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\PSO");
particleNum = 200;
baseVarFuzzyN = [2;2;2];
[ifParm, cnsqParm, lossAll] = AO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN);

rmpath("C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\LossFunc","C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\FIS","C:\Users\Jason\Matlab\AO+RLSE CFIS for StarBrightness\Model\PSO");
end