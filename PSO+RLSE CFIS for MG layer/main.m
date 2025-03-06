addpath(".\Model\",".\Dataset\",".\Model\Result\");
%addpath(".\Model\","\Dataset\",".\Result\",".\Model\LossFunc\",".\Model\Result\");
[T, X] = getData("mgData.dat");
[T, H, Y] = generateDataset(X,118,1000);

%產生訓練資料
T_train = T(1:500,:);
H_train = H(1:500,:);
Y_train = Y(1:500,:);

%產生測試資料
T_test = T(501:1000,:);
H_test = H(501:1000,:);
Y_test = Y(501:1000,:);

%使用optimizer找出模型最佳參數
tIter = 3;
[ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter);

%使用approxiamtor預測資料
Y_predict_train = approximator(H_train, ifParm, cnsqParm, baseVarFuzzyN);
Y_predict_test = approximator(H_test, ifParm, cnsqParm, baseVarFuzzyN);

%輸出圖形與損失值
printLoss(Y_predict_train, Y_train, Y_predict_test, Y_test);
model_plot([Y_predict_train,Y_train],[Y_predict_test,Y_test], lossAll );
rmpath(".\Model\",".\Dataset\",".\Model\Result\");