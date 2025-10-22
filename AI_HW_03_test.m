% =========================================================================
% AI Homework 1: Deep Neural Network from Scratch
% Author: [Your Name]
% ID: [Your ID]
% Date: 2025/10/16
%
% This script implements a three-layer neural network from basic principles
% without using any specialized toolboxes, as per the assignment requirements.
% =========================================================================

%% Clear workspace, command window, and close all figures
clear; clc; close all;

%% ==================== 問題 3: 建立並測試三層深度神經網路 ====================
% 此部分直接使用問題2的函式建立三層網路，並用提供的測試資料驗證。

fprintf('--- 開始執行三層深度神經網路測試 ---\n\n');

% --- 1. 定義網路架構與轉化函數 ---
% 第 1 層: 4 個神經元, Hard Limit 轉化函數
% 第 2 層: 5 個神經元, Log-Sigmoid 轉化函數
% 第 3 層: 2 個神經元, Saturating Linear 轉化函數
% 我們使用匿名函式 (function handle) 來傳遞這些轉化函數
f1 = @(n) hardlim(n);
f2 = @(n) logsig(n);
f3 = @(n) satlin(n);

% --- 2. 載入提供的測試資料 ---
% 輸入 (Inputs)
inputs = [0.6; 0.9];

w1=[0.51, -0.22; -0.81, 1.12];
b1=[0.15; -0.30];
w2=[0.44, 0.99; -0.12, -0.55; 1.20, -1.05; 0.71, 0.33; -0.68, 0.81];
b2=[-0.45; 0.25; 0.50; -0.99; 0.05];
w3=[1.50, -1.25, 0.85, 0.10, -0.75];
b3=[-0.50];


% 預期的最終輸出
expected_output = 0.3343;

fprintf('輸入向量 P (3x1):\n');
disp(inputs);

% --- 3. 依序計算每一層的輸出 ---

% 計算第 1 層輸出
fprintf('--- 計算第 1 層輸出 (Hard Limit) ---\n');
output1 = neuron_layer(inputs, w1, b1, f1);
fprintf('第 1 層的輸出 A1 (4x1):\n');
disp(output1);

% 計算第 2 層輸出 (使用第1層的輸出作為輸入)
fprintf('--- 計算第 2 層輸出 (Log-Sigmoid) ---\n');
output2 = neuron_layer(output1, w2, b2, f2);
fprintf('第 2 層的輸出 A2 (5x1):\n');
disp(output2);

% 計算第 3 層輸出 (使用第2層的輸出作為輸入)
fprintf('--- 計算第 3 層輸出 (Saturating Linear) ---\n');
final_output = neuron_layer(output2, w3, b3, f3);
fprintf('第 3 層的最終輸出 A3 (2x1):\n');
disp(final_output);

% --- 4. 驗證結果 ---
fprintf('--- 結果驗證 ---\n');
fprintf('預期輸出:\n');
disp(expected_output);
fprintf('程式計算輸出:\n');
disp(final_output);

% 使用一個小的容許誤差來比較浮點數
if all(abs(final_output - expected_output) < 1e-4)
    fprintf('\n測試成功：程式計算結果與提供的解答相符。\n');
else
    fprintf('\n測試失敗：程式計算結果與提供的解答不符。\n');
end


%% ==================== 函式定義 (Function Definitions) ====================
% 根據作業要求，以下是獨立的函式模組。
% 在 MATLAB R2016b 及更新版本中，函式可以定義在腳本檔案的末尾。

% =========================================================================
% 問題 1: 類神經網路之神經元的模組程式
% =========================================================================
function output = single_neuron(inputs, weights, bias, transfer_function)
    % inputs: 輸入值的行向量 (column vector)
    % weights: 權重的列向量 (row vector)
    % bias: 閥值的純量 (scalar)
    % transfer_function: 轉化函數的函式控制代碼 (function handle)

    % 計算淨輸入 n = w*p + b
    net_input = weights * inputs + bias;

    % 將淨輸入傳遞給轉化函數以獲得輸出
    output = transfer_function(net_input);
end

% =========================================================================
% 問題 2: 建立一類神經網路層
% =========================================================================
function layer_output = neuron_layer(layer_inputs, layer_weights, layer_biases, transfer_function)
    % layer_inputs: 來自前一層的輸入行向量
    % layer_weights: 該層的權重矩陣 (S x R)，S 是神經元數量，R 是輸入數量
    % layer_biases: 該層的閥值行向量
    % transfer_function: 轉化函數的函式控制代碼

    % 使用矩陣運算計算所有神經元的淨輸入向量 n = W*p + b
    net_inputs = layer_weights * layer_inputs + layer_biases;

    % 將淨輸入向量的每個元素應用於轉化函數
    layer_output = transfer_function(net_inputs);
end

% =========================================================================
% 作業要求的轉化函數 (Transfer Functions)
% =========================================================================

% Hard Limit Transfer Function
function a = hardlim(n)
    % 如果 n >= 0，輸出為 1，否則為 0
    a = double(n >= 0);
end

% Log-Sigmoid Transfer Function
function a = logsig(n)
    % 數學式: a = 1 / (1 + exp(-n))
    a = 1 ./ (1 + exp(-n));
end

% Saturating Linear Transfer Function
function a = satlin(n)
    % 如果 n < 0，輸出為 0
    % 如果 0 <= n <= 1，輸出為 n
    % 如果 n > 1，輸出為 1
    a = max(0, min(1, n));
end