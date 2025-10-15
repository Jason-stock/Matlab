function [gBest, thenParm, yAll] = QAO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
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
        
        % ---------- 波函數電子徑像距離增強的 Aquila Optimizer 四段策略 ----------
        % 計算1s軌道波函數電子徑像距離
        r_radial = sample1sOrbital();
        
        % 生成量子方向向量
        dir_vector = generateQuantumDirection(parmDim);
        
        % 演化進度自適應縮放因子
        adaptive_scale = calculateAdaptiveScale(tNorm);
        
        if     tNorm < 0.25              % S1: 高空盤旋 + 量子探索
            X_base = gBest .* (1 - tNorm) + ...
                rand(1,parmDim) .* (gBest - rand(1,parmDim).*gBest);
            
            % 加入1s軌道量子擾動
            exploration_factor = 0.5 * (1 - tNorm^0.5);
            X_new = X_base + dir_vector * r_radial * adaptive_scale * exploration_factor;
            
        elseif tNorm < 0.5               % S2: 低空滑翔 + 量子引導
            X_rand = X(randi(particleNum), :);
            X_base = X_mean - A .* abs(X_rand - X(i,:));
            
            % 加入1s軌道量子擾動
            gliding_factor = 0.3 * exp(-tNorm);
            X_new = X_base + dir_vector * r_radial * adaptive_scale * gliding_factor;
            
        elseif tNorm < 0.75              % S3: 俯衝攻擊 + 量子收斂
            X_base = gBest - A .* abs(gBest - X(i,:));
            
            % 加入1s軌道量子擾動
            attack_factor = 0.2 * (1 - tNorm^2);
            X_new = X_base + dir_vector * r_radial * adaptive_scale * attack_factor;
            
        else                             % S4: 包圍攻擊 + 量子Lévy飛行
            levy_base = levyFlight(parmDim);
            
            % 加入1s軌道量子擾動
            surround_factor = 0.4 * (1 - tNorm^1.5);
            X_new = gBest + A .* levy_base + dir_vector * r_radial * adaptive_scale * surround_factor;
        end
        
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

function r = sample1sOrbital()
% sample1sOrbital - 1s軌道波函數電子徑像距離採樣
% 基於氫原子1s態的精確徑向機率密度
%
% 數學模型:
% R₁₀(r) = 2(1/a₀)^(3/2) * exp(-r/a₀)
% P(r) = |R₁₀(r)|² * r² * dr = 4r² * exp(-2r/a₀)
% 對應 Gamma(k=3, θ=a₀/2) 分佈

a0 = 1;  % 波爾半徑 (歸一化)
r = gamrnd(3, a0/2);  % Gamma分佈採樣
r = max(r, 0.01);     % 確保正值
end

function dir_vector = generateQuantumDirection(parmDim)
% generateQuantumDirection - 生成量子方向向量
% 使用球面均勻分佈

% 球面均勻分佈
theta = acos(2*rand - 1);              % 極角 [0,π]
phi = 2*pi*rand;                       % 方位角 [0,2π]

% 笛卡爾坐標
dir_x = sin(theta) * cos(phi);
dir_y = sin(theta) * sin(phi);
dir_z = cos(theta);

% 建立高維方向向量
directions = [dir_x, dir_y, dir_z];
dir_vector = zeros(1, parmDim);

for k = 1:parmDim
    dir_vector(k) = directions(mod(k-1, 3) + 1);
end
end

function scale = calculateAdaptiveScale(tNorm)
% calculateAdaptiveScale - 演化進度自適應縮放因子
% 根據演化進度動態調整量子擾動的強度
%
% 數學模型:
% scale(t) = base_decay(t) + oscillation(t)
% 其中 base_decay 提供主要衰減，oscillation 提供微調

% 基礎指數衰減 (主要項)
base_decay = 0.3 * exp(-2 * tNorm);

% 振盪項 (提供中期微調)
oscillation = 0.1 * sin(3 * pi * tNorm) * exp(-tNorm);

% 合成縮放因子
scale = base_decay + oscillation;

% 確保最小量子效應
scale = max(scale, 0.02);
end

function weights = calculateQuantumWeights(tNorm, n_levels)
% calculateQuantumWeights - 保留此函數以維持兼容性
% 但在簡化版本中不使用多軌道

% 簡化：固定權重為1s軌道
weights = [1.0, 0.0, 0.0];  % 只使用1s軌道
end

function r = sampleHydrogenLevel(n)
% sampleHydrogenLevel - 氫原子能級徑向距離採樣
% 基於氫原子波函數的準確徑向機率密度
%
% 對於氫原子: <r> = (3n² - l(l+1))/2 * a₀
% 這裡簡化為 s 軌道 (l=0)

a0 = 1;  % 波尔半徑 (歸一化)

if n == 1
    % 1s 軌道: R₁₀(r) = 2(1/a₀)^(3/2) * exp(-r/a₀)
    % P(r) = 4r² * exp(-2r/a₀)
    % 對應 Gamma(3, a₀/2) 分佈
    r = gamrnd(3, a0/2);
    
elseif n == 2
    % 2s 軌道: 更複雜的分佈，使用數值逆變換
    u = rand;
    % 使用 fzero 求解累積分佈函數
    try
        F = @(rho) calculateCDF_2s(rho, a0) - u;
        r = fzero(F, [0, 20]);
    catch
        r = 2*a0;  % 失敗時使用期望值
    end
    
elseif n == 3
    % 3s 軌道: 近似為修正的 Gamma 分佈
    % 平均半徑 r̄ = 9a₀/2
    shape = 4;
    scale = 9*a0/(2*shape);
    r = gamrnd(shape, scale);
    
else
    % 高量子數近似
    r = n^2 * a0 * (0.5 + 0.5*rand);  % n²a₀ 附近的均勻分佈
end

% 確保正值
r = max(r, 0.01);
end

function cdf_val = calculateCDF_2s(r, a0)
% calculateCDF_2s - 計算2s軌道的累積分佈函數
% 基於 P₂ₛ(r) = (r²/8a₀³)(2-r/a₀)²exp(-r/a₀)

if r <= 0
    cdf_val = 0;
    return;
end

% 使用數值積分計算 CDF
% 這是一個簡化的近似
rho = r / a0;
if rho < 10
    cdf_val = 1 - exp(-rho) * (1 + rho + rho^2/2 + rho^3/6 + rho^4/24);
else
    cdf_val = 1;  % 對於大 r 值
end
end