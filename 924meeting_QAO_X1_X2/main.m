addpath("C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Model","C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Dataset","C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Model\Result");
%addpath(".\Model\","\Dataset\",".\Result\",".\Model\LossFunc\",".\Model\Result\");
% === Step 1: 讀取 CSV 檔 ===
filename = "C:\Users\Jason\Matlab2\AO+RLSE CFIS for AppleStock\HistoricalData_1743853818599.csv";
data = readtable(filename);
disp(data)

data.Open = cellfun(@(x) str2double(erase(x, '$')), data.Open);
openPrice = data.Open;     % 開盤價欄位
openPrice = openPrice(1:1000);

data.Close_Last = cellfun(@(x) str2double(erase(x, '$')), data.Close_Last);
closePrice = data.Close_Last;     % 開盤價欄位
closePrice = closePrice(1:1000);

minOpen  = min(openPrice);
maxOpen  = max(openPrice);
minClose = min(closePrice);
maxClose = max(closePrice);

% 2. 將數列依照 min-max scaling 方式正規化到 [0,1]
openPrice  = (openPrice  - minOpen ) ./ (maxOpen  - minOpen );
closePrice = (closePrice - minClose) ./ (maxClose - minClose);

num_samples = 998;
X = zeros(num_samples, 4);
Y1 = zeros(num_samples, 1);
Y2 = zeros(num_samples, 1);

for i = 1:num_samples
    t = i + 1;
    X(i, :) = [openPrice(t-1), openPrice(t),closePrice(t-1), closePrice(t)];
    Y1(i) = openPrice(t+1);
    Y2(i) = closePrice(t+1);
end

H_train = X(1:500, :);
Y_train = Y1(1:500) + 1j*Y2(1:500);

H_test = X(501:end, :);
Y_test = Y1(501:end) + 1j*Y2(501:end);

%使用optimizer找出模型最佳參數
tIter = 20;
[ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizer(H_train, Y_train, tIter);

%使用approxiamtor預測資料
Y_predict_train = approximator(H_train, ifParm, cnsqParm, baseVarFuzzyN);
Y_predict_test = approximator(H_test, ifParm, cnsqParm, baseVarFuzzyN);

%輸出圖形與損失值
printLoss(Y_predict_train, Y_train, Y_predict_test, Y_test);
model_plot([Y_predict_train,Y_train],[Y_predict_test,Y_test], lossAll );

rmpath("C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Model","C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Dataset","C:\Users\Jason\Matlab2\AO+RLSE CFIS for MG layer\Model\Result");

