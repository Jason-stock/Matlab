%% =================== 更新後的主程序 ===================
% 使用新的統合FIS系統的完整示例
% 
% 主要改進:
% 1. 使用unifiedFIS替代原始cFIS
% 2. 消除cell結構，改用矩陣運算
% 3. 統合所有FIS相關函數到單一文件
% 
% 作者: AI Assistant
% 日期: 2025

clear; clc;
addpath("./Dataset/", "./Model/", "./Model/Result/");

%% =================== 數據載入與預處理 ===================
fprintf('=== 數據載入中... ===\n');

% 載入Mackey-Glass數據
[T, X] = getData("mgData.dat");
[T, H, Y] = generateDataset(X, 118, 1000);

% 數據分割
TRAIN_SIZE = 500;
TEST_SIZE = 500;

% 訓練集
T_train = T(1:TRAIN_SIZE, :);
H_train = H(1:TRAIN_SIZE, :);
Y_train = Y(1:TRAIN_SIZE, :);

% 測試集  
T_test = T(TRAIN_SIZE+1:TRAIN_SIZE+TEST_SIZE, :);
H_test = H(TRAIN_SIZE+1:TRAIN_SIZE+TEST_SIZE, :);
Y_test = Y(TRAIN_SIZE+1:TRAIN_SIZE+TEST_SIZE, :);

fprintf('訓練數據: %d 樣本\n', TRAIN_SIZE);
fprintf('測試數據: %d 樣本\n', TEST_SIZE);

%% =================== 模型參數設置 ===================
% FIS結構參數
baseVarFuzzyN = [2; 2; 2; 2];  % 每個輸入變數2個模糊集
ruleNum = prod(baseVarFuzzyN);  % 16條規則

fprintf('模糊規則數: %d\n', ruleNum);
fprintf('輸入變數數: %d\n', length(baseVarFuzzyN));

%% =================== 優化器設置 ===================
% QAO優化器參數
tIter = 50;           % 迭代次數 (原本是3，增加到50以獲得更好結果)
particleNum = 60;     % 粒子數量
parmDim = sum(baseVarFuzzyN) * 3;  % 前件參數維度: 24

fprintf('優化參數維度: %d\n', parmDim);
fprintf('最大迭代次數: %d\n', tIter);

%% =================== 模型訓練 ===================
fprintf('\n=== 開始模型訓練 ===\n');
tic;

% 使用更新後的優化器 (需要修改AO.m調用unifiedFIS)
[ifParm, cnsqParm, baseVarFuzzyN_result, lossAll] = optimizerUpdated(H_train, Y_train, tIter);

training_time = toc;
fprintf('訓練完成! 用時: %.2f 秒\n', training_time);

%% =================== 模型預測 ===================
fprintf('\n=== 模型預測中... ===\n');
tic;

% 使用新的統合FIS系統進行訓練預測
Y_predict_train = approximateWithFIS(H_train, ifParm, cnsqParm, baseVarFuzzyN);

% 使用新的統合FIS系統進行測試預測  
Y_predict_test = approximateWithFIS(H_test, ifParm, cnsqParm, baseVarFuzzyN);

prediction_time = toc;
fprintf('預測完成! 用時: %.2f 秒\n', prediction_time);

%% =================== 性能評估 ===================
% 計算各種誤差指標
train_rmse = RMSE(Y_predict_train, Y_train);
test_rmse = RMSE(Y_predict_test, Y_test);
train_mse = MSE(Y_predict_train, Y_train);
test_mse = MSE(Y_predict_test, Y_test);

fprintf('\n=== 性能評估結果 ===\n');
fprintf('訓練 RMSE: %.6f\n', train_rmse);
fprintf('測試 RMSE: %.6f\n', test_rmse);
fprintf('訓練 MSE: %.6f\n', train_mse);
fprintf('測試 MSE: %.6f\n', test_mse);

% 輸出詳細的性能報告
printLoss(Y_predict_train, Y_train, Y_predict_test, Y_test);

%% =================== 結果可視化 ===================
fprintf('\n=== 生成可視化結果 ===\n');

% 使用更新後的繪圖函數
model_plot([Y_predict_train, Y_train], [Y_predict_test, Y_test], lossAll);

% 額外的收斂曲線圖
figure;
plot(1:length(lossAll), lossAll, 'r-o', 'LineWidth', 2, 'MarkerSize', 4);
title('QAO優化收斂曲線', 'FontSize', 14);
xlabel('迭代次數', 'FontSize', 12);
ylabel('RMSE', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 11);

%% =================== 系統性能報告 ===================
fprintf('\n=== 系統性能報告 ===\n');
fprintf('總執行時間: %.2f 秒\n', training_time + prediction_time);
fprintf('平均每樣本訓練時間: %.6f 秒\n', training_time / TRAIN_SIZE);
fprintf('平均每樣本預測時間: %.6f 秒\n', prediction_time / TEST_SIZE);
fprintf('模型複雜度: %d 參數\n', length(ifParm) + numel(cnsqParm));
fprintf('收斂迭代數: %d\n', length(lossAll));

%% =================== 清理路徑 ===================
rmpath("./Dataset/", "./Model/", "./Model/Result/");

fprintf('\n=== 程序執行完成 ===\n');

%% =================== 更新後的優化器函數 ===================
function [ifParm, cnsqParm, baseVarFuzzyN, lossAll] = optimizerUpdated(H_train, Y_train, tIter)
% 更新後的優化器，使用unifiedFIS替代cFIS
%
% 輸入:
%   H_train - 訓練特徵 (500×4)
%   Y_train - 訓練目標 (500×1)  
%   tIter   - 迭代次數
%
% 輸出:
%   ifParm        - 最優前件參數
%   cnsqParm      - 最優後件參數
%   baseVarFuzzyN - 模糊集配置
%   lossAll       - 收斂曲線

addpath("./Model/FIS/", "./Model/LossFunc/", "./Model/AO/");

% FIS結構參數
particleNum = 60;
baseVarFuzzyN = [2; 2; 2; 2];

% 調用更新後的EQAO_V2算法
[ifParm, cnsqParm, lossAll] = EQAO_V2(tIter, H_train, Y_train, particleNum, baseVarFuzzyN);

rmpath("./Model/FIS/", "./Model/LossFunc/", "./Model/AO/");
end

%% =================== 更新後的AO算法 ===================
function [gBest, thenParm, yAll] = AO_Updated(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
% 使用unifiedFIS的更新版AO算法
%
% 輸入參數:
%   tIter          : 最大迭代次數
%   H_train        : 訓練資料 (前置 / 隱含層特徵)
%   Y_train        : 訓練目標
%   particleNum    : 個體 (粒子) 數
%   baseVarFuzzyN  : 每個輸入變數的模糊集合數
%
% 輸出:
%   gBest          : 找到的最佳參數向量
%   thenParm       : 該最佳解對應的後件參數
%   yAll           : 每代最佳 RMSE 收斂曲線

%% 基本設定
parmDim   = sum(baseVarFuzzyN) * 3;        % 前件參數維度
LB        = zeros(1, parmDim);             % 參數下界
UB        = ones(1, parmDim);              % 參數上界

%% 初始化族群
X         = rand(particleNum, parmDim);    % 隨機生成初始參數矩陣
fitness   = zeros(particleNum, 1);         % 每隻個體的 RMSE
pCnsqParm = cell(particleNum, 1);          % 每隻個體的後件參數

fprintf('初始化 %d 個粒子...\n', particleNum);
for i = 1:particleNum
    % 使用新的unifiedFIS系統
    [Y_out, pCnsqParm{i}] = unifiedFIS(H_train, Y_train, baseVarFuzzyN, X(i,:));
    fitness(i) = RMSE(Y_out, Y_train);
    
    if mod(i, 10) == 0
        fprintf('已初始化 %d/%d 個粒子\n', i, particleNum);
    end
end

[gBestVal, idx] = min(fitness);          % 找到初始最佳解
gBest     = X(idx,:);                    
thenParm  = pCnsqParm{idx};              
yAll      = zeros(tIter,1);              

fprintf('初始最佳RMSE: %.6f\n', gBestVal);

%% 主演化迴圈
for t = 1:tIter
    tNorm  = t / tIter;                  % 當前進度 (0–1)
    X_mean = mean(X,1);                  % 族群平均位置
    
    improved_count = 0;  % 記錄改善的粒子數
    
    for i = 1:particleNum
        A = 2 * (1 - tNorm);             % AO 收斂係數
        
        % AO四段策略
        if     tNorm < 0.25              % S1: 高空盤旋
            X_new = gBest .* (1 - tNorm) + ...
                rand(1,parmDim) .* (gBest - rand(1,parmDim).*gBest);
        elseif tNorm < 0.5               % S2: 低空滑翔
            X_rand = X(randi(particleNum), :);
            X_new  = X_mean - A .* abs(X_rand - X(i,:));
        elseif tNorm < 0.75              % S3: 俯衝攻擊
            X_new  = gBest - A .* abs(gBest - X(i,:));
        else                             % S4: 包圍攻擊
            X_new  = gBest + A .* levyFlight(parmDim);
        end
        
        % 量子擾動增強
        dir   = randn(1, parmDim);
        dir   = dir / (norm(dir) + eps);
        r_q   = sample2s();
        scale = 0.5;
        X_new = X_new + dir * r_q * scale;
        
        % 邊界約束
        X_new = max(X_new, LB);
        X_new = min(X_new, UB);
        
        % 適應度評估 - 使用新的unifiedFIS
        [Y_out, tmpParm] = unifiedFIS(H_train, Y_train, baseVarFuzzyN, X_new);
        fNew             = RMSE(Y_out, Y_train);
        
        % 更新個體
        if fNew < fitness(i)
            X(i,:)       = X_new;
            fitness(i)   = fNew;
            pCnsqParm{i} = tmpParm;
            improved_count = improved_count + 1;
        end
        
        % 更新全域最佳
        if fNew < gBestVal
            gBestVal = fNew;
            gBest    = X_new;
            thenParm = tmpParm;
        end
    end
    
    yAll(t) = gBestVal;
    fprintf('[%3d/%d] RMSE=%.6f (改善粒子: %d/%d)\n', ...
        t, tIter, gBestVal, improved_count, particleNum);
    
    % 提前終止條件
    if gBestVal < 1e-6
        fprintf('達到收斂條件，提前終止\n');
        yAll = yAll(1:t); 
        break;
    end
end

fprintf('優化完成! 最終RMSE: %.6f\n', gBestVal);
end

%% =================== 輔助函數 ===================
function step = levyFlight(d)
% Levy飛行步長生成
beta  = 1.5;
sigma = ( gamma(1+beta) * sin(pi*beta/2) / ...
          ( gamma((1+beta)/2) * beta * 2^((beta-1)/2) ) )^(1/beta);
u = randn(1,d) * sigma;
v = randn(1,d);
step = u ./ abs(v).^(1/beta);
end

function r = sample2s()
% 氫原子2s態徑向採樣
u   = rand;
F   = @(rho) 1 - exp(-rho).*(1+rho+rho.^2/2+rho.^4/8) - u;
rho = fzero(F, [0,20]);
r   = rho;
end