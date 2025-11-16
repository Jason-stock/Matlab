QAO_optimization()
function QAO_optimization
    % QAO_optimization
    % 針對 13 個古典測試函數（F1-F13）
    % 在 dimList 維度下執行。
    % [修改] 將每個維度(30D, 50D, 100D)的所有函數(F1-F13)繪製在同一張圖上。

    % ===== 參數設定 =====
    dimList    = [30, 50, 100];   % 測試維度
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
    
    % 初始化統計結果儲存
    all_results = zeros(length(dimList), length(functions), n_runs);
    all_convergence = zeros(length(dimList), length(functions), n_runs, max_iter);

    for d = 1:length(dimList)
        dim = dimList(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);

        % [修改] 儲存此維度下所有函數的最佳收斂曲線
        all_best_curves_for_dim = zeros(length(functions), max_iter);
        
        % [修改] 在函數迴圈開始前，為此維度建立一個新圖形
        figure('Color','w','Name',sprintf('All Functions (%d-D) - Best Run Convergence', dim));
        hold on;
        set(gca, 'YScale', 'log');
        title(sprintf('Convergence Curves (%d-D) - Best of %d Runs', dim, n_runs), 'FontSize', 14);
        xlabel('Iterations', 'FontSize', 12);
        ylabel('Best Objective (log scale)', 'FontSize', 12);
        grid on;

        for i = 1:length(functions)
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
        
        for i = 1:length(functions)
            % 循環使用顏色和線型
            color_idx = mod(i-1, size(colors, 1)) + 1;
            style_idx = mod(floor((i-1) / size(colors, 1)), length(lineStyles)) + 1;
            
            plot(iterations, max(all_best_curves_for_dim(i, :), eps), ...
                'DisplayName', function_names{i}, ... % 用於圖例
                'LineWidth', 2, ...
                'Color', colors(color_idx, :), ...
                'LineStyle', lineStyles{style_idx});
        end
        
        legend('show', 'Interpreter', 'none', 'Location', 'northeastoutside');
        hold off;
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
                    % 使用平均值來當作要修改的範圍
                    Umin_x = mean(X_mean);  % 氫原子
                    Umax_x = mean(gBest);  % 電子

                    % 呼叫 rescale_axis_range 函數來調整 X 軸，傳入固定的來源範圍
                    r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);
                    generated_samples = inverse_transform_sampling(r_values_rescaled, P_r_values_normalized, dim);
                    X_new = gBest .* (1 - t/max_iter) + generated_samples;
                else
                    % Narrowed exploration (2) - 氫原子 1s 徑向分佈（原點-電子模型）
                    % 原點當作質子，X_random 當作電子
                    rand_idx = floor(n_particles * rand) + 1;
                    X_rand = X(rand_idx, :);  % 隨機個體作為電子位置
                    
                    origin = zeros(1,dim);
                    Umin_x = mean(origin);
                    Umax_x = mean(X_rand);

                    r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);
                    generated_samples = inverse_transform_sampling(r_values_rescaled, P_r_values_normalized, dim);

                    r1 = 1 + (20-1)*rand;     % r1 ∈ [1,20]
                    D1 = 1:dim;
                    r = r1 + u * D1;
                    theta = -w * D1 + theta1;
    

                    y = r .* cos(theta);
                    x = r .* sin(theta);

                    spiral = (y - x) .* rand(1, dim);
                    
                    % 新位置 = 質子位置 + 氫原子機率分佈距離 * 方向
                    X_new = gBest.*levy_step(dim, u) + X_rand + generated_samples + spiral;
                end
            else
                if rand < 0.5
                    % Expanded exploitation (3)
                    Umin_x = mean(gBest);  % 氫原子
                    Umax_x = mean(X_mean);  % 電子

                    % 呼叫 rescale_axis_range 函數來調整 X 軸，傳入固定的來源範圍
                    r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);
                    generated_samples = inverse_transform_sampling(r_values_rescaled, P_r_values_normalized, dim);


                    X_new = (gBest - generated_samples)*alpha - rand + ((ub - lb) * rand)*delta;
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

function samples = inverse_transform_sampling(x_values, pdf_values, num_samples)
%INVERSE_TRANSFORM_SAMPLING 從數值 PDF 生成隨機樣本

    % 1. 計算數值 CDF (累積分佈函數)
    x_values = x_values(:)';
    pdf_values = pdf_values(:)';
    CDF_values = cumtrapz(x_values, pdf_values);

    % 2. 確保 CDF 範圍是 [0, 1] 
    CDF_values(1) = 0;
    CDF_values(end) = 1;
    
    % 3. 處理 CDF 中的平坦區域 (重複值)
    [CDF_unique, ia] = unique(CDF_values, 'last');
    x_unique = x_values(ia);

    % 4. 生成 U(0, 1) 的均勻分佈隨機數
    u = rand(num_samples, 1);

    % 5. 執行逆轉換：使用 "乾淨" 且 "唯一" 的 CDF 和 X 值進行插值
    samples = interp1(CDF_unique, x_unique, u);
    samples = samples(:)'; 
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
    y = 0;
    d = numel(x);
    for i = 1:d
        y = y + (sum(x(1:i)))^2;
    end
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
    % global optimum at x=0, f=0
    D = numel(x);
    sumTerm = sum(x.^2)/4000;
    prodTerm = 1;
    for i = 1:D
        prodTerm = prodTerm * cos(x(i)/sqrt(i));
    end
    y = sumTerm - prodTerm + 1;
end

% --- F12 (Multimodal) ---
% 根據 PDF Table 3 的公式實現
function y = f12(x)
    n = numel(x);
    y1 = 1 + (x + 1)/4;
    
    term1 = 10 * sin(pi * y1(1));
    
    term2_sum = 0;
    for i = 1:(n-1)
        term2_sum = term2_sum + (y1(i)-1)^2 * (1 + 10 * sin(pi * y1(i+1))^2);
    end
    
    % PDF F12的公式似乎不完整，但標準F12定義包含y_n項
    term3 = (y1(n)-1)^2 * (1 + 10 * sin(pi * y1(n))^2); % 修正：使用y_n和y_n
    
    u_sum = 0;
    for i = 1:n
        u_sum = u_sum + u_func(x(i), 10, 100, 4);
    end
    
    % 修正：標準定義中 term3 不乘以 10*sin...
    term3_std = (y1(n)-1)^2;
    
    % 採用PDF Table 3 的結構
    % f(x)=\frac{\pi}{n}(10sin(\pi y_{1}))+\sum_{i=1}^{n-1}(y_{i}-1)^{2}[1+10sin^{2}(\pi y_{i+1}) + ...
    % PDF公式 F12 似乎在表格中被截斷且有誤。
    % 這裡我們採用一個常見的 F12 (Levy and Montalvo) 實現，它匹配PDF的 y_i 和 u 函數
    
    term1_f12 = sin(pi * y1(1))^2;
    term2_f12 = sum((y1(1:n-1) - 1).^2 .* (1 + 10 * sin(pi * y1(2:n)).^2));
    term3_f12 = (y1(n) - 1)^2 * (1 + sin(2 * pi * y1(n))^2); % PDF F13有類似項
    
    % 重新採用 F12 PDF Table 3 的公式
    term1_pdf = 10 * sin(pi * y1(1));
    term2_pdf = 0;
    for i=1:(n-1)
        term2_pdf = term2_pdf + (y1(i)-1)^2 * (1 + 10*sin(pi*y1(i+1))^2);
    end
    % PDF F12的描述 $u(x_i, 10, 100, 4)$
    u_sum_pdf = 0;
    for i = 1:n
        u_sum_pdf = u_sum_pdf + u_func(x(i), 10, 100, 4);
    end
    
    % PDF F12第二行似乎是 $y_n$ 項，但格式混亂
    % $ (y_n-1)^2 [1 + 10\sin^2(\pi y_{n+1})] $ -> $y_{n+1}$ 超界
    % 假設它是 $(y_n-1)^2$
    term3_pdf = (y1(n)-1)^2;
    
    y = (pi/n) * (term1_pdf + term2_pdf + term3_pdf) + u_sum_pdf;
end

% --- F13 (Multimodal) ---
% 根據 PDF Table 3 的公式實現
function y = f13(x)
    n = numel(x);
    
    % PDF: $sin^{2}(3xx_{1})$ -> 假設 $3\pi x_1$
    term1 = sin(3 * pi * x(1))^2;
    
    sum_term = 0;
    % PDF: $\sum_{l=1}^{n}(x_{l}-1)^{2}[1+sin^{2}(3xx_{l}+1)]$
    % 這與下一項 $ (x_n-1)^2 ... $ 重複了
    % 假設 $\sum_{l=1}^{n-1}$
    for i = 1:(n-1)
        % PDF: $sin^{2}(3xx_{l}+1)$ -> 假設 $3\pi x_i + 1$
        sum_term = sum_term + (x(i)-1)^2 * (1 + sin(3 * pi * x(i) + 1)^2);
    end
    
    % PDF: $(x_{n}-1)^{2}1+sin^{2}(2xx_{n})$ -> 假設 $(x_n-1)^2 * (1 + sin(2\pi x_n)^2)$
    term3 = (x(n)-1)^2 * (1 + sin(2 * pi * x(n))^2);
    
    % PDF: $\sum_{l=1}^{n}u(x_{l}.5,100,4)$ -> 假設 $u(x_i, 5, 100, 4)$
    u_sum = 0;
    for i = 1:n
        u_sum = u_sum + u_func(x(i), 5, 100, 4);
    end
    
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
function [sse] = SSE(Y_output, Y_target)
    % SSE: Sum of Squared Errors
    % Y_output, Y_target 大小為 N x D
    div = Y_output - Y_target;

    % 把所有樣本、所有維度的誤差平方加總
    sse = sum(div(:).^2);
end