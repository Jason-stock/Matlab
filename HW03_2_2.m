function HW03_Problem2()
    % 生成訓練和測試資料
    [train_inputs, train_targets] = generate_data(-5.12, 5.12, 202);
    [test_inputs, test_targets] = generate_data(-2, 4, 32);

    % 初始化模糊推理系統
    fis = initialize_fis();

    % 訓練模糊系統 (使用粒子群優化)
    [best_params, fitness_history] = pso(fis, train_inputs, train_targets, 30, 2000);

    % 學習曲線繪製
    figure;
    plot(fitness_history, 'LineWidth', 1.5);
    title('學習曲線 (MSE vs Iteration)');
    xlabel('疊代次數');
    ylabel('MSE');
    grid on;

    % 訓練階段結果
    fprintf('訓練階段最佳 MSE: %.6f\n', min(fitness_history));
    plot_training_results(fis, train_inputs, train_targets, best_params);

    % 測試階段結果
    plot_testing_results(fis, test_inputs, test_targets, best_params);
end

%% 數據生成
function [inputs, targets] = generate_data(start_u, end_u, num_points)
    % 生成目標函數數據
    u = linspace(start_u, end_u, num_points);
    y = u.^2 - 10 * cos(2 * pi * u) + 10; % 目標函數
    inputs = [y(1:end-2)', y(2:end-1)'];
    targets = y(3:end)';
end

%% 模糊推理系統初始化
function fis = initialize_fis()
    % 初始化模糊系統結構
    fis.rule_num = 4; % 規則數量
    fis.parameters = rand(fis.rule_num, 3); % 隨機初始化規則參數 [a0, a1, a2]

    % 定義每條規則的隸屬函數參數 (高斯模糊集)
    fis.input_mfs.x1 = [2, 0.8; 3, 1]; % 每行 [c, sigma]
    fis.input_mfs.x2 = [1, 0.6; 2.5, 0.9];
end

%% FIS 輸出計算
function y_hat = evaluate_fis(fis, x1, x2)
    % 計算模糊推理系統的輸出
    rule_num = fis.rule_num;
    firing_strengths = zeros(rule_num, length(x1));
    rule_outputs = zeros(rule_num, length(x1));

    for k = 1:rule_num
        % 取模糊隸屬函數參數
        c1 = fis.input_mfs.x1(mod(k-1, size(fis.input_mfs.x1, 1)) + 1, 1);
        sigma1 = fis.input_mfs.x1(mod(k-1, size(fis.input_mfs.x1, 1)) + 1, 2);

        c2 = fis.input_mfs.x2(floor((k-1) / size(fis.input_mfs.x2, 1)) + 1, 1);
        sigma2 = fis.input_mfs.x2(floor((k-1) / size(fis.input_mfs.x2, 1)) + 1, 2);

        % 計算隸屬度
        mu1 = exp(-0.5 * ((x1 - c1) ./ sigma1).^2);
        mu2 = exp(-0.5 * ((x2 - c2) ./ sigma2).^2);

        % 計算規則隸屬度與輸出
        firing_strengths(k, :) = min(mu1, mu2); % 隸屬度取最小值
        rule_outputs(k, :) = fis.parameters(k, 1) + fis.parameters(k, 2) .* x1 + fis.parameters(k, 3) .* x2;
    end

    % 加權輸出
    numerator = sum(firing_strengths .* rule_outputs, 1);
    denominator = sum(firing_strengths, 1) + 1e-6; % 防止除以 0
    y_hat = numerator ./ denominator;
end

%% 粒子群優化 (PSO)
function [best_params, fitness_history] = pso(fis, train_inputs, train_targets, num_particles, max_iter)
    % 初始化參數
    num_params = fis.rule_num * 3; % 每條規則 3 個參數
    particles(num_particles) = struct();
    fitness_history = inf(1, max_iter); % 初始化學習曲線
    global_best_position = [];
    global_best_fitness = inf; % 初始化全域最佳適應值

    % 初始化粒子
    for i = 1:num_particles
        particles(i).position = rand(1, num_params) * 2 - 1; % 隨機初始化 [-1, 1]
        particles(i).velocity = zeros(1, num_params);
        particles(i).best_position = particles(i).position;
        particles(i).best_fitness = inf; % 個體最佳適應值初始化
    end

    % 迭代更新
    for iter = 1:max_iter
        for i = 1:num_particles
            % 更新 FIS 參數
            fis.parameters = reshape(particles(i).position, fis.rule_num, 3);

            % 計算適應值 (均方誤差)
            y_pred = evaluate_fis(fis, train_inputs(:, 1), train_inputs(:, 2));
            fitness = mean((y_pred - train_targets).^2); % 確保 fitness 是標量

            % 更新個體最佳
            if fitness < particles(i).best_fitness
                particles(i).best_fitness = fitness;
                particles(i).best_position = particles(i).position;
            end

            % 更新全域最佳
            if fitness < global_best_fitness
                global_best_fitness = fitness;
                global_best_position = particles(i).position;
            end
        end

        % 更新速度和位置
        for i = 1:num_particles
            w = 0.7; % 慣性權重
            c1 = 1.5; % 認知因子
            c2 = 1.5; % 社會因子
            r1 = rand(1, num_params);
            r2 = rand(1, num_params);

            particles(i).velocity = w * particles(i).velocity + ...
                c1 * r1 .* (particles(i).best_position - particles(i).position) + ...
                c2 * r2 .* (global_best_position - particles(i).position);

            particles(i).position = particles(i).position + particles(i).velocity;
        end

        % 保存當前最佳適應值
        fitness_history(iter) = global_best_fitness; % 確保這裡為標量
        fprintf('Iteration %d/%d, Best Fitness: %.6f\n', iter, max_iter, global_best_fitness);
    end

    best_params = global_best_position;
end


%% 訓練階段結果繪製
function plot_training_results(fis, inputs, targets, best_params)
    fis.parameters = reshape(best_params, fis.rule_num, 3);
    y_pred = evaluate_fis(fis, inputs(:, 1), inputs(:, 2));
    mse = mean((y_pred - targets).^2);
    fprintf('訓練階段 MSE: %.6f\n', mse);

    figure;
    plot(1:length(targets), targets, 'b-', 'LineWidth', 1.5); hold on;
    plot(1:length(y_pred), y_pred, 'r--', 'LineWidth', 1.5);
    title('訓練階段函數逼近結果');
    legend('目標函數', '模型輸出');
    xlabel('樣本編號');
    ylabel('輸出值');
    grid on;
end

%% 測試階段結果繪製
function plot_testing_results(fis, inputs, targets, best_params)
    fis.parameters = reshape(best_params, fis.rule_num, 3);
    y_pred = evaluate_fis(fis, inputs(:, 1), inputs(:, 2));
    mse = mean((y_pred - targets).^2);
    fprintf('測試階段 MSE: %.6f\n', mse);

    figure;
    plot(1:length(targets), targets, 'b-', 'LineWidth', 1.5); hold on;
    plot(1:length(y_pred), y_pred, 'r--', 'LineWidth', 1.5);
    title('測試階段函數逼近結果');
    legend('目標函數', '模型輸出');
    xlabel('樣本編號');
    ylabel('輸出值');
    grid on;
end
HW03_Problem2();