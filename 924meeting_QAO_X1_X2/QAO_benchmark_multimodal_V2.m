QAO_optimization()
function QAO_optimization
    % QAO_optimization
    % 針對 13 個古典測試函數（F1-F13）
    % 在 dimList 維度下執行。
    % [修改] 將每個維度(30D, 50D, 100D)的所有函數(F1-F13)繪製在同一張圖上。

    % ===== 參數設定 =====
    dimList    = [30];   % 測試維度
    max_iter   = 2000;            % 最大迭代數
    n_particles = 50;             % 族群數量

    % ===== 測試函數定義 (F1-F13 from Aquila Optimizer PDF Tables 2 & 3) =====
    functions = {
        @sphere, @f2, @f3, @f4, @rosenbrock, @f6, @f7, ... % F1-F7
        @f8, @rastrigin, @ackley, @griewank, @f12, @f13     % F8-F13
    };
    function_names = {
        'F1 (Sphere)', 'F2', 'F3', 'F4', 'F5 (Rosenbrock)', 'F6', 'F7', ...
        'F8', 'F9 (Rastrigin)', 'F10 (Ackley)', 'F11 (Griewank)', 'F12', 'F13'
    };
    % 對應的搜尋範圍（[lb, ub]），會依維度展開 (from PDF Tables 2 & 3)
    bounds = [
        -100,    100      % F1
        -10,     10       % F2
        -100,    100      % F3
        -100,    100      % F4
        -30,     30       % F5 (PDF Table 2)
        -100,    100      % F6
        -128,    128      % F7
        -500,    500      % F8
        -5.12,   5.12     % F9
        -32,     32       % F10 (PDF Table 3)
        -600,    600      % F11
        -50,     50       % F12
        -50,     50       % F13
    ];


    % 新增運行次數參數
    n_runs = 15;                  % 運行次數
    
    % 優化：使用更精確的變數命名和預分配
    n_dims = length(dimList);
    n_funcs = length(functions);
    all_results = zeros(n_dims, n_funcs, n_runs);
    all_convergence = zeros(n_dims, n_funcs, n_runs, max_iter);

    for d = 1:n_dims
        dim = dimList(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);

        % [修改] 儲存此維度下所有函數的最佳收斂曲線
        all_best_curves_for_dim = zeros(n_funcs, max_iter);
        
        % [修改] 在函數迴圈開始前，為此維度建立一個新圖形
        figure('Color','w','Name',sprintf('All Functions (%d-D) - Best Run Convergence', dim));
        hold on;
        set(gca, 'YScale', 'log');
        title(sprintf('Convergence Curves (%d-D) - Best of %d Runs', dim, n_runs), 'FontSize', 14);
        xlabel('Iterations', 'FontSize', 12);
        ylabel('Best Objective (log scale)', 'FontSize', 12);
        grid on;

        for i = 1:n_funcs
            fprintf('Running %s (%d-D)...\n', function_names{i}, dim);
            
            % 執行15次實驗
            run_results = zeros(n_runs, 1);
            run_convergence = zeros(n_runs, max_iter);
            
            for run = 1:n_runs
                rng('shuffle');  % 每次運行使用不同的隨機種子
                [bestCost, best_cost_history, bestX] = qao_run(functions{i}, dim, max_iter, n_particles, bounds(i, :));
                
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
            best_convergence_curve = squeeze(run_convergence(best_run_idx, :));

            % [修改] 儲存最佳曲線以供後續繪圖
            all_best_curves_for_dim(i, :) = best_convergence_curve;
            
            % [修改] 移除此處的單獨繪圖程式碼
            % (原來的 figure, plot, title, text 程式碼已刪除)
        end

        % [修改] 函數迴圈結束後，在此維度的圖形上繪製所有曲線
        iterations = 1:max_iter;
        colors = lines(7); % 使用 7 種基礎顏色
        lineStyles = {'-', '--', ':', '-.'};
        n_colors = size(colors, 1);
        n_styles = length(lineStyles);
        
        for i = 1:n_funcs
            % 優化：預先計算索引，避免重複計算
            color_idx = mod(i-1, n_colors) + 1;
            style_idx = mod(floor((i-1) / n_colors), n_styles) + 1;
            
            % 優化：使用 max 確保數值大於 eps，避免 log(0)
            plot(iterations, max(all_best_curves_for_dim(i, :), eps), ...
                'DisplayName', function_names{i}, ...
                'LineWidth', 2, ...
                'Color', colors(color_idx, :), ...
                'LineStyle', lineStyles{style_idx});
        end
        
        legend('show', 'Interpreter', 'none', 'Location', 'northeastoutside');
        hold off;
    end
    
    % 生成總結報告
    fprintf('\n\n========== FINAL SUMMARY REPORT ==========\n');
    for d = 1:n_dims
        dim = dimList(d);
        fprintf('\n--- Dimension: %d ---\n', dim);
        fprintf('%-18s | %-12s | %-12s | %-12s | %-12s\n', ...
                'Function', 'Best', 'Worst', 'Mean', 'Std Dev');
        fprintf('%s\n', repmat('-', 1, 80));
        
        for i = 1:n_funcs
            results = squeeze(all_results(d, i, :));
            % 優化：一次性計算所有統計量
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
    

    % 優化：使用向量化操作建立邊界
    lb = repmat(bound1x2(1), 1, dim);  % 下限值
    ub = repmat(bound1x2(2), 1, dim);  % 上限值

    % 初始化族群（在 [0,1]^D）
    X = rand(n_particles, dim);
    fitness = zeros(n_particles, 1);

    % 優化：初始 fitness 評估（保持迴圈以便未來可能的平行化）
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
    % 優化：預先計算氫原子機率分佈（只需計算一次）
    a0 = 1; 
    num_points = 10001;  % 直接使用點數

    % 原始 X 軸：物理距離 r (範圍 [0, 30])
    r_values_original = linspace(0, 30, num_points);

    % Y 軸：計算對應的機率密度 P(r)
    % 優化：預先計算常數項
    const_factor = 4 / (a0^3);
    P_r_values = const_factor * (r_values_original.^2) .* exp(-2 * r_values_original / a0);
    
    % 歸一化Y軸面積
    area = trapz(r_values_original, P_r_values);
    P_r_values_normalized = P_r_values / area;

    % 優化：預先計算常數
    exploration_threshold = (2/3) * max_iter;
    
    for t = 1:max_iter
        X_mean = mean(X, 1);
        G1 = 2*rand() - 1;
        G2 = 2*(1 - t/max_iter);
        
        % 優化：預先計算時間相關係數
        time_factor = 1 - t/max_iter;

        for p = 1:n_particles
            if t <= exploration_threshold
                if rand < 0.5
                    % Expanded exploration (1) - 氫原子 1s 徑向
                    % 使用平均值來當作要修改的範圍
                    Umin_x = mean(X_mean);  % 氫原子
                    Umax_x = mean(gBest);   % 電子

                    % 呼叫 rescale_axis_range 函數來調整 X 軸
                    r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);
                    generated_samples = inverse_transform_sampling(r_values_rescaled, P_r_values_normalized, dim);
                    X_new = gBest * time_factor + (X_mean + generated_samples);
                else
                    % Narrowed exploration (2) with Lévy
                    levy_val = levy_step(dim, u);
                    rand_idx = randi(n_particles);  % 優化：使用 randi 替代 floor+rand
                    X_rand = X(rand_idx, :);
                    X_new = gBest .* levy_val + X_rand + (rand - 0.5) * 1e-3;
                end
            else
                if rand < 0.5
                    % Expanded exploitation (3)
                    X_new = (gBest - X_mean) * alpha - rand + rand * delta;
                else
                    % Narrowed exploitation (4)
                    QF = t^((2*rand - 1)/(1 - max_iter)^2);
                    X_new = QF * gBest - (G1 * X(p, :) * rand) - G2 * levy_step(dim, u) + rand * G1;
                end
            end

            % 優化：邊界裁切（更高效的寫法）
            X_new = max(min(X_new, 1), 0);

            % 評估
            x_real = denorm01_to_bounds(X_new, lb, ub);
            func_output = func(x_real);
            fNew = SSE(func_output, 0);

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

    % AO 參數
    alpha = 0.1;            % exploitation 調整
    delta = 0.1;            % exploitation 調整
    u = 0.00565;            % Levy flight 參數

    % 優化：使用 repmat 建立邊界
    lb = repmat(bound1x2(1), 1, dim);
    ub = repmat(bound1x2(2), 1, dim);

    % 初始化族群（在 [0,1]^D）
    X = rand(n_particles, dim);
    fitness = zeros(n_particles, 1);

    % 初始評估
    for p = 1:n_particles
        x_real = denorm01_to_bounds(X(p, :), lb, ub);
        func_output = func(x_real);
        fitness(p) = SSE(func_output, 0);
    end

    [gBestVal, idx] = min(fitness);
    gBest = X(idx, :);
    bestX = denorm01_to_bounds(gBest, lb, ub);
    bestCost = gBestVal;

    best_cost_history = zeros(max_iter, 1);
    
    % 優化：預先計算常數
    exploration_threshold = (2/3) * max_iter;

    for t = 1:max_iter
        X_mean = mean(X, 1);
        G1 = 2*rand() - 1;
        G2 = 2 * (1 - t / max_iter);
        
        % 優化：預先計算時間相關係數
        time_factor = 1 - t/max_iter;

        for p = 1:n_particles
            if t <= exploration_threshold
                if rand < 0.5
                    % Expanded exploration (1)
                    X_new = gBest * time_factor + (X_mean - gBest * rand);
                else
                    % Narrowed exploration (2) with Lévy
                    levy_val = levy_step(dim, u);
                    rand_idx = randi(n_particles);  % 優化：使用 randi
                    X_rand = X(rand_idx, :);
                    X_new = gBest .* levy_val + X_rand + (rand - 0.5) * 1e-3;
                end
            else
                if rand < 0.5
                    % Expanded exploitation (3)
                    X_new = (gBest - X_mean) * alpha - rand + rand * delta;
                else
                    % Narrowed exploitation (4)
                    QF = t^((2*rand - 1)/(1 - max_iter)^2);
                    X_new = QF * gBest - (G1 * X(p, :) * rand) - G2 * levy_step(dim, u) + rand * G1;
                end
            end

            % 優化：邊界裁切
            X_new = max(min(X_new, 1), 0);

            % 評估
            x_real = denorm01_to_bounds(X_new, lb, ub);
            func_output = func(x_real);
            fNew = SSE(func_output, 0);

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

function samples = inverse_transform_sampling(x_values, pdf_values, num_samples)
%INVERSE_TRANSFORM_SAMPLING 從數值 PDF 生成隨機樣本
%   優化版本：減少不必要的轉置和複製操作

    % 1. 確保輸入為行向量並計算 CDF
    if size(x_values, 1) > 1
        x_values = x_values';
    end
    if size(pdf_values, 1) > 1
        pdf_values = pdf_values';
    end
    CDF_values = cumtrapz(x_values, pdf_values);

    % 2. 確保 CDF 範圍是 [0, 1] 
    CDF_values(1) = 0;
    CDF_values(end) = 1;
    
    % 3. 處理 CDF 中的平坦區域（使用 'last' 選項）
    [CDF_unique, ia] = unique(CDF_values, 'last');
    x_unique = x_values(ia);

    % 4. 生成 U(0, 1) 的均勻分佈隨機數並執行逆轉換
    u = rand(1, num_samples);
    samples = interp1(CDF_unique, x_unique, u, 'linear', 'extrap');
end

function U_x = rescale_axis_range(G_x, Umin_x, Umax_x)
%RESCALE_AXIS_RANGE 將輸入的 X 軸向量 G_x 線性映射到一個新的範圍 [Umin_x, Umax_x]
%
%   輸入:
%       G_x    - 原始的 X 軸數據向量
%       Umin_x - 目標範圍的最小值
%       Umax_x - 目標範圍的最大值
%   輸出:
%       U_x    - 調整到新範圍的 X 軸數據向量

    % 優化：使用 min/max 的單次調用
    Gmin_x = min(G_x);
    Gmax_x = max(G_x);
    
    % 檢查範圍以避免除以零
    if Gmax_x == Gmin_x
        U_x = repmat(Umin_x, size(G_x));  % 優化：使用 repmat
        warning('rescale_axis_range:constantInput', '輸入的 X 軸向量所有元素都相同。');
        return;
    end

    % 優化：一次性計算縮放係數
    scale_factor = (Umax_x - Umin_x) / (Gmax_x - Gmin_x);
    U_x = (G_x - Gmin_x) * scale_factor + Umin_x;
end

% ===================== 測試函數 (F1-F13) =====================

% --- F1 (Unimodal) ---
function y = sphere(x)
    % global optimum at x=0, f=0
    y = sum(x.^2);
end

% --- F2 (Unimodal) ---
function y = f2(x)
    y = sum(abs(x)) + prod(abs(x));
end

% --- F3 (Unimodal) ---
function y = f3(x)
    % 優化：向量化計算，避免迴圈
    d = numel(x);
    cumsum_x = cumsum(x);
    y = sum(cumsum_x.^2);
end

% --- F4 (Unimodal) ---
function y = f4(x)
    y = max(abs(x));
end

% --- F5 (Unimodal) ---
function y = rosenbrock(x)
    % global optimum at x=1, f=0 (Note: PDF fmin=0)
    y = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);
end

% --- F6 (Unimodal) ---
function y = f6(x)
    % PDF: sum([x_i + 0.5]^2) - [] seems to be floor or round
    y = sum((floor(x + 0.5)).^2);
end

% --- F7 (Unimodal) ---
function y = f7(x)
    d = numel(x);
    y = sum((1:d) .* (x.^4)) + rand;
end

% --- F8 (Multimodal) ---
function y = f8(x)
    y = sum(-x .* sin(sqrt(abs(x))));
end

% --- F9 (Multimodal) ---
function y = rastrigin(x)
    % global optimum at x=0, f=0
    A = 10;
    D = numel(x);
    y = A*D + sum(x.^2 - A*cos(2*pi*x));
end

% --- F10 (Multimodal) ---
function y = ackley(x)
    % global optimum at x=0, f=0
    a = 20; b = 0.2; c = 2*pi;
    D = numel(x);
    s1 = sum(x.^2);
    s2 = sum(cos(c*x));
    y = -a*exp(-b*sqrt(s1/D)) - exp(s2/D) + a + exp(1);
end

% --- F11 (Multimodal) ---
function y = griewank(x)
    % 優化：向量化計算
    % global optimum at x=0, f=0
    D = numel(x);
    sumTerm = sum(x.^2) / 4000;
    % 優化：使用 prod 函數替代迴圈
    prodTerm = prod(cos(x ./ sqrt(1:D)));
    y = sumTerm - prodTerm + 1;
end

% --- F12 (Multimodal) ---
% 根據 PDF Table 3 的公式實現 (Levy and Montalvo)
function y = f12(x)
    n = numel(x);
    y1 = 1 + (x + 1) / 4;
    
    % 優化：向量化計算
    term1 = 10 * sin(pi * y1(1));
    
    % 優化：向量化 term2
    if n > 1
        term2 = sum((y1(1:n-1) - 1).^2 .* (1 + 10 * sin(pi * y1(2:n)).^2));
    else
        term2 = 0;
    end
    
    term3 = (y1(n) - 1)^2;
    
    % 優化：向量化 u 函數計算
    u_sum = sum(arrayfun(@(xi) u_func(xi, 10, 100, 4), x));
    
    y = (pi/n) * (term1 + term2 + term3) + u_sum;
end

% --- F13 (Multimodal) ---
% 根據 PDF Table 3 的公式實現
function y = f13(x)
    n = numel(x);
    
    % 優化：向量化計算
    term1 = sin(3 * pi * x(1))^2;
    
    % 優化：向量化 sum_term
    if n > 1
        sum_term = sum((x(1:n-1) - 1).^2 .* (1 + sin(3 * pi * x(1:n-1) + 1).^2));
    else
        sum_term = 0;
    end
    
    term3 = (x(n) - 1)^2 * (1 + sin(2 * pi * x(n))^2);
    
    % 優化：向量化 u 函數計算
    u_sum = sum(arrayfun(@(xi) u_func(xi, 5, 100, 4), x));
    
    y = 0.1 * (term1 + sum_term + term3) + u_sum;
end


% ===================== F12/F13 輔助函數 =====================
function u = u_func(x, a, k, m)
    % 根據 PDF F12 的 $u(x_i, a, k, m)$ 定義
    if x > a
        u = k * (x - a)^m;
    elseif x < -a
        u = k * (-x - a)^m;
    else
        u = 0;
    end
end


% ===================== 損失函數 =====================
function sse = SSE(Y_output, Y_target)
    % SSE: Sum of Squared Errors
    % 優化：直接計算平方和，避免中間變數
    sse = sum((Y_output - Y_target).^2, 'all');
end