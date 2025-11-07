QAO_optimization()
function QAO_optimization
    % QAO_optimization
    % 針對 5 個常見測試函數（Sphere / Rastrigin / Rosenbrock / Ackley / Griewank）
    % 在 dimList 維度下執行，繪製收斂曲線，並在 Command Window 印出最佳解與最佳目標值。

    % ===== 參數設定 =====
    dimList    = [30, 50, 100];   % 測試維度
    max_iter   = 2000;            % 最大迭代數
    n_particles = 50;             % 族群數量

    % ===== 測試函數定義 =====
    functions = {@sphere, @rastrigin, @rosenbrock, @ackley, @griewank};
    function_names = {'Sphere Function', 'Rastrigin Function', 'Rosenbrock Function', 'Ackley Function', 'Griewank Function'};
    % 對應的搜尋範圍（[lb, ub]），會依維度展開
    bounds = [
        -5.12      5.12      % Sphere（可用較廣也行）
        -5.12      5.12      % Rastrigin
        -5.0       10.0      % Rosenbrock
        -32.768    32.768    % Ackley
        -600       600       % Griewank
    ];

    % 新增運行次數參數
    n_runs = 15;                  % 運行次數
    
    % 初始化統計結果儲存
    all_results = zeros(length(dimList), length(functions), n_runs);
    all_convergence = zeros(length(dimList), length(functions), n_runs, max_iter);

    for d = 1:length(dimList)
        dim = dimList(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);

        for i = 1:length(functions)
            fprintf('Running %s (%d-D)...\n', function_names{i}, dim);
            
            % 執行15次實驗
            run_results = zeros(n_runs, 1);
            run_convergence = zeros(n_runs, max_iter);
            
            for run = 1:n_runs
                rng('shuffle');  % 每次運行使用不同的隨機種子
                [bestCost, best_cost_history, bestX] = ao_run(functions{i}, dim, max_iter, n_particles, bounds(i, :));
                
                run_results(run) = bestCost;
                run_convergence(run, :) = best_cost_history;
                
                fprintf('  Run %2d: %.6e\n', run, bestCost);
            end
            
            % 儲存結果
            all_results(d, i, :) = run_results;
            all_convergence(d, i, :, :) = run_convergence;
            
            % 統計分析
            best_result = min(run_results);
            worst_result = max(run_results);
            mean_result = mean(run_results);
            std_result = std(run_results);
            
            % 輸出統計結果
            fprintf('\n===== %s (%d-D) Statistics =====\n', function_names{i}, dim);
            fprintf('Best:     %.8e\n', best_result);
            fprintf('Worst:    %.8e\n', worst_result);
            fprintf('Mean:     %.8e\n', mean_result);
            fprintf('Std Dev:  %.8e\n', std_result);
            fprintf('==========================================\n\n');
            
            % 找到15次運行中最佳的那次
            [~, best_run_idx] = min(run_results);
            
            % 定義迭代序列
            iterations = 1:max_iter;
            
            % 繪製15次中最佳那次的收斂曲線（單獨圖表）
            figure('Color','w','Name',sprintf('%s (%d-D) - Best Run Convergence', function_names{i}, dim));
            best_convergence_curve = squeeze(run_convergence(best_run_idx, :));
            plot(iterations, max(best_convergence_curve, eps), 'r-', 'LineWidth', 2.5);
            set(gca, 'YScale', 'log');
            xlabel('Iterations', 'FontSize', 12);
            ylabel('Best Objective (log scale)', 'FontSize', 12);
            title(sprintf('%s (%d-D) - Best Run Convergence Curve\nBest Value: %.8e', ...
                  function_names{i}, dim, best_result), 'Interpreter','none', 'FontSize', 14);
            grid on;
            
            % 添加最終值標註
            text(max_iter*0.7, max(best_convergence_curve(end)*10, eps), ...
                 sprintf('Final: %.6e', best_convergence_curve(end)), ...
                 'FontSize', 11, 'BackgroundColor', 'yellow', 'EdgeColor', 'black', 'FontWeight', 'bold');
            
            % 添加初始值標註
            text(max_iter*0.05, max(best_convergence_curve(1), eps), ...
                 sprintf('Initial: %.6e', best_convergence_curve(1)), ...
                 'FontSize', 11, 'BackgroundColor', 'white', 'EdgeColor', 'black');
        end
    end
    
    % 生成總結報告
    fprintf('\n\n========== FINAL SUMMARY REPORT ==========\n');
    for d = 1:length(dimList)
        dim = dimList(d);
        fprintf('\n--- Dimension: %d ---\n', dim);
        fprintf('%-18s | %-12s | %-12s | %-12s | %-12s\n', ...
                'Function', 'Best', 'Worst', 'Mean', 'Std Dev');
        fprintf('%s\n', repmat('-', 1, 80));
        
        for i = 1:length(functions)
            results = squeeze(all_results(d, i, :));
            fprintf('%-18s | %.6e | %.6e | %.6e | %.6e\n', ...
                    function_names{i}, min(results), max(results), ...
                    mean(results), std(results));
        end
    end
    fprintf('==========================================\n');
end

% ===================== QAO 外掛器（符合 PSO_optimization 呼叫介面） =====================
function [bestCost, best_cost_history, bestX] = qao_run(func, dim, max_iter, n_particles, bound1x2)
    % 這個包裝器會把 QAO 在 [0,1]^D 求解，並映射到 [lb,ub] 範圍去評估 func

    % AO/QAO 參數（沿用你提供的）
    alpha = 0.1;            % exploitation 調整
    delta = 0.1;            % exploitation 調整
    u = 0.00565;            % Levy flight 參數
    w  = 0.005;               % ω
    theta1 = 3*pi/2;

    % 這裡的 D1 為整數序列 1:D（見下方說明）
    

    % 維度對應的界線
    lb = bound1x2(1)*ones(1, dim);    %bound1x2(1) 取的是下限值（例如 −5.12）。
                                      
    ub = bound1x2(2)*ones(1, dim);    %bound1x2(2)取的是上限值（例如 +5.12）。

    % 初始化族群（在 [0,1]^D）
    X = rand(n_particles, dim);
    fitness = zeros(n_particles, 1);

    % 初始 fitness
    for p = 1:n_particles
        x_real = denorm01_to_bounds(X(p,:), lb, ub);
        func_output = func(x_real);
        fitness(p) = SSE(func_output, 0);  % 使用SSE損失函數，目標值為0
    end

    [gBestVal, idx] = min(fitness);
    gBest = X(idx, :);
    bestX = denorm01_to_bounds(gBest, lb, ub);
    bestCost = gBestVal;

    best_cost_history = zeros(max_iter, 1);
    % 將完整波型內的面積算出來，使用matlab trapz()函式計算
    a0 = 1; 
    num_slots = 10000;
    num_points = num_slots + 1;

    % 原始 X 軸：物理距離 r (範圍 [0, 30])
    r_values_original = linspace(0, 30, num_points);

    % Y 軸：計算對應的機率密度 P(r)
    P_r_values = (4 / a0^3) .* (r_values_original.^2) .* exp(-2 .* r_values_original ./ a0);
    % (可選) 歸一化Y軸面積，這不影響X軸的調整
    area = trapz(r_values_original, P_r_values);
    P_r_values_normalized = P_r_values / area;

    for t = 1:max_iter
        X_mean = mean(X, 1);
        G1 = 2*rand() - 1;
        G2 = 2*(1 - t/max_iter);

        for p = 1:n_particles
            if t <= (2/3)*max_iter
                if rand < 0.5
                    % Expanded exploration (1) - 氫原子 1s 徑向
                    r_norm = inverse_transform_sampling(dim);
                    direction = norm(X_mean - gBest);
                    X_new = gBest.*(t/max_iter) + r_norm .* direction;
                else
                    % Narrowed exploration (2) - 氫原子 1s 徑向分佈（原點-電子模型）
                    % 原點當作質子，X_random 當作電子
                    rand_idx = floor(n_particles * rand) + 1;
                    X_rand = X(rand_idx, :);  % 隨機個體作為電子位置
                    
                    % 使用氫原子1s軌域的徑向分佈
                    r_norm = inverse_transform_sampling(dim);
                    
                    % 計算從原點（質子）到隨機個體（電子）的方向
                    origin = zeros(1, dim);  % 原點座標
                    direction = norm(X_rand - origin);  % 從質子到電子的方向向量

                    r1 = 1 + (20-1)*rand;     % r1 ∈ [1,20]
                    D1 = 1:dim;
                    r = r1 + u * D1;
                    theta = -w * D1 + theta1;
    

                    y = r .* cos(theta);
                    x = r .* sin(theta);

                    spiral = (y - x) .* rand(1, dim);
                    
                    % 新位置 = 質子位置 + 氫原子機率分佈距離 * 方向
                    X_new = gBest.*levy_step(dim, u) + origin + r_norm .* direction + spiral;
                end
            else
                if rand < 0.5
                    % Expanded exploitation (3)
                    X_new = (gBest - X_mean)*alpha - rand + (rand)*delta;
                else
                    % Narrowed exploitation (4)
                    QF = t^((2*rand - 1)/(1 - max_iter)^2);
                    X_new = QF .* gBest - (G1 .* X(p, :)*rand) - G2 .* levy_step(dim, u) + rand*G1;
                end
            end

            % 邊界裁切（仍在 [0,1]）
            X_new = min(max(X_new, 0), 1);

            % 評估
            x_real = denorm01_to_bounds(X_new, lb, ub);
            func_output = func(x_real);
            fNew = SSE(func_output, 0);  % 使用SSE損失函數，目標值為0

            % 個體更新
            if fNew < fitness(p)
                X(p, :) = X_new;
                fitness(p) = fNew;
            end
        end

        % 全域最佳更新
        [minFit, minIdx] = min(fitness);
        if minFit < gBestVal
            gBestVal = minFit;
            gBest = X(minIdx, :);
            bestX = denorm01_to_bounds(gBest, lb, ub);
            bestCost = gBestVal;
        end

        best_cost_history(t) = gBestVal;
    end
end

function [bestCost, best_cost_history, bestX] = ao_run(func, dim, max_iter, n_particles, bound1x2)
    % 這個包裝器在 [0,1]^D 搜尋，評估時映射到實際 [lb,ub]
    % 規則沿用你貼的 AO：四種策略 + Levy 擾動 + [0,1] 邊界裁切

    % AO 參數（依你原始碼）
    alpha = 0.1;            % exploitation 調整
    delta = 0.1;            % exploitation 調整
    u = 0.00565;            % Levy flight 參數
    r1 = 10;                % Levy flight 參數（未顯式用到，保留一致性）

    % 邊界
    lb = bound1x2(1) * ones(1, dim);
    ub = bound1x2(2) * ones(1, dim);

    % 初始化族群（在 [0,1]^D）
    X = rand(n_particles, dim);
    fitness = zeros(n_particles, 1);

    % 初始評估
    for p = 1:n_particles
        x_real = denorm01_to_bounds(X(p, :), lb, ub);
        func_output = func(x_real);
        fitness(p) = SSE(func_output, 0);  % 使用SSE損失函數，目標值為0
    end

    [gBestVal, idx] = min(fitness);
    gBest = X(idx, :);
    bestX = denorm01_to_bounds(gBest, lb, ub);
    bestCost = gBestVal;

    best_cost_history = zeros(max_iter, 1);

    for t = 1:max_iter
        X_mean = mean(X, 1);
        G1 = 2*rand() - 1;
        G2 = 2 * (1 - t / max_iter);

        for p = 1:n_particles
            if t <= (2/3) * max_iter
                if rand < 0.5
                    % Expanded exploration (1)
                    X_new = gBest .* (1 - t/max_iter) + (X_mean - gBest * rand);
                else
                    % Narrowed exploration (2) with Lévy
                    levy_val = levy_step(dim, u);
                    rand_idx = floor(n_particles * rand) + 1;
                    X_rand = X(rand_idx, :);
                    X_new = gBest .* levy_val + X_rand + (rand - 0.5) * 1e-3;
                end
            else
                if rand < 0.5
                    % Expanded exploitation (3)
                    X_new = (gBest - X_mean) * alpha - rand + (rand) * delta;
                else
                    % Narrowed exploitation (4)
                    QF = t^((2*rand - 1)/(1 - max_iter)^2);
                    X_new = QF .* gBest - (G1 .* X(p, :) * rand) - G2 .* levy_step(dim, u) + rand * G1;
                end
            end

            % 邊界裁切（保持在 [0,1]）
            X_new = min(max(X_new, 0), 1);

            % 評估
            x_real = denorm01_to_bounds(X_new, lb, ub);
            func_output = func(x_real);
            fNew = SSE(func_output, 0);  % 使用SSE損失函數，目標值為0

            % 個體更新
            if fNew < fitness(p)
                X(p, :) = X_new;
                fitness(p) = fNew;
            end
        end

        % 全域最佳更新
        [minFit, minIdx] = min(fitness);
        if minFit < gBestVal
            gBestVal = minFit;
            gBest = X(minIdx, :);
            bestX = denorm01_to_bounds(gBest, lb, ub);
            bestCost = gBestVal;
        end

        best_cost_history(t) = gBestVal;
    end
end

% ===================== 工具函數 =====================
function xr = denorm01_to_bounds(x01, lb, ub)
    xr = lb + x01 .* (ub - lb);
end

function step = levy_step(d, u)
    % 與你版本一致的 Lévy 取樣（beta=1.5，比例 0.01）
    w = u * randn(1, d);
    v = randn(1, d);
    beta = 1.5;
    step = 0.01 * (w ./ (abs(v).^(1/beta)));
end

function r_norm = inverse_transform_sampling(dim)
    % 氫原子 1s 徑向分佈 P(r) ~ r^2 exp(-2r)
    u = rand(1, dim);
    r = ones(1, dim);
    max_iter = 20;
    tol = 1e-8;

    for i = 1:dim
        g  = @(x) 1 - (2*x^2 + 2*x + 1) * exp(-2*x) - u(i);
        gp = @(x) 4 * x.^2 .* exp(-2*x);

        ri = (u(i) < 0.5) * 0.5 + (u(i) >= 0.5) * 2.0;
        for it = 1:max_iter
            fx = g(ri);
            if abs(fx) < tol, break; end
            fpx = gp(ri);
            if abs(fpx) < 1e-12
                ri = ri + tol;
                continue;
            end
            ri_new = ri - fx / fpx;
            if ri_new < 0, ri_new = tol; elseif ri_new > 10, ri_new = 10; end
            if abs(ri_new - ri) < tol, ri = ri_new; break; end
            ri = ri_new;
        end
        r(i) = ri;
    end

    r_norm = r / 6.0;               % 99.9% 質機率密度 ~ [0,6]
    r_norm = min(max(r_norm, 0), 1);
end

function U_x = rescale_axis_range(G_x, Umin_x, Umax_x)
%RESCALE_AXIS_RANGE 將輸入的 X 軸向量 G_x 線性映射到一個新的範圍 [Umin_x, Umax_x]
%
%   輸入:
%       G_x    - 原始的 X 軸數據向量 (例如 r_values)
%       Umin_x - 目標 X 軸範圍的最小值
%       Umax_x - 目標 X 軸範圍的最大值
%
%   輸出:
%       U_x    - 調整到新範圍的 X 軸數據向量

    % 獲取 G_x 的實際最大值和最小值
    Gmin_x = min(G_x);
    Gmax_x = max(G_x);
    
    % 檢查 Gmax 和 Gmin 是否相同，以避免除以零
    if Gmax_x == Gmin_x
        U_x = ones(size(G_x)) * Umin_x;
        warning('輸入的 X 軸向量所有元素都相同。');
        return;
    end

    % 應用標準範圍調整公式 (與 Y 軸調整的邏輯相同)
    % U_x = ( (G_x - Gmin_x) / (Gmax_x - Gmin_x) ) * (Umax_x - Umin_x) + Umin_x;
    U_x = ((G_x - Gmin_x) ./ (Gmax_x - Gmin_x)) .* (Umax_x - Umin_x) + Umin_x;
end

% ===================== 測試函數 =====================
function y = sphere(x)
    % global optimum at x=0, f=0
    y = sum(x.^2);
end

function y = rastrigin(x)
    % global optimum at x=0, f=0
    A = 10;
    D = numel(x);
    y = A*D + sum(x.^2 - A*cos(2*pi*x));
end

function y = rosenbrock(x)
    % global optimum at x=1, f=0
    y = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);
end

function y = ackley(x)
    % global optimum at x=0, f=0
    a = 20; b = 0.2; c = 2*pi;
    D = numel(x);
    s1 = sum(x.^2);
    s2 = sum(cos(c*x));
    y = -a*exp(-b*sqrt(s1/D)) - exp(s2/D) + a + exp(1);
end

function y = griewank(x)
    % global optimum at x=0, f=0
    D = numel(x);
    sumTerm = sum(x.^2)/4000;
    prodTerm = 1;
    for i = 1:D
        prodTerm = prodTerm * cos(x(i)/sqrt(i));
    end
    y = sumTerm - prodTerm + 1;
end

function [sse] = SSE(Y_output, Y_target)
    % SSE: Sum of Squared Errors
    % Y_output, Y_target 大小為 N x D
    div = Y_output - Y_target;

    % 把所有樣本、所有維度的誤差平方加總
    sse = sum(div(:).^2);
end
