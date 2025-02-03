% MATLAB 程式碼: 類神經模糊系統 (NFS) 結合 PSO 和 RLSE
% 資料讀取
filename = 'C:/TSMC_stock.csv';
data = readtable(filename, 'VariableNamingRule', 'preserve'); % 確保變數名稱保留原始
close_price = data.Close; % 提取收盤價
ndata = length(close_price);

% 構建數據對
pairs = ndata - 2;
inputs = [close_price(1:pairs), close_price(2:pairs+1)]';
targets = close_price(3:pairs+2);

% 分割訓練與測試資料
train_size = 200;
X_train = inputs(:, 1:train_size);
y_train = targets(1:train_size);
X_test = inputs(:, train_size+1:end);
y_test = targets(train_size+1:end);

% 模型參數
nRules = 16; % 模糊規則數量
nPSO = 20; % 粒子數量
maxIter = 1000; % 最大疊代次數
alpha = 1e9; % RLSE 初始參數

% 初始化模糊集參數（高斯隸屬函數）
mu = rand(nRules, 2); % 隨機初始化中心
sigma = rand(nRules, 2); % 隨機初始化標準差

% 初始化 PSO
particles = rand(nPSO, 112); % 粒子位置
velocities = zeros(size(particles)); % 粒子速度
pBest = particles; % 個體最佳位置
gBest = particles(1, :); % 全域最佳位置
pBestScores = inf(nPSO, 1);
gBestScore = inf;

% 初始化 RLSE 參數
phi_example = construct_phi(X_train(:, 1));
theta = zeros(length(phi_example), 1); % 根據 phi 初始化 theta
P = alpha * eye(length(phi_example)); % 根據 phi 初始化 P

% PSO 適應度函數（計算 MSE）
fitness = @(params) computeMSE(params, X_train, y_train, theta, P);

% 儲存 MSE
mse_history = zeros(maxIter, 1);

% PSO 主迴圈
for iter = 1:maxIter
    % 動態調整慣性權重
    w = 0.9 - (0.5 * iter / maxIter);
    
    % 更新每個粒子的適應度
    for i = 1:nPSO
        params = particles(i, :);
        score = fitness(params);
        if score < pBestScores(i)
            pBestScores(i) = score;
            pBest(i, :) = params;
        end
        if score < gBestScore
            gBestScore = score;
            gBest = params;
        end
    end

    % 更新粒子速度與位置
    c1 = 2; c2 = 2; % PSO 參數
    for i = 1:nPSO
        r1 = rand(); r2 = rand();
        velocities(i, :) = w * velocities(i, :) + c1 * r1 * (pBest(i, :) - particles(i, :)) + c2 * r2 * (gBest - particles(i, :));
        particles(i, :) = particles(i, :) + velocities(i, :);
    end
    
    % 儲存當前最佳 MSE
    mse_history(iter) = gBestScore;
end

% RLSE 訓練結論部分
for j = 1:size(X_train, 2)
    phi = construct_phi(X_train(:, j)); % 特徵向量
    error = y_train(j) - phi' * theta; % 計算誤差
    K = P * phi / (1 + phi' * P * phi); % 更新增益
    theta = theta + K * error; % 更新參數
    P = P - K * phi' * P; % 更新 P 矩陣
end

% 測試模型性能
train_predictions = predictNFS(X_train, theta, gBest, nRules);
test_predictions = predictNFS(X_test, theta, gBest, nRules);

train_mse = mean((y_train - train_predictions).^2);
test_mse = mean((y_test - test_predictions).^2);

% 顯示結果
fprintf('訓練 MSE: %.4f\n', train_mse);
fprintf('測試 MSE: %.4f\n', test_mse);

% 繪製學習曲線
figure;
plot(1:maxIter, mse_history, '-b', 'LineWidth', 1.5);
xlabel('Iteration');
ylabel('MSE');
title('Learning Curve');
grid on;
set(gca, 'YScale', 'log')

% 繪製訓練結果圖
figure;
plot(1:train_size, y_train, '-r', 1:train_size, train_predictions, '-b');
legend('True Value', 'Predicted Value');
xlabel('Data Point');
ylabel('Value');
title('Training Results');
grid on;

% 繪製測試結果圖
figure;
plot(1:length(y_test), y_test, '-r', 1:length(y_test), test_predictions, '-b');
legend('True Value', 'Predicted Value');
xlabel('Data Point');
ylabel('Value');
title('Testing Results');
grid on;

function future_predictions = predict_future(X_last, theta, gBest, nRules, days)
    % X_last: 最後兩天的收盤價 (2x1 向量)
    % theta: RLSE 訓練好的結論參數
    % gBest: 最佳模糊規則參數 (來自 PSO)
    % nRules: 模糊規則數量
    % days: 要預測的未來天數
    % future_predictions: 回傳未來 'days' 天的預測結果
    
    future_predictions = zeros(days, 1); % 初始化存放預測數據
    
    % 使用最後兩天的數據作為起點
    X_prev = X_last; 
    
    for i = 1:days
        % 預測下一天的收盤價
        y_pred = predictNFS(X_prev, theta, gBest, nRules);
        
        % 存儲預測結果
        future_predictions(i) = y_pred;
        
        % 更新 X_prev，使其包含最近的兩天數據
        X_prev = [X_prev(2); y_pred]; 
    end
end

% 取得最後兩天的數據
X_last = [close_price(end-1); close_price(end)]; 

% 設定預測天數
days = 30;

% 執行預測
future_prices = predict_future(X_last, theta, gBest, nRules, days);

% 顯示預測結果
disp('未來 7 天的預測收盤價：');
disp(future_prices);

% 繪圖顯示未來趨勢
figure;
plot(1:days, future_prices, '-o', 'LineWidth', 2);
xlabel('未來天數');
ylabel('預測收盤價');
title('未來 7 天股價預測');
grid on;


% --- 輔助函數 ---
function mu = gaussian_func(h, c, sigma)
% 高斯模糊集
mu = exp(-((h - c).^2) / (2 * sigma.^2));
end

function phi = construct_phi(inputs)
% 構造特徵向量
phi = [1; inputs];
end

function mse = computeMSE(params, X, y, theta, P)
% 計算 MSE
n = size(X, 2);
mse = 0;
for i = 1:n
    phi = construct_phi(X(:, i)); % 特徵向量
    error = y(i) - phi' * theta; % 計算誤差
    K = P * phi / (1 + phi' * P * phi); % 更新增益
    theta = theta + K * error; % 更新參數
    P = P - K * phi' * P; % 更新 P 矩陣
    
    % 模型輸出
    y_pred = FIS_model(params, X(:, i), theta);
    mse = mse + (y(i) - y_pred)^2;
end
mse = mse / n;
end

function output = FIS_model(param, inputs, theta)
% FIS 模型
c = reshape(param(1:32), [16, 2]); % 16 條規則, 每條 2 個中心
sigma = reshape(param(33:64), [16, 2]); % 16 條規則, 每條 2 個標準差
a0 = param(65:80); % 16 條規則的結論參數 a0
a1 = param(81:96); % 結論參數 a1
a2 = param(97:112); % 結論參數 a2

num_rules = 16;
n_samples = size(inputs, 2); % 輸入樣本數
output = zeros(1, n_samples); % 初始化輸出

for j = 1:n_samples
    w = zeros(1, num_rules);
    y = zeros(1, num_rules);
    for k = 1:num_rules
        A1 = gaussian_func(inputs(1, j), c(k, 1), sigma(k, 1));
        A2 = gaussian_func(inputs(2, j), c(k, 2), sigma(k, 2));
        w(k) = A1 * A2; % 計算規則權重
        y(k) = a0(k) + a1(k) * inputs(1, j) + a2(k) * inputs(2, j); % 計算規則輸出
    end
    output(j) = sum(w .* y) / sum(w); % 聚合規則輸出
end
end

function y_pred = predictNFS(X, theta, params, nRules)
% NFS 模型預測
n = size(X, 2);
y_pred = zeros(n, 1);
for i = 1:n
    phi = construct_phi(X(:, i));
    y_pred(i) = phi' * theta;
end
end



