function [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter)
addpath("C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\FIS\","C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\LossFunc\","C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\AO\");
particleNum = 60;
baseVarFuzzyN = [2;2;2;2];
[ifParm, cnsqParm, lossAll] = AO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN);

rmpath("C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\LossFunc\","C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\FIS\","C:\Users\jason\Matlab\804meeting_QAO\QAO+RLSE CFIS for MG layer\Model\AO\");
end