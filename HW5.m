% 產生訓練資料集
train_set = linspace(-5.12, 5.12, 202);
train_set_target = target_func(train_set);

% PSO algorithm
% 學習因子
c1 = 2;
c2 = 2;

% tier_max
t_max = 2000;

% weights
w_start = 0.95;
w_end = 0.65;

% number of particles
particles = 30;

% 初始化velocity
% 16條規則，每條規則7個參數 => 16*7 = 112
v = rand(particles, 112);

% 初始化position
p = rand(particles, 112);

% 初始化pbest
pbest = p;

% 初始化gbest
gbest = p(1, :);

% 儲存MSE
total_best_mse = [];

% PSO主迴圈
for t = 1:t_max
    
    % 動態權重
    w = w_start - (w_start - w_end) / t_max * t;

    % 隨機值
    s1 = rand(particles, 112);
    s2 = rand(particles, 112);
  
    % 更新粒子位置和速度
    new_p = p + v;
    new_velocity = w .* v + c1 .* s1 .* (pbest - new_p) + c2 .* s2 .* ((gbest .* ones(particles, 112)) - new_p);
    
    for i = 1:particles
        % 計算粒子的MSE
        target_y = train_set_target(3:end);
        new_p_mse = MSEfunc(FIS_model(new_p(i, :), train_set_target), target_y);
        pbest_mse = MSEfunc(FIS_model(pbest(i, :), train_set_target), target_y);

        % 更新pbest
        if new_p_mse < pbest_mse
            pbest(i, :) = new_p(i, :);
        end

        % 更新gbest
        gbest_mse = MSEfunc(FIS_model(gbest, train_set_target), target_y);
        if new_p_mse < gbest_mse
            gbest = new_p(i, :);
        end
    end

    % 更新位置與速度
    p = new_p;
    v = new_velocity;

    % 儲存當前最佳MSE
    total_best_mse(t) = gbest_mse;  
end

% 學習曲線圖
plot(linspace(1, length(total_best_mse), length(total_best_mse)), total_best_mse);
xlabel("疊代 q");
ylabel("MSE(q)");
title("學習曲線圖");

% 最佳模型之函數逼近結果圖(訓練模型)
target_output = train_set_target(3:end);
train_input = train_set(3:end);
model_output = FIS_model(gbest, train_set_target);
plot(train_input, model_output, '-b', train_input, target_output, '-r');
xlabel("輸入");
ylabel("輸出");
title("最佳模型之函數逼近結果圖(訓練模型)");

% training stage best mse
best_mse = min(total_best_mse)

% 最佳模型之函數逼近結果圖(測試模型)
test_input = linspace(-2, 4, 32);
test_target_output = target_func(test_input);
test_model_output = FIS_model(gbest, test_target_output);
plot(test_input(3:end), test_model_output, '-b', test_input(3:end), test_target_output(3:end), '-r');
xlabel("輸入");
ylabel("輸出");
title("最佳模型之函數逼近結果圖(測試模型)");

% testing stage mse
test_mse = MSEfunc(test_model_output, test_target_output(3:end));

% --- 模型相關函數 ---
function mu = gaussian_func(h, c, sigma)
% 高斯模糊集
mu = exp(-((h - c).^2) / (2 * sigma.^2));
end

function output = MSEfunc(model_y, target_y)
% 均方誤差 (MSE)
e = target_y - model_y;
Q = length(e);
output = sum(e.^2) / Q;
end

function output = target_func(mu)
% 測試函數
output = (mu.^2 - 10 .* (cos(2 .* pi .* mu)) + 10);
end

function output = FIS_model(param, test_set)
% 參數提取
c = reshape(param(1:32), [4, 2]);     % 16條規則的中心參數
sigma = reshape(param(33:64), [4, 2]); % 16條規則的標準差參數
a0 = param(65:80);                     % Then-part 偏置項
a1 = param(81:96);                     % Then-part 一階項 (x1)
a2 = param(97:112);                    % Then-part 二階項 (x2)

y = [];
for i = 1 : length(test_set) - 2
    h1 = test_set(i);      % 第一個輸入
    h2 = test_set(i + 1);  % 第二個輸入

    % 計算規則隸屬值與輸出
    w = zeros(1, 16);
    R = zeros(1, 16);
    for k = 1:16
        A1_k = gaussian_func(h1, c(k, 1), sigma(k, 1));
        A2_k = gaussian_func(h2, c(k, 2), sigma(k, 2));

        w(k) = min(A1_k, A2_k); % 規則權重
        R(k) = a0(k) + a1(k) * h1 + a2(k) * h2; % 規則輸出
    end

    % 加權平均計算輸出
    y(i) = sum(w .* R) / sum(w);
end
output = y;
end

