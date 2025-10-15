function [gBest, thenParm, yAll] = EQAO(tIter, H_train, Y_train, particleNum, baseVarFuzzyN)
% EQAO - Enhanced Quantum Aquila Optimizer
% 增強型量子老鷹優化演算法，結合波函數電子徑像距離
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
%
% 創新點:
% 1. 引入波函數電子徑像距離的量子擾動
% 2. 動態多軌道疊加模型
% 3. 自旋效應和量子穿隧
% 4. 演化進度自適應調整

fprintf('=== 增強型量子老鷹優化演算法 (EQAO) ===\n');

%% ──────────────────── 1. 基本設定 ──────────────────────
parmDim   = sum(baseVarFuzzyN) * 3;        % 待優化參數維度
LB        = zeros(1, parmDim);             % 參數下界
UB        = ones(1, parmDim);              % 參數上界

fprintf('參數維度: %d, 粒子數: %d, 最大迭代: %d\n', parmDim, particleNum, tIter);

%% ──────────────────── 2. 初始化族群 ─────────────────────
X         = rand(particleNum, parmDim);    % 隨機生成初始參數矩陣
fitness   = zeros(particleNum, 1);         % 每隻個體的 RMSE
pCnsqParm = cell(particleNum, 1);          % 每隻個體的後件參數

% 量子增強初始化
for i = 1:particleNum
    % 加入量子隨機初始化
    quantum_noise = 0.1 * sampleQuantumNoise(parmDim);
    X(i, :) = max(0, min(1, X(i, :) + quantum_noise));
    
    [Y_out, pCnsqParm{i}] = cFIS(H_train, Y_train, baseVarFuzzyN, X(i,:));
    fitness(i) = RMSE(Y_out, Y_train);
    
    if mod(i, 10) == 0
        fprintf('初始化進度: %d/%d\n', i, particleNum);
    end
end

[gBestVal, idx] = min(fitness);          % 找到初始最佳解
gBest     = X(idx,:);
thenParm  = pCnsqParm{idx};
yAll      = zeros(tIter,1);

fprintf('初始最佳RMSE: %.6f\n', gBestVal);

%% ──────────────────── 3. 主演化迴圈 ────────────────────
for t = 1:tIter
    tNorm  = t / tIter;                  % 當前進度 (0–1)
    X_mean = mean(X,1);                  % 族群平均位置
    
    % 動態量子參數
    quantum_strength = calculateQuantumStrength(tNorm);
    
    improved_count = 0;
    
    for i = 1:particleNum
        A = 2 * (1 - tNorm);             % AO 收斂係數
        
        % ---------- 增強型 Aquila Optimizer 四段策略 ----------
        if tNorm < 0.25                  % S1: 高空盤旋 (全域探索)
            X_new = gBest .* (1 - tNorm) + ...
                rand(1,parmDim) .* (gBest - rand(1,parmDim).*gBest);
            
            % 量子增強探索
            quantum_boost = sampleQuantumMultiOrbit(parmDim, tNorm) * quantum_strength;
            X_new = X_new + quantum_boost;
            
        elseif tNorm < 0.5               % S2: 低空滑翔 (局部搜索)
            X_rand = X(randi(particleNum), :);
            X_new  = X_mean - A .* abs(X_rand - X(i,:));
            
            % 量子自旋效應
            spin_perturbation = sampleSpinPerturbation(parmDim, tNorm);
            X_new = X_new + spin_perturbation * quantum_strength * 0.5;
            
        elseif tNorm < 0.75              % S3: 俯衝攻擊 (加速收斂)
            X_new  = gBest - A .* abs(gBest - X(i,:));
            
            % 量子穿隧效應
            if rand < 0.1  % 10% 機率發生穿隧
                tunnel_jump = sampleQuantumTunneling(parmDim);
                X_new = X_new + tunnel_jump * quantum_strength * 0.3;
            end
            
        else                             % S4: 包圍攻擊 (Levy 飛行 + 量子效應)
            levy_step = levyFlight(parmDim);
            quantum_levy = sampleQuantumLevyHybrid(parmDim, tNorm);
            X_new = gBest + A .* (levy_step + quantum_levy * quantum_strength);
        end
        
        % ---------- 波函數電子徑像距離主要量子擾動 ----------
        [radial_perturbation, angular_info] = sampleElectronRadialDistanceWithAngular(tNorm, parmDim);
        
        % 動態縮放因子
        scale = calculateDynamicScale(tNorm, angular_info.spin, i, particleNum);
        
        % 應用主要量子擾動
        X_new = X_new + radial_perturbation * scale;
        
        % ---------- 邊界約束與量子反射 ----------
        X_new = applyQuantumBoundaryConstraints(X_new, LB, UB, quantum_strength);
        
        % ---------- 適應度評估 ----------
        [Y_out, tmpParm] = cFIS(H_train, Y_train, baseVarFuzzyN, X_new);
        fNew             = RMSE(Y_out, Y_train);
        
        % 量子接受準則 (類似量子退火)
        accept_prob = calculateQuantumAcceptance(fitness(i), fNew, tNorm);
        
        if fNew < fitness(i) || rand < accept_prob
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
    fprintf('[%3d/%d] RMSE=%.6f (改善: %d/%d, 量子強度: %.3f)\n', ...
        t, tIter, gBestVal, improved_count, particleNum, quantum_strength);
    
    % 提前終止條件
    if gBestVal < 1e-6
        fprintf('達到收斂條件，提前終止於第 %d 代\n', t);
        yAll = yAll(1:t);
        break;
    end
end

fprintf('=== EQAO 優化完成! 最終RMSE: %.6f ===\n', gBestVal);
end

%% =================== 量子擾動相關函數 ===================

function noise = sampleQuantumNoise(dim)
% 生成量子噪聲用於初始化增強
persistent rng_initialized
if isempty(rng_initialized)
    rng('shuffle');  % 使用當前時間作為隨機種子
    rng_initialized = true;
end

% 多尺度量子噪聲
noise = 0.7 * randn(1, dim) .* exp(-abs(randn(1, dim)));  % 長尾分佈
noise = noise + 0.3 * (rand(1, dim) - 0.5) * 2;          % 均勻分佈
end

function strength = calculateQuantumStrength(tNorm)
% 計算動態量子強度
% 早期強，後期弱，中期有一個小回升
base_strength = exp(-3 * tNorm);  % 指數衰減
fluctuation = 0.2 * sin(4 * pi * tNorm) * exp(-2 * tNorm);  % 振盪項
strength = base_strength + fluctuation;
strength = max(strength, 0.05);  % 保持最小量子效應
end

function perturbation = sampleQuantumMultiOrbit(dim, tNorm)
% 多軌道量子擾動
n_orbitals = 3;
weights = [0.5, 0.3, 0.2];  % 1s, 2s, 3s 權重

perturbation = zeros(1, dim);
for i = 1:n_orbitals
    orbital_contrib = sampleOrbitalContribution(dim, i, tNorm);
    perturbation = perturbation + weights(i) * orbital_contrib;
end
end

function contrib = sampleOrbitalContribution(dim, n, tNorm)
% 計算特定軌道的貢獻
if n == 1
    % 1s 軌道：緊密分佈
    contrib = 0.1 * randn(1, dim) .* exp(-2 * abs(randn(1, dim)));
elseif n == 2
    % 2s 軌道：中等擴散
    contrib = 0.2 * randn(1, dim) .* exp(-abs(randn(1, dim)));
else
    % 3s 軌道：較寬分佈
    contrib = 0.3 * randn(1, dim) .* exp(-0.5 * abs(randn(1, dim)));
end

% 時間調制
contrib = contrib * (1 - 0.5 * tNorm);
end

function perturbation = sampleSpinPerturbation(dim, tNorm)
% 自旋擾動效應
spin_up = rand(1, dim) > 0.5;  % 隨機自旋方向
magnitude = 0.1 * exp(-2 * tNorm);  % 時間衰減

perturbation = magnitude * (2 * spin_up - 1) .* abs(randn(1, dim));
end

function jump = sampleQuantumTunneling(dim)
% 量子穿隧跳躍
tunnel_strength = 0.5 * exp(-abs(randn(1, dim)));  % 穿隧強度
direction = randn(1, dim);  % 隨機方向
direction = direction / (norm(direction) + eps);  % 歸一化

jump = tunnel_strength .* direction;
end

function hybrid_step = sampleQuantumLevyHybrid(dim, tNorm)
% 量子-Levy混合步長
% 經典Levy飛行
beta = 1.5;
sigma = (gamma(1+beta) * sin(pi*beta/2) / ...
         (gamma((1+beta)/2) * beta * 2^((beta-1)/2)))^(1/beta);
u = randn(1, dim) * sigma;
v = randn(1, dim);
levy_step = u ./ abs(v).^(1/beta);

% 量子修正
quantum_factor = 0.3 * sin(2 * pi * tNorm) * exp(-tNorm);
hybrid_step = levy_step * (1 + quantum_factor);
end

function [radial_perturbation, angular_info] = sampleElectronRadialDistanceWithAngular(tNorm, dim)
% 主要的波函數電子徑像距離採樣，包含角度信息
%
% 數學模型:
% 完整的電子波函數: ψ(r,θ,φ) = R(r) * Y_l^m(θ,φ)
% 徑向部分: P(r) = |R(r)|² * r²
% 角度部分: 球諧函數分佈

% 1. 徑向距離採樣
r_radial = sampleAdvancedElectronRadial(tNorm);

% 2. 角度採樣 (球面均勻分佈)
theta = acos(2*rand - 1);              % 極角 [0,π]
phi = 2*pi*rand;                       % 方位角 [0,2π]

% 3. 自旋採樣
spin = (-1)^randi(2);                  % ±1/2 自旋

% 4. 轉換為笛卡爾坐標
dir_x = sin(theta) * cos(phi);
dir_y = sin(theta) * sin(phi);
dir_z = cos(theta);

% 5. 建立高維方向向量
directions = [dir_x, dir_y, dir_z];
radial_perturbation = zeros(1, dim);

for k = 1:dim
    radial_perturbation(k) = directions(mod(k-1, 3) + 1) * r_radial;
end

% 6. 返回角度信息
angular_info.theta = theta;
angular_info.phi = phi;
angular_info.spin = spin;
angular_info.radial_distance = r_radial;
end

function r = sampleAdvancedElectronRadial(tNorm)
% 進階的電子徑向距離採樣
% 結合量子力學精確解和數值優化需求

% 多軌道權重 (動態調整)
if tNorm < 0.3
    weights = [0.2, 0.5, 0.3];  % 初期：探索導向
elseif tNorm < 0.7
    weights = [0.5, 0.3, 0.2];  % 中期：平衡
else
    weights = [0.8, 0.15, 0.05]; % 後期：收斂導向
end

% 採樣不同能級
r1s = sampleHydrogenOrbital(1);   % 1s
r2s = sampleHydrogenOrbital(2);   % 2s  
r3s = sampleHydrogenOrbital(3);   % 3s

% 加權疊加
r = weights(1)*r1s + weights(2)*r2s + weights(3)*r3s;

% 加入量子漲落
fluctuation = 0.1 * randn * exp(-2*tNorm);
r = r + fluctuation;

% 約束範圍
r = min(max(r, 0.05), 8);
end

function r = sampleHydrogenOrbital(n)
% 氫原子軌道精確採樣
a0 = 1;  % 波爾半徑 (歸一化)

switch n
    case 1
        % 1s: P(r) = 4r²exp(-2r/a₀)
        % 對應 Gamma(3, a₀/2)
        r = gamrnd(3, a0/2);
        
    case 2
        % 2s: 數值逆變換
        u = rand;
        try
            F = @(rho) 1 - exp(-rho)*(1 + rho + rho^2/2 + rho^3/6) - u;
            r = fzero(F, [0, 15]);
        catch
            r = 2*a0;  % 失敗時使用期望值
        end
        
    case 3
        % 3s: 近似處理
        r = gamrnd(5, 0.9*a0);
        
    otherwise
        % 高量子數
        r = n^2 * a0 * (0.7 + 0.6*rand);
end

r = max(r, 0.01);  % 確保正值
end

function scale = calculateDynamicScale(tNorm, spin, particle_idx, total_particles)
% 計算動態縮放因子
% 考慮演化進度、自旋、粒子位置等因素

% 基礎縮放 (隨時間減小)
base_scale = 0.4 * (1 - tNorm^1.5);

% 自旋效應
spin_effect = 1 + 0.3 * spin;

% 粒子位置效應 (邊緣粒子更大擾動)
position_factor = 1 + 0.5 * abs(particle_idx / total_particles - 0.5);

% 隨機量子漲落
quantum_fluctuation = 1 + 0.2 * randn * exp(-3*tNorm);

scale = base_scale * spin_effect * position_factor * quantum_fluctuation;
scale = max(scale, 0.01);  % 保持最小值
end

function X_constrained = applyQuantumBoundaryConstraints(X, LB, UB, quantum_strength)
% 量子邊界約束 (包含反射效應)
X_constrained = X;

% 標準約束
below_bound = X < LB;
above_bound = X > UB;

% 量子反射 (小機率穿過邊界)
reflection_prob = 0.1 * quantum_strength;

for i = 1:length(X)
    if below_bound(i)
        if rand < reflection_prob
            X_constrained(i) = LB(i) + abs(X(i) - LB(i)) * 0.1;  % 部分穿透
        else
            X_constrained(i) = LB(i);  % 硬邊界
        end
    elseif above_bound(i)
        if rand < reflection_prob
            X_constrained(i) = UB(i) - abs(X(i) - UB(i)) * 0.1;  % 部分穿透
        else
            X_constrained(i) = UB(i);  % 硬邊界
        end
    end
end
end

function prob = calculateQuantumAcceptance(current_fitness, new_fitness, tNorm)
% 量子接受準則 (類似模擬退火)
if new_fitness <= current_fitness
    prob = 1;  % 總是接受更好的解
else
    % 量子溫度 (隨時間降低)
    temperature = 0.1 * exp(-5 * tNorm);
    delta = new_fitness - current_fitness;
    prob = exp(-delta / (temperature + eps));
    prob = min(prob, 0.1);  % 限制最大接受機率
end
end

%% =================== 傳統函數 (保持兼容性) ===================

function step = levyFlight(d)
% levyFlight  生成長尾分佈步長 (Mantegna 演算法)
beta  = 1.5;
sigma = ( gamma(1+beta) * sin(pi*beta/2) / ...
          ( gamma((1+beta)/2) * beta * 2^((beta-1)/2) ) )^(1/beta);
u = randn(1,d) * sigma;
v = randn(1,d);
step = u ./ abs(v).^(1/beta);
end
