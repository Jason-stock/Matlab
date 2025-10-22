% =========================================================================
% AI Homework 1 - Modified for 3D Visualization
% Author: [Your Name]
% ID: [Your ID]
% Date: 2025/10/16
%
% This script visualizes a hand-coded neural network as a 3D surface function
% y = f(x1, x2).
% =========================================================================

%% Clear workspace, command window, and close all figures
clear; clc; close all;

%% ==================== 1. 定義網路架構與參數 ====================
fprintf('--- 1. 初始化類神經網路 ---\n');

% --- 網路結構 ---
% 輸入層: 2 個神經元 (x1, x2)
% 隱藏層 1: 4 個神經元 (Hard Limit)
% 隱藏層 2: 5 個神經元 (Log-Sigmoid)
% 輸出層: 1 個神經元 (Saturating Linear) -> 為了得到單一輸出 y

% --- 轉化函數 ---
f1 = @(n) hardlim(n);
f2 = @(n) logsig(n);
f3 = @(n) satlin(n);

% --- 初始化權重 (Weights) 與閥值 (Biases) ---
% 由於網路結構已變更，我們使用隨機值初始化參數
% 'rng(0)' 可確保每次執行時生成的隨機數都相同，方便重現結果
rng(0);

% Layer 1: 4 neurons, 2 inputs -> W1 is 4x2, b1 is 4x1
w1 = randn(4, 2);
b1 = randn(4, 1);

% Layer 2: 5 neurons, 4 inputs -> W2 is 5x4, b2 is 5x1
w2 = randn(5, 4);
b2 = randn(5, 1);

% Layer 3: 1 neuron, 5 inputs -> W3 is 1x5, b3 is 1x1 (scalar)
w3 = randn(1, 5);
b3 = randn(1, 1);

fprintf('網路初始化完成。\n\n');

%% ==================== 2. 生成輸入資料網格 ====================
fprintf('--- 2. 生成輸入資料網格 ---\n');

% 定義 x1 和 x2 的範圍與解析度
points = 1000; % 注意：1000x1000 會產生 10^6 個點，計算量很大
               % 若要快速測試，可將此數值調低，例如 100
x_range = [-3, 3];

% 線性生成 1000 個點
x1_vec = linspace(x_range(1), x_range(2), points);
x2_vec = linspace(x_range(1), x_range(2), points);

% 建立 2D 網格
[X1, X2] = meshgrid(x1_vec, x2_vec);

% 初始化輸出矩陣 Y
Y = zeros(points, points);

fprintf('已生成 %d x %d 的輸入網格。\n\n', points, points);

%% ============== 3. 遍歷網格並通過神經網路計算輸出 ==============
fprintf('--- 3. 開始計算網路輸出 (y) ---\n');
fprintf('這需要一些時間，請稍候...\n');

% 使用計時器
tic;

% 遍歷每一個網格點
for i = 1:points
    for j = 1:points
        % 組合當前的輸入向量 p = [x1; x2]
        p = [X1(i, j); X2(i, j)];

        % 依序通過三層網路
        a1 = neuron_layer(p, w1, b1, f1);
        a2 = neuron_layer(a1, w2, b2, f2);
        y = neuron_layer(a2, w3, b3, f3);

        % 儲存輸出結果
        Y(i, j) = y;
    end
end

% 停止計時器
elapsed_time = toc;
fprintf('計算完成！總耗時: %.2f 秒。\n\n', elapsed_time);

%% ==================== 4. 繪製 3D 曲面圖 ====================
fprintf('--- 4. 繪製 3D 結果圖 ---\n');

figure('Name', 'Neural Network Function Visualization', 'NumberTitle', 'off');
surf(X1, X2, Y, 'EdgeColor', 'none', 'FaceAlpha', 0.8);

% 美化圖形
shading interp;
lighting gouraud;
material shiny;
camlight head;

% 加入標籤與標題
xlabel('Input x1');
ylabel('Input x2');
zlabel('Output y');
title('3D Visualization of the Neural Network as a Function y=f(x1,x2)');
grid on;
colorbar;
view(3); % 設定為 3D 視角
axis tight; % 自動調整座標軸

fprintf('繪圖完成。\n');

%% ==================== 函式定義 (Function Definitions) ====================

% 神經網路層模組 (來自問題2)
function layer_output = neuron_layer(layer_inputs, layer_weights, layer_biases, transfer_function)
    net_inputs = layer_weights * layer_inputs + layer_biases;
    layer_output = transfer_function(net_inputs);
end

% --- Transfer (Activation) Functions ---

% Hard Limit Transfer Function
function a = hardlim(n)
    a = double(n >= 0);
end

% Log-Sigmoid Transfer Function
function a = logsig(n)
    a = 1 ./ (1 + exp(-n));
end

% Saturating Linear Transfer Function
function a = satlin(n)
    a = max(0, min(1, n));
end