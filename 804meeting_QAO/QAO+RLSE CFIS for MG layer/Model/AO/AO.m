function [gBest, thenParm, yAll] = AO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
% 輸入參數
%   tIter          : 最大迭代次數
%   H_train        : 訓練資料 (前置 / 隱含層特徵)
%   Y_train        : 訓練目標
%   particleNum    : 個體 (粒子) 數
%   baseVarFuzzyN  : 每個輸入變數的模糊集合數
%
% 輸出
%   gBest          : 找到的最佳參數向量
%   thenParm       : 該最佳解對應的後件參數 (由 cFIS 回傳)
%   yAll           : 每代最佳 RMSE 收斂曲線

%% ──────────────────── 1. 基本設定 ──────────────────────
parmDim   = sum(baseVarFuzzyN) * 3;        % 共有多少待優化參數 (前件 c, σ, 權重)
LB        = zeros(1, parmDim);             % 參數下界，全設為 0
UB        = ones(1,  parmDim);             % 參數上界，全設為 1

%% ──────────────────── 2. 初始化族群 ─────────────────────
X         = rand(particleNum, parmDim);    % 隨機生成初始參數矩陣 (Ns × dim)
fitness   = zeros(particleNum, 1);         % 預留每隻個體的 RMSE
pCnsqParm = cell(particleNum, 1);          % 存放每隻個體對應的後件參數

for i = 1:particleNum                                      % 對每個體
    [Y_out, pCnsqParm{i}] = cFIS(H_train, Y_train, baseVarFuzzyN, X(i,:));   
    fitness(i) = RMSE(Y_out, Y_train);                     %   計算 RMSE
end
[gBestVal, idx] = min(fitness);          % 取群體中的最小 RMSE 與索引
gBest     = X(idx,:);                    %   對應的參數即為全域最佳
thenParm  = pCnsqParm{idx};              %   儲存其後件參數
yAll      = zeros(tIter,1);              %   收斂曲線預留空間

%% ──────────────────── 3. 主演化迴圈 ────────────────────
for t = 1:tIter
    tNorm  = t / tIter;                  % 當前進度 (0–1)
    X_mean = mean(X,1);                  % 族群平均位置
    
    for i = 1:particleNum                % 更新每個體
        A = 2 * (1 - tNorm);             % AO 收斂係數 (由 2 線性遞減到 0)
        
        % ---------- Aquila Optimizer 四段策略 ----------
        if     tNorm < 0.25              % S1: 高空盤旋 (全域探索)
            X_new = gBest .* (1 - tNorm) + ...
                rand(1,parmDim) .* (gBest - rand(1,parmDim).*gBest);
        elseif tNorm < 0.5               % S2: 低空滑翔 (局部搜索)
            X_rand = X(randi(particleNum), :);  % 隨機選一隻同伴
            X_new  = X_mean - A .* abs(X_rand - X(i,:));
        elseif tNorm < 0.75              % S3: 俯衝攻擊 (加速收斂)
            X_new  = gBest - A .* abs(gBest - X(i,:));
        else                             % S4: 包圍攻擊 (Levy 飛行)
            X_new  = gBest + A .* levyFlight(parmDim);
        end
        
        % ---------- 加入氫原子 1s 量子擾動 ----------
        dir   = randn(1, parmDim);             % 隨機方向向量
        dir   = dir / (norm(dir) + eps);       % 單位化避免除 0
        r_q   = sample2s();                    % 徑向距離 (1s 機率密度)
        scale = 0.5;                           % 將 r_q 轉換為搜尋空間尺度
        X_new = X_new + dir * r_q * scale;     % 將量子擾動加到 AO 結果
        
        % ---------- 邊界約束 ----------
        X_new = max(X_new, LB);                % 低於下界 → 拉回
        X_new = min(X_new, UB);                % 高於上界 → 拉回
        
        % ---------- 適應度評估 ----------
        [Y_out, tmpParm] = cFIS(H_train, Y_train, baseVarFuzzyN, X_new);
        fNew             = RMSE(Y_out, Y_train);
        
        % 若新解優於個體歷史，則更新個體
        if fNew < fitness(i)
            X(i,:)       = X_new;
            fitness(i)   = fNew;
            pCnsqParm{i} = tmpParm;
        end
        % 若新解優於全域最佳，則更新全域
        if fNew < gBestVal
            gBestVal = fNew;
            gBest    = X_new;
            thenParm = tmpParm;
        end
    end
    
    yAll(t) = gBestVal;                     % 記錄當代最佳 RMSE
    fprintf('%3d / %d   RMSE = %.6f\n', t, tIter, gBestVal);  % 即時輸出
    
    if gBestVal < 1e-5                      % 提前終止 (達標 RMSE)
        yAll = yAll(1:t); break;
    end
end
end  % ← 主函式結束

%% ──────────────────── 4. 附屬函式 ──────────────────────
function step = levyFlight(d)
% levyFlight  生成長尾分佈步長 (Mantegna 演算法)
beta  = 1.5;                               % 飛行指數 (建議 1.5)
sigma = ( gamma(1+beta) * sin(pi*beta/2) / ...
          ( gamma((1+beta)/2) * beta * 2^((beta-1)/2) ) )^(1/beta);
u = randn(1,d) * sigma;                    % 正態分佈 u
v = randn(1,d);                            % 正態分佈 v
step = u ./ abs(v).^(1/beta);              % Levy 步長
end

function r = sample1s()
% sample1s  根據氫原子 1s 態徑向機率密度取樣距離 r
% 1s 分佈對應 Gamma(k=3, θ=1)；r = ρ/2 (a0=1)
r = sum(-log(rand(3,1)))/2; 
end

function r = sample2s()   % 2s 態徑向採樣 (數值逆 CDF)
u   = rand;
F   = @(rho) 1 - exp(-rho).*(1+rho+rho.^2/2+rho.^4/8) - u;
rho = fzero(F, [0,20]);   % 求 F(ρ)=u 之根
r   = rho;                % (a0 = 1) → r = ρ
end