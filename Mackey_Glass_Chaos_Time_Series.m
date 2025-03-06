%% Step 1: 生成 Mackey-Glass 混沌時間序列
clc; clear; close all;

% 定義參數
tau = 17;       % 時間延遲
beta = 0.2;     % 增長率
gamma = 0.1;    % 衰減率
n = 10;         % 非線性指數
dt = 0.1;       % 時間步長
T = 600;        % 總時間
tspan = 1:dt:T; % 時間範圍

% 初始化狀態變數
x = zeros(1, length(tspan));
x(1) = 0.5; % 初始條件

% 使用 Euler 方法求解 Mackey-Glass 方程
for i = 2:length(tspan)
    tau_index = max(1, round(i - tau/dt)); % 過去的索引
    x(i) = x(i-1) + dt * (beta * x(tau_index) / (1 + x(tau_index)^n) - gamma * x(i-1));
end

% 標準化數據
x = (x - min(x)) / (max(x) - min(x));

%% Step 2: 劃分數據集 (80% 訓練, 20% 測試)
train_ratio = 0.8;
train_len = floor(train_ratio * length(x));
train_data = x(1:train_len);
test_data = x(train_len+1:end);

%% Step 3: FCM 進行模糊分群 (決定 CNFS 規則數量)
c = 5; % 假設有 5 個模糊集合
[center, U] = fcm(train_data, c);

% 轉換成模糊規則
rules = zeros(c, length(train_data));
for i = 1:c
    rules(i, :) = U(i, :) .* train_data;
end

%% Step 4: 訓練 CNFS (使用 CFSs 訓練模糊系統)
% 使用 Sugeno 型模糊推理
fis = mamfis('NumInputs',1,'NumOutputs',1,'NumRules',c);

% 定義隸屬函數 (Gaussian)
for i = 1:c
    fis.Inputs(1).MembershipFunctions(i) = fismf('gaussmf', [0.1 center(i)]);
    fis.Outputs(1).MembershipFunctions(i) = fismf('linear', [1 0]);
end

% 訓練模糊系統 (使用 ANFIS 訓練 CNFS)
opt = anfisOptions('InitialFIS',fis,'EpochNumber',50);
CNFS_model = anfis([train_data(1:end-1)' train_data(2:end)'], opt);

%% Step 5: 訓練 ARIMA 模型 (對數據做時間序列建模)
model_ARIMA = arima(4,1,0); % 設定 ARIMA(4,1,0)
fit_ARIMA = estimate(model_ARIMA, train_data');

%% Step 6: 預測未來數據 (CNFS + ARIMA 結果)
pred_CNFS = evalfis(test_data(1:end-1), CNFS_model);
pred_ARIMA = forecast(fit_ARIMA, length(test_data), 'Y0', train_data');

% 組合 CNFS 與 ARIMA 結果 (線性 + 非線性修正)
alpha = 0.7; % CNFS 權重
beta = 1 - alpha; % ARIMA 權重
final_prediction = alpha * pred_CNFS' + beta * pred_ARIMA;

%% Step 7: 評估模型性能
mse_CNFS = mean((test_data(2:end) - pred_CNFS').^2);
mse_ARIMA = mean((test_data(2:end) - pred_ARIMA).^2);
mse_combined = mean((test_data(2:end) - final_prediction).^2);

fprintf('MSE (CNFS): %f\n', mse_CNFS);
fprintf('MSE (ARIMA): %f\n', mse_ARIMA);
fprintf('MSE (CNFS + ARIMA): %f\n', mse_combined);

%% Step 8: 繪圖對比
figure;
hold on;
plot(test_data, 'k', 'LineWidth', 2);
plot([NaN(1,1) pred_CNFS], 'r--', 'LineWidth', 1.5);
plot([NaN(1,1) pred_ARIMA], 'b--', 'LineWidth', 1.5);
plot([NaN(1,1) final_prediction], 'g', 'LineWidth', 2);
legend('Real Data', 'CNFS Prediction', 'ARIMA Prediction', 'CNFS+ARIMA Prediction');
xlabel('Time');
ylabel('Normalized Value');
title('Mackey-Glass Time-Series Prediction using CNFS-ARIMA');
grid on;
hold off;
