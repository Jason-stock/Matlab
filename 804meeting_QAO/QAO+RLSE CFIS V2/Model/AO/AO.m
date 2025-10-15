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
        
        % ---------- 波函數電子徑像距離增強的 Aquila Optimizer 四段策略 ----------
        % 預先計算量子參數
        [r_radial, quantum_params] = sampleElectronRadialDistance(tNorm);
        [dir_vector, angular_params] = generateQuantumDirection(parmDim);
        
        if     tNorm < 0.25              % S1: 高空盤旋 + 多軌道量子探索
            % 原始高空盤旋策略
            X_base = gBest .* (1 - tNorm) + ...
                rand(1,parmDim) .* (gBest - rand(1,parmDim).*gBest);
            
            % 加入高能態電子軌道 (2s, 3s) 用於大範圍探索
            r_exploration = sampleHighEnergyOrbitals(quantum_params.weights);
            exploration_scale = 0.5 * (1 - tNorm^0.5) * angular_params.spin;
            
            X_new = X_base + dir_vector * r_exploration * exploration_scale;
            
        elseif tNorm < 0.5               % S2: 低空滑翔 + 中等軌道量子引導
            % 原始低空滑翔策略
            X_rand = X(randi(particleNum), :);
            X_base = X_mean - A .* abs(X_rand - X(i,:));
            
            % 加入平衡的軌道混合 (1s+2s) 用於局部搜索
            r_balanced = sampleBalancedOrbitals(quantum_params.weights);
            gliding_scale = 0.3 * exp(-tNorm) * angular_params.spin;
            
            X_new = X_base + dir_vector * r_balanced * gliding_scale;
            
        elseif tNorm < 0.75              % S3: 俯衝攻擊 + 基態量子收斂
            % 原始俯衝攻擊策略
            X_base = gBest - A .* abs(gBest - X(i,:));
            
            % 加入基態軌道 (1s) 用於精確收斂
            r_ground = sampleGroundStateOrbital();
            attack_scale = 0.2 * (1 - tNorm^2) * angular_params.spin;
            
            % 量子穿隧機率在攻擊階段增加
            if rand < 0.15  % 15% 穿隧機率
                tunnel_boost = sampleQuantumTunneling(r_radial);
                X_new = X_base + dir_vector * (r_ground + tunnel_boost) * attack_scale;
            else
                X_new = X_base + dir_vector * r_ground * attack_scale;
            end
            
        else                             % S4: 包圍攻擊 + 量子-Lévy 混合飛行
            % 量子增強的 Lévy 飛行
            levy_base = levyFlight(parmDim);
            quantum_levy = generateQuantumLevyFlight(r_radial, angular_params);
            
            % 混合 Lévy 飛行和量子軌道
            hybrid_step = 0.7 * levy_base + 0.3 * quantum_levy;
            surround_scale = 0.4 * (1 - tNorm^1.5) * angular_params.spin;
            
            X_new = gBest + A .* hybrid_step + dir_vector * r_radial * surround_scale;
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

function r = sampleElectronRadialDistance(tNorm)
% sampleElectronRadialDistance - 波函數生成電子徑像距離採樣
% 基於量子力學電子波函數的徑向分佈，結合演化進度動態調整
%
% 輸入: tNorm - 演化進度 [0,1]
% 輸出: r - 電子徑像距離
%
% 數學模型:
% ψ(r) = R(r) * Y(θ,φ) 其中 R(r) 為徑向波函數
% P(r) = |ψ(r)|² * r² * dr 為徑向機率密度
% 
% 結合多個量子態的疊加:
% P_total(r) = Σ c_n * |R_n(r)|² * r²
% 其中 c_n 根據演化進度動態調整

% 量子數設定 (主量子數)
n_levels = [1, 2, 3];  % 考慮1s, 2s, 3s 軌道
weights = calculateQuantumWeights(tNorm, n_levels);

% 多軌道疊加採樣
r = 0;
for i = 1:length(n_levels)
    n = n_levels(i);
    
    % 不同量子數的採樣
    if n == 1
        r_n = sampleHydrogenLevel(1);      % 1s 軌道
    elseif n == 2  
        r_n = sampleHydrogenLevel(2);      % 2s 軌道
    else
        r_n = sampleHydrogenLevel(3);      % 3s 軌道
    end
    
    % 加權疊加
    r = r + weights(i) * r_n;
end

% 加入量子穿隧效應 (小機率長距離)
if rand < 0.05  % 5% 機率發生穿隧
    tunnel_distance = -log(rand) * 2;  % 指數分佈
    r = r + tunnel_distance;
end

% 歸一化到合理範圍
r = min(max(r, 0.1), 10);  % 限制在 [0.1, 10]
end

function weights = calculateQuantumWeights(tNorm, n_levels)
% calculateQuantumWeights - 計算量子軌道權重
% 根據演化進度動態調整各軌道的貢獻比例
%
% 早期: 主要使用高能態 (探索)
% 後期: 主要使用基態 (收斂)

alpha = 3;  % 控制轉換速度
beta = tNorm^alpha;

% 動態權重分配
if tNorm < 0.3        % 初期: 高能態主導 (探索)
    weights = [0.2, 0.4, 0.4];
elseif tNorm < 0.7    % 中期: 平衡分佈
    weights = [0.4, 0.4, 0.2];  
else                  % 後期: 基態主導 (收斂)
    weights = [0.7, 0.2, 0.1];
end

% 歸一化
weights = weights / sum(weights);
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

%% =================== 新增的量子函數群組 ===================

function [dir_vector, angular_params] = generateQuantumDirection(parmDim)
% generateQuantumDirection - 生成量子方向向量和角度參數

% 球面均勻分佈
theta = acos(2*rand - 1);              % 極角 [0,π]
phi = 2*pi*rand;                       % 方位角 [0,2π]

% 笛卡爾坐標
dir_x = sin(theta) * cos(phi);
dir_y = sin(theta) * sin(phi);
dir_z = cos(theta);

% 電子自旋
spin = (-1)^randi(2);                  % ±1 自旋

% 建立高維方向向量
directions = [dir_x, dir_y, dir_z];
dir_vector = zeros(1, parmDim);

for k = 1:parmDim
    dir_vector(k) = directions(mod(k-1, 3) + 1);
end

% 返回角度參數
angular_params.theta = theta;
angular_params.phi = phi;
angular_params.spin = spin;
angular_params.cartesian = [dir_x, dir_y, dir_z];
end

function r_high = sampleHighEnergyOrbitals(weights)
% sampleHighEnergyOrbitals - 採樣高能態軌道 (主要用於S1探索階段)

r2s = sampleHydrogenLevel(2);
r3s = sampleHydrogenLevel(3);

% 高能態權重 (探索導向)
high_weights = [0.1, 0.5, 0.4];  % 偏重2s, 3s
r_high = high_weights(2)*r2s + high_weights(3)*r3s;

% 探索增強
exploration_boost = 1 + 0.3*rand;
r_high = r_high * exploration_boost;
end

function r_balanced = sampleBalancedOrbitals(weights)
% sampleBalancedOrbitals - 採樣平衡軌道 (主要用於S2滑翔階段)

r1s = sampleHydrogenLevel(1);
r2s = sampleHydrogenLevel(2);

% 平衡權重
balanced_weights = [0.6, 0.4, 0.0];  % 1s和2s平衡
r_balanced = balanced_weights(1)*r1s + balanced_weights(2)*r2s;
end

function r_ground = sampleGroundStateOrbital()
% sampleGroundStateOrbital - 採樣基態軌道 (主要用於S3攻擊階段)

r_ground = sampleHydrogenLevel(1);

% 收斂增強 (減小擾動)
convergence_factor = 0.8;
r_ground = r_ground * convergence_factor;
end

function tunnel_boost = sampleQuantumTunneling(r_base)
% sampleQuantumTunneling - 量子穿隧效應

tunnel_strength = 0.5 * exp(-r_base/2);  % 距離越遠穿隧越弱
tunnel_direction = (-1)^randi(2);         % 隨機方向
tunnel_boost = tunnel_direction * tunnel_strength * (-log(rand));
end

function quantum_levy = generateQuantumLevyFlight(r_radial, angular_params)
% generateQuantumLevyFlight - 量子增強的Lévy飛行

% 基礎Lévy飛行參數
beta = 1.5 + 0.3*sin(angular_params.theta);  % 角度調制的β值
sigma = calculateQuantumSigma(beta, r_radial);

% 量子修正的Lévy步長
u = randn * sigma;
v = randn;
levy_base = u / abs(v)^(1/beta);

% 量子軌道調制
orbital_modulation = 1 + 0.2*cos(angular_params.phi) * angular_params.spin;
quantum_levy = levy_base * orbital_modulation;
end

function sigma = calculateQuantumSigma(beta, r_radial)
% calculateQuantumSigma - 計算量子調制的sigma參數

% 基礎sigma計算
sigma_base = (gamma(1+beta) * sin(pi*beta/2) / ...
              (gamma((1+beta)/2) * beta * 2^((beta-1)/2)))^(1/beta);

% 徑向距離調制
radial_factor = 1 + 0.1*log(1 + r_radial);
sigma = sigma_base * radial_factor;
end

function energy_level = selectDominantEnergyLevel(tNorm)
% selectDominantEnergyLevel - 選擇主導能級

if tNorm < 0.3
    energy_level = 3;      % 高能態主導
elseif tNorm < 0.7
    energy_level = 2;      % 中間態主導
else
    energy_level = 1;      % 基態主導
end
end