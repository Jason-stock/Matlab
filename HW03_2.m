function HW03()
    main();
end

function main()
    % 設定訓練資料
    [train_inputs, train_targets] = generate_training_data();

    % 初始化模糊系統
    fis = initialize_fis();

    % 粒子群優化參數
    num_particles = 30; % 粒子數
    max_iter = 2000;    % 最大迭代次數

    % 執行粒子群優化
    [best_params, fitness_history] = pso(fis, train_inputs, train_targets, num_particles, max_iter);

    % 輸出最佳參數與適應值歷史
    disp('最佳參數:');
    disp(best_params);
    disp('適應值歷史:');
    disp(fitness_history);

    % 繪製適應值歷史
    figure;
    plot(fitness_history);
    xlabel('Iteration');
    ylabel('Fitness');
    title('PSO Fitness History');

    % 生成測試資料 (與訓練資料不同分布)
    [test_inputs, test_targets] = generate_testing_data();

    % 訓練階段分析與繪圖
    plot_training_results(fis, train_inputs, train_targets, best_params);

    % 測試階段分析與繪圖
    plot_testing_results(fis, test_inputs, test_targets, best_params);

end

function [inputs, targets] = generate_training_data()
    % 生成訓練資料範例
    Q = 202;
    u1 = linspace(-5.12, 5.12, Q);
    y = target_function(u1);
    inputs = [y(1:end-2)', y(2:end-1)'];
    targets = y(3:end)';
end

function [inputs, targets] = generate_testing_data()
    % 測試資料 (與訓練資料分布不同)
    N = 32;
    u2 = linspace(-2, 4, N);
    y = target_function(u2);
    inputs = [y(1:end-2)', y(2:end-1)'];
    targets = y(3:end)';
end


function fis = initialize_fis()
    % 初始化一個含有兩個輸入的模糊系統，並定義4條T-S規則
    fis.input_mfs.x1 = []; % 輸入1的高斯型模糊集參數
    fis.input_mfs.x2 = []; % 輸入2的高斯型模糊集參數
    fis.rule_num = 4;                          % 假設4條規則
    fis.If_Part_parameters = rand(fis.rule_num, 4);% 初始化前鑑部參數 (每條規則4個參數)
    fis.Then_Part_parameters = rand(fis.rule_num,3);% 初始化後鑑部參數
end

function y_hat = evaluate_fis(fis, x1, x2)
    % 計算模糊系統的輸出
    rule_num = fis.rule_num;
    y_hat = zeros(size(x1));

    for k = 1:rule_num
        % 獲取第k條規則的參數
        c1 = fis.input_mfs.x1(1, k);   % 輸入1的高斯隸屬度中心
        sigma1 = fis.input_mfs.x1(2, k); % 輸入1的高斯隸屬度標準差
        c2 = fis.input_mfs.x2(1, k);   % 輸入2的高斯隸屬度中心
        sigma2 = fis.input_mfs.x2(2, k); % 輸入2的高斯隸屬度標準差
        
        a0 = fis.parameters(k, 1);     % 第k條規則的常數項
        a1 = fis.parameters(k, 2);     % 第k條規則對應輸入1的係數
        a2 = fis.parameters(k, 3);     % 第k條規則對應輸入2的係數
        
        % 計算模糊隸屬度 (高斯函數)
        mf_x1 = exp(-((x1 - c1).^2) / (2 * sigma1^2));
        mf_x2 = exp(-((x2 - c2).^2) / (2 * sigma2^2));

        % 計算第k條規則的貢獻
        rule_output = a0 + a1 * mf_x1 + a2 * mf_x2;
        
        % 將每條規則的貢獻加總到最終輸出中
        y_hat = y_hat + rule_output .* mf_x1 .* mf_x2;
    end
    
    % 正規化輸出（可選）
    y_hat = y_hat / sum(mf_x1 .* mf_x2);
end

function [best_params, fitness_history] = pso(fis, train_inputs, train_targets, num_particles, max_iter)
    % 初始化參數
    rule_num = fis.rule_num;
    num_params = rule_num * 4; % 每條規則4個參數
    particles(num_particles) = struct();
    fitness_history = zeros(1, max_iter);
    global_best_position = [];
    global_best_fitness = inf;

    % 初始化粒子
    for i = 1:num_particles
        particles(i).position = rand(1, num_params) * 2 - 1; % 初始化為 [-1, 1]
        particles(i).velocity = zeros(1, num_params);        % 初始速度為 0
        particles(i).best_position = particles(i).position;
        particles(i).best_fitness = inf;
    end

    % 迭代更新
    for iter = 1:max_iter
        for i = 1:num_particles
            % 更新 FIS 參數
            if numel(particles(i).position) ~= num_params
                error('Particle position size mismatch. Expected %d, got %d.', ...
                    num_params, numel(particles(i).position));
            end

            fis.parameters = reshape(particles(i).position, rule_num, 3);

            % 計算適應值 (均方誤差)
            y_pred = evaluate_fis(fis, train_inputs(i:i+4, 1), train_inputs(i:i+4, 2));
            fitness = mean((y_pred - train_targets).^2);

            % 更新個體最佳
            if fitness < particles(i).best_fitness
                particles(i).best_fitness = fitness;
                particles(i).best_position = particles(i).position;
            end

            % 更新全局最佳
            if fitness < global_best_fitness
                global_best_fitness = fitness;
                global_best_position = particles(i).position;
            end
        end

        % 更新速度和位置
        for i = 1:num_particles
            w = 0.5; % 慣性權重
            c1 = 1.5; % 個體加速度
            c2 = 1.5; % 群體加速度
            r1 = rand(1, num_params);
            r2 = rand(1, num_params);

            particles(i).velocity = w * particles(i).velocity + ...
                c1 * r1 .* (particles(i).best_position - particles(i).position) + ...
                c2 * r2 .* (global_best_position - particles(i).position);

            particles(i).position = particles(i).position + particles(i).velocity;
        end

        % 保存當前迭代的最佳適應值
        fitness_history(iter) = global_best_fitness;

        % 打印進度
        fprintf('Iteration %d/%d, Best Fitness: %f\n', iter, max_iter, global_best_fitness);
    end

    % 返回最優參數和適應值歷史
    best_params = global_best_position;
end
% 訓練階段函數逼近結果與最佳 MSE
function plot_training_results(fis, train_inputs, train_targets, best_params)
    % 更新 FIS 參數為最佳參數
    fis.parameters = reshape(best_params, fis.rule_num, 3);

    % 使用最佳模型進行函數逼近
    y_pred_train = evaluate_fis(fis, train_inputs(:, 1), train_inputs(:, 2));

    % 計算訓練 MSE
    mse_train = mean((y_pred_train - train_targets).^2);
    fprintf('最佳訓練 MSE: %f\n', mse_train);

    % 繪製輸入-輸出曲線 (訓練)
    figure;
    plot(1:length(train_targets), train_targets, 'b-', 'LineWidth', 1.5); hold on;
    plot(1:length(y_pred_train), y_pred_train, 'r--', 'LineWidth', 1.5);
    legend('目標函數', '模型輸出');
    title('訓練階段函數逼近結果');
    xlabel('樣本編號');
    ylabel('輸出值');
    grid on;
    hold off;
end

% 測試階段函數逼近結果與 MSE
function plot_testing_results(fis, test_inputs, test_targets, best_params)
    % 更新 FIS 參數為最佳參數
    fis.parameters = reshape(best_params, fis.rule_num, 3);

    % 使用最佳模型進行函數逼近
    y_pred_test = evaluate_fis(fis, test_inputs(:, 1), test_inputs(:, 2));

    % 計算測試 MSE
    mse_test = mean((y_pred_test - test_targets).^2);
    fprintf('測試階段 MSE: %f\n', mse_test);

    % 繪製輸入-輸出曲線 (測試)
    figure;
    plot(1:length(test_targets), test_targets, 'b-', 'LineWidth', 1.5); hold on;
    plot(1:length(y_pred_test), y_pred_test, 'r--', 'LineWidth', 1.5);
    legend('目標函數', '模型輸出');
    title('測試階段函數逼近結果');
    xlabel('樣本編號');
    ylabel('輸出值');
    grid on;
    hold off;
end

function y = target_function(u)
    y = u.^2 - 10 * cos(2 * pi * u) + 10;
end
