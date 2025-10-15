function [Y_output, cnsqParm] = unifiedFIS(H, Y, baseVarFuzzyN, ifParm)
% UNIFIED FIS SYSTEM - 統合的模糊推理系統
% 整合了所有FIS相關功能，使用矩陣/向量取代cell結構
%
% 輸入:
%   H            - 輸入特徵矩陣 (numSamples × numFeatures)
%   Y            - 目標輸出向量 (numSamples × 1)
%   baseVarFuzzyN - 每個輸入變數的模糊集數量 [2;2;2;2]
%   ifParm       - 前件參數向量 (1 × 24)
%
% 輸出:
%   Y_output     - 預測輸出 (numSamples × 1)
%   cnsqParm     - 後件參數矩陣 (numCoeff × ruleNum)

%% =================== 初始化參數 ===================
HNum = size(H, 1);                    % 樣本數量
numFeatures = size(H, 2);             % 特徵數量 (4)
ruleNum = prod(baseVarFuzzyN);        % 規則數量 (16)
numOfCoeff = numFeatures + 1;         % 後件係數數量 (5: a0,a1,a2,a3,a4)

% 初始化輸出
Y_output = zeros(HNum, 1);

% 初始化RLSE參數
p = 10^8 * eye(ruleNum * numOfCoeff);  % 協方差矩陣
theta = zeros(ruleNum * numOfCoeff, 1); % 參數向量

% 預分配歸一化激發強度矩陣
nfs = zeros(HNum, ruleNum);

fprintf('=== 統合FIS系統開始運行 ===\n');
fprintf('樣本數: %d, 特徵數: %d, 規則數: %d\n', HNum, numFeatures, ruleNum);

%% =================== 前件參數處理 ===================
% 將前件參數轉置以便後續處理
HT = H';  % (4 × HNum)

%% =================== 主要計算循環 ===================
% 對每個樣本計算歸一化激發強度
for i = 1:HNum
    % 取得當前樣本的特徵向量
    h_current = HT(:, i);  % (4 × 1)
    
    % Layer 1: 模糊化 - 計算隸屬度矩陣
    mbrDegMatrix = computeMembershipMatrix(h_current, ifParm, baseVarFuzzyN);
    
    % Layer 2: 規則強度計算
    strength = computeRuleStrength(mbrDegMatrix, baseVarFuzzyN);
    
    % Layer 3: 歸一化
    nfs(i, :) = normalizeStrength(strength);
end

%% =================== RLSE參數學習 ===================
fprintf('開始RLSE參數學習...\n');
for i = 1:HNum
    h_current = HT(:, i);
    
    % 構建回歸矩陣 b
    b = constructRegressionMatrix(h_current, nfs(i, :), ruleNum, numOfCoeff);
    
    % RLSE更新
    [theta, p] = performRLSE(b, theta, p, Y(i));
end

%% =================== 後件參數重構 ===================
cnsqParm = reshape(theta, [numOfCoeff, ruleNum]);

%% =================== 最終輸出計算 ===================
fprintf('計算最終輸出...\n');
for i = 1:HNum
    h_current = HT(:, i);
    
    % Layer 4: 結論計算
    ruleOut = computeConsequence(h_current, cnsqParm, nfs(i, :));
    
    % Layer 5: 聚合輸出
    Y_output(i, 1) = sum(ruleOut);
end

fprintf('=== 統合FIS系統運行完成 ===\n');
end

%% =================== 子函數定義區 ===================

function mbrDegMatrix = computeMembershipMatrix(h, ifParm, baseVarFuzzyN)
% LAYER 1: 計算隸屬度矩陣 (取代cell結構)
% 
% 輸入:
%   h - 當前樣本特徵向量 (4×1)
%   ifParm - 前件參數 (1×24)
%   baseVarFuzzyN - 模糊集數量 [2;2;2;2]
%
% 輸出:
%   mbrDegMatrix - 隸屬度矩陣 (4×2), 複數矩陣

numOfBaseVar = length(baseVarFuzzyN);
maxFuzzyN = max(baseVarFuzzyN);
mbrDegMatrix = zeros(numOfBaseVar, maxFuzzyN);  % 使用複數零矩陣

for j = 1:numOfBaseVar
    for k = 1:baseVarFuzzyN(j)
        % 提取模糊參數
        [fuzzySigma, fuzzyMu, fuzzyLambda] = extractFuzzyParameters(ifParm, baseVarFuzzyN, j, k);
        
        % 計算複數高斯隸屬度
        mbrDegMatrix(j, k) = complexGaussianMF(h(j), fuzzySigma, fuzzyMu, fuzzyLambda);
    end
end
end

function [fuzzySigma, fuzzyMu, fuzzyLambda] = extractFuzzyParameters(parm, baseVarFuzzyN, baseVarNO, fuzzyNO)
% 從參數向量中提取特定模糊集的參數
%
% 輸入:
%   parm - 參數向量
%   baseVarFuzzyN - 每個變數的模糊集數量
%   baseVarNO - 變數編號
%   fuzzyNO - 模糊集編號

if baseVarNO == 1
    startIdx = 1 + (fuzzyNO - 1) * 3;
else
    startIdx = (sum(baseVarFuzzyN(1:baseVarNO-1)) + (fuzzyNO - 1)) * 3 + 1;
end

fuzzySigma = parm(startIdx);      % 標準差
fuzzyMu = parm(startIdx + 1);     % 中心
fuzzyLambda = parm(startIdx + 2); % 相位權重
end

function cMbrDeg = complexGaussianMF(h, sigma, mu, lambda)
% 複數高斯隸屬度函數
%
% 輸入:
%   h - 輸入值
%   sigma - 標準差參數
%   mu - 中心參數  
%   lambda - 相位權重參數
%
% 輸出:
%   cMbrDeg - 複數隸屬度值

% 基本高斯函數
r = exp(-((h - mu)^2) / (2 * sigma^2));

% 相位項計算 (對h微分版本)
w = -r * (-(h - mu) / sigma^2) * lambda;

% 複數隸屬度
cMbrDeg = r * exp(w * 1i);
end

function strength = computeRuleStrength(mbrDegMatrix, baseVarFuzzyN)
% LAYER 2: 計算規則激發強度 (使用矩陣運算取代cell)
%
% 輸入:
%   mbrDegMatrix - 隸屬度矩陣 (4×2)
%   baseVarFuzzyN - 模糊集數量向量
%
% 輸出:
%   strength - 規則強度向量 (1×16)

% 初始化：取第一個變數的隸屬度
strength = mbrDegMatrix(1, 1:baseVarFuzzyN(1));  % (1×2)

% 逐步計算笛卡爾積
for j = 2:length(baseVarFuzzyN)
    % 取得當前變數的隸屬度
    currentMbr = mbrDegMatrix(j, 1:baseVarFuzzyN(j));  % (1×2)
    
    % 計算外積 (張量積)
    newStrength = currentMbr' * strength;  % (2×1) * (1×2) = (2×2)
    
    % 重塑為行向量
    strength = reshape(newStrength, 1, []);  % (1×4), 然後 (1×8), 最後 (1×16)
end
end

function nfs = normalizeStrength(strength)
% LAYER 3: 歸一化激發強度
%
% 輸入:
%   strength - 原始強度向量 (1×16)
%
% 輸出:
%   nfs - 歸一化強度向量 (1×16)

totalStrength = sum(strength);
if abs(totalStrength) < eps  % 避免除零
    nfs = ones(size(strength)) / length(strength);
else
    nfs = strength / totalStrength;
end
end

function b = constructRegressionMatrix(h, nfs, ruleNum, numOfCoeff)
% 構建RLSE回歸矩陣
%
% 輸入:
%   h - 特徵向量 (4×1)
%   nfs - 歸一化強度 (1×16)
%   ruleNum - 規則數量 (16)
%   numOfCoeff - 係數數量 (5)
%
% 輸出:
%   b - 回歸矩陣 (80×1)

% 擴展輸入向量 [1; h]
extendedH = [1; h];  % (5×1)

% 構建完整回歸矩陣
B = extendedH * nfs;  % (5×1) * (1×16) = (5×16)

% 重塑為列向量
b = reshape(B, [ruleNum * numOfCoeff, 1]);  % (80×1)
end

function [theta, p] = performRLSE(b, theta, p, Y)
% 執行遞迴最小平方估計
%
% 輸入:
%   b - 回歸向量 (80×1)
%   theta - 當前參數向量 (80×1)
%   p - 協方差矩陣 (80×80)
%   Y - 目標輸出 (標量)
%
% 輸出:
%   theta - 更新後參數向量 (80×1)
%   p - 更新後協方差矩陣 (80×80)

% RLSE公式
denominator = 1 + b' * p * b;
p = p - (p * b * b' * p) / denominator;
theta = theta + p * b * (Y - b' * theta);
end

function ruleOut = computeConsequence(h, cnsqParm, nfs)
% LAYER 4: 計算結論部分
%
% 輸入:
%   h - 特徵向量 (4×1)
%   cnsqParm - 後件參數矩陣 (5×16)
%   nfs - 歸一化強度 (1×16)
%
% 輸出:
%   ruleOut - 規則輸出向量 (1×16)

% 擴展輸入 [1; h]
extendedH = [1; h];  % (5×1)

% 計算線性函數輸出
linearOut = extendedH' * cnsqParm;  % (1×5) * (5×16) = (1×16)

% 加權輸出
ruleOut = nfs .* linearOut;  % (1×16) .* (1×16) = (1×16)
end

% =================== 獨立使用函數 ===================
function [Y_predict] = approximateWithFIS(H, ifParm, cnsqParm, baseVarFuzzyN)
% 使用已訓練的FIS進行預測 (獨立預測函數)
%
% 輸入:
%   H - 測試特徵矩陣 (numSamples × 4)
%   ifParm - 前件參數 (1×24)
%   cnsqParm - 後件參數 (5×16)
%   baseVarFuzzyN - 模糊集數量 [2;2;2;2]
%
% 輸出:
%   Y_predict - 預測結果 (numSamples × 1)

HNum = size(H, 1);
ruleNum = prod(baseVarFuzzyN);
Y_predict = zeros(HNum, 1);

HT = H';  % 轉置

fprintf('使用FIS進行預測...\n');
for i = 1:HNum
    h_current = HT(:, i);
    
    % 計算隸屬度矩陣
    mbrDegMatrix = computeMembershipMatrix(h_current, ifParm, baseVarFuzzyN);
    
    % 計算規則強度
    strength = computeRuleStrength(mbrDegMatrix, baseVarFuzzyN);
    
    % 歸一化
    nfs = normalizeStrength(strength);
    
    % 結論計算
    ruleOut = computeConsequence(h_current, cnsqParm, nfs);
    
    % 最終輸出
    Y_predict(i, 1) = sum(ruleOut);
end
fprintf('預測完成!\n');
end