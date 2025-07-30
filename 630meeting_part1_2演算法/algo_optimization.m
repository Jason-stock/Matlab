%% PSO演算法
PSO_optimization();
function PSO_optimization
    % 參數設定
    dimList = [30,50,100]; % 設定input的維度
    max_iter = 2000; % 設定最大的迭代數
    n_particles = 50; % 設定粒子群的數量
    
    % 定義要尋找最佳解的方程式
    functions = {@sphere, @rastrigin, @rosenbrock, @ackley, @griewank};
    function_names = {'Sphere Function', 'Rastrigin Function', 'Rosenbrock Function', 'Ackley Function', 'Griewank Function'};
    bounds = [-5.12, 5.12; -5.12, 5.12; -5, 10; -32.768, 32.768; -600, 600]; % 搜尋範圍

    % Plot 3D surfaces for each function
    % for i = 1:length(functions)
    %     plot_function_3d(functions{i}, bounds(i, :), function_names{i});
    % end
    for d = 1:length(dimList)
        dim = dimList(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);

        for i = 1:length(functions)
        [bestCost , best_cost_history] = pso(functions{i}, dim, max_iter, n_particles, bounds(i, :));

        fprintf('Function: %-10s | Best Objective: %.16e\n', function_names{i}, bestCost);
        % Plot convergence
        figure;
        plot(1:max_iter, best_cost_history, 'LineWidth', 1.5);
        set(gca, 'YScale', 'log');
        xlabel('Iterations');
        ylabel('Best Solution');
        title(sprintf('Convergence Curve for %s (%d-D)', function_names{i}, dim));
        grid on;
        end

    end
        
end

% function plot_function_3d(func, bounds, func_name)
%     % Plot a 3D surface for a 2D projection of the given function
%     [X, Y] = meshgrid(linspace(bounds(1), bounds(2), 100), linspace(bounds(1), bounds(2), 100));
%     Z = arrayfun(@(x, y) func([x, y]), X, Y);
% 
%     figure;
%     surf(X, Y, Z, 'EdgeColor', 'none');
%     title(['3D Surface of ', func_name]);
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');
%     grid on;
% end

%% RO 演算法
function [bestCost, best_cost_history] = ro(func, dim, max_iter, n_particles, bounds)
    % 隨機優化演算法（RO）參數設定
    lb = bounds(1);
    ub = bounds(2);

    % 初始化粒子群
    positions = lb + (ub - lb) * rand(n_particles, dim);
    fitness = arrayfun(@(i) func(positions(i,:)), 1:n_particles)';
    [bestCost, bestIdx] = min(fitness);
    bestPosition = positions(bestIdx, :);
    best_cost_history = zeros(max_iter, 1);

    % 主迴圈
    for t = 1:max_iter
        for i = 1:n_particles
            % 在鄰近範圍內隨機產生新解
            perturbation = (ub - lb) * (rand(1, dim) - 0.5) * 0.1;  % 小幅變動
            candidate = positions(i, :) + perturbation;

            % 邊界限制
            candidate = max(min(candidate, ub), lb);

            candidateFitness = func(candidate);

            % 擇優保留
            if candidateFitness < fitness(i)
                positions(i, :) = candidate;
                fitness(i) = candidateFitness;

                if candidateFitness < bestCost
                    bestCost = candidateFitness;
                    bestPosition = candidate;
                end
            end
        end

        best_cost_history(t) = bestCost;
    end
end


%% AO 演算法
function [bestCost, best_cost_history] = ao(func, dim, max_iter, n_particles, bounds)
    % AO 演算法參數初始化
    lb = bounds(1);
    ub = bounds(2);

    % 初始化解群體
    positions = lb + (ub - lb) * rand(n_particles, dim);
    fitness = arrayfun(@(i) func(positions(i, :)), 1:n_particles)';
    [bestCost, bestIdx] = min(fitness);
    bestPosition = positions(bestIdx, :);
    best_cost_history = zeros(max_iter, 1);

    for t = 1:max_iter
        a = 5;         % 控制探索與開採的變數
        alpha = 0.1;   % 學習率（也可隨時間縮減）
        r1 = rand();   % 隨機值決定類型

        TF = (t / max_iter)^((1 - (t / max_iter)) * a);  % AO 核心轉換函數

        for i = 1:n_particles
            r2 = rand();
            if r1 > 0.5  % Exploration：加法或減法
                if r2 > 0.5
                    positions(i, :) = bestPosition / (TF + eps) + alpha * rand(1, dim) .* positions(i, :);
                else
                    positions(i, :) = bestPosition - TF * rand(1, dim) .* positions(i, :);
                end
            else         % Exploitation：乘法或除法
                if r2 > 0.5
                    positions(i, :) = bestPosition .* TF + alpha * rand(1, dim) .* bestPosition;
                else
                    positions(i, :) = bestPosition ./ (TF + eps) + alpha * rand(1, dim) .* bestPosition;
                end
            end
        end

        % 邊界限制
        positions = max(min(positions, ub), lb);

        % 更新適應值與最佳解
        fitness = arrayfun(@(i) func(positions(i,:)), 1:n_particles)';
        [currentBest, bestIdx] = min(fitness);
        if currentBest < bestCost
            bestCost = currentBest;
            bestPosition = positions(bestIdx, :);
        end
        best_cost_history(t) = bestCost;
    end
end


%% PSO演算法
function [bestCost,best_cost_history] = pso(func, dim, max_iter, n_particles, bounds)
    % PSO演算法的參數設定
    w = 0.7; % Inertia weight
    c1 = 1.5; % Cognitive component
    c2 = 1.5; % Social component
    
    % 初始化
    lb = bounds(1);  % 設定搜索範圍的上下限
    ub = bounds(2);
    positions = lb + (ub - lb) * rand(n_particles, dim);  % 隨機初始化粒子的位置，均勻分佈在搜索範圍內。
    velocities = zeros(n_particles, dim);  % 初始化粒子的速度為零矩陣
    personal_best_positions = positions;  % 初始化每個粒子的p-best
    personal_best_scores = zeros(n_particles, 1); % 初始化個體最佳分數
    for i = 1:n_particles
        personal_best_scores(i) = func(positions(i, :)); % 計算每個粒子的適應值(該粒子的目標函數)
    end
    [global_best_score, g_idx] = min(personal_best_scores);  % 全域最佳分數，初始為所有粒子最佳分數的最小值。
    global_best_position = personal_best_positions(g_idx, :); % g_idx：對應全域最佳分數的粒子索引。
                                                              % global_best_position：全域最佳位置。
                                                              
    best_cost_history = zeros(max_iter, 1);  % best_cost_history：初始化記錄每次迭代最佳解的歷史。
    
    % PSO主迴圈
    for iter = 1:max_iter
        % 更新速度以及位置
        for i = 1:n_particles
            r1 = rand(1, dim);
            r2 = rand(1, dim);
            velocities(i, :) = w * velocities(i, :) + ...
                c1 * r1 .* (personal_best_positions(i, :) - positions(i, :)) + ...
                c2 * r2 .* (global_best_position - positions(i, :));
            positions(i, :) = positions(i, :) + velocities(i, :);
            
            % 範圍限制
            positions(i, :) = max(min(positions(i, :), ub), lb);
        end
        
        % 計算每個粒子的計算每個粒子的分數
        scores = arrayfun(@(i) func(positions(i, :)), 1:n_particles)';
        % 更新每個粒子的分數
        for i = 1:n_particles
            if scores(i) < personal_best_scores(i)
                personal_best_scores(i) = scores(i);
                personal_best_positions(i, :) = positions(i, :);
            end
        end
        % 
        [current_best_score, g_idx] = min(personal_best_scores);
        if current_best_score < global_best_score
            global_best_score = current_best_score;
            global_best_position = personal_best_positions(g_idx, :);
        end
        
        % 將每次迭代最佳解記錄在best_cost_history
        best_cost_history(iter) = global_best_score;
    end
    bestCost = min(best_cost_history);
end
%% WOA演算法
function [bestCost, best_cost_history] = woa(func, dim, max_iter, n_particles, bounds)
    % WOA 演算法參數設定
    lb = bounds(1);
    ub = bounds(2);
    
    % 初始化群體
    positions = lb + (ub - lb) * rand(n_particles, dim);
    fitness = zeros(n_particles, 1);
    for i = 1:n_particles
        fitness(i) = func(positions(i, :));
    end
    [bestCost, bestIdx] = min(fitness);
    bestPosition = positions(bestIdx, :);
    
    best_cost_history = zeros(max_iter, 1);

    % 主迴圈
    for t = 1:max_iter
        a = 2 - t * (2 / max_iter);  % a從2遞減到0
        
        for i = 1:n_particles
            r1 = rand();
            r2 = rand();
            A = 2 * a * r1 - a;
            C = 2 * r2;
            p = rand();
            b = 1;
            l = -1 + 2 * rand();  % l in [-1,1]

            D = abs(C * bestPosition - positions(i, :));

            if p < 0.5
                if abs(A) >= 1
                    randIdx = randi(n_particles);
                    X_rand = positions(randIdx, :);
                    D_rand = abs(C * X_rand - positions(i, :));
                    newPos = X_rand - A * D_rand;
                else
                    newPos = bestPosition - A * D;
                end
            else
                newPos = D .* exp(b * l) .* cos(2 * pi * l) + bestPosition;
            end

            % 範圍限制
            newPos = max(min(newPos, ub), lb);
            newFitness = func(newPos);

            % 更新位置與最佳值
            if newFitness < fitness(i)
                positions(i, :) = newPos;
                fitness(i) = newFitness;
                if newFitness < bestCost
                    bestCost = newFitness;
                    bestPosition = newPos;
                end
            end
        end
        best_cost_history(t) = bestCost;
    end
end
%% DE演算法
function [bestCost, best_cost_history] = de(func, dim, max_iter, n_particles, bounds)
    % 差分演化參數
    F = 0.5;      % 差分權重
    CR = 0.9;     % 交叉機率

    % 初始化種群
    lb = bounds(1);
    ub = bounds(2);
    X = lb + (ub - lb) * rand(n_particles, dim);
    fitness = arrayfun(@(i) func(X(i,:)), 1:n_particles)';
    
    [bestCost, bestIdx] = min(fitness);
    bestPosition = X(bestIdx, :);
    best_cost_history = zeros(max_iter, 1);

    for t = 1:max_iter
        for i = 1:n_particles
            % 隨機選擇三個不等於 i 的個體
            idxs = randperm(n_particles);
            idxs(idxs == i) = [];
            r1 = idxs(1);
            r2 = idxs(2);
            r3 = idxs(3);

            % 變異
            V = X(r1,:) + F * (X(r2,:) - X(r3,:));

            % 邊界處理
            V = max(min(V, ub), lb);

            % 交叉
            jrand = randi(dim);
            U = X(i,:);
            for j = 1:dim
                if rand() <= CR || j == jrand
                    U(j) = V(j);
                end
            end

            % 評估與選擇
            trialFitness = func(U);
            if trialFitness < fitness(i)
                X(i,:) = U;
                fitness(i) = trialFitness;
            end
        end

        % 更新全域最佳
        [currentBest, idx] = min(fitness);
        if currentBest < bestCost
            bestCost = currentBest;
            bestPosition = X(idx,:);
        end
        best_cost_history(t) = bestCost;
    end
end



%% GWO演算法
function [bestCost, best_cost_history] = gwo(func, dim, max_iter, n_particles, bounds)
    lb = bounds(1);
    ub = bounds(2);
    
    % 初始化
    positions = lb + (ub - lb) * rand(n_particles, dim);
    fitness = arrayfun(@(i) func(positions(i,:)), 1:n_particles)';
    [~, sorted_idx] = sort(fitness);
    alpha = positions(sorted_idx(1), :);
    beta  = positions(sorted_idx(2), :);
    delta = positions(sorted_idx(3), :);
    bestCost = fitness(sorted_idx(1));
    best_cost_history = zeros(max_iter, 1);

    for t = 1:max_iter
        a = 2 - 2 * t / max_iter;
        for i = 1:n_particles
            for j = 1:dim
                r1 = rand(); r2 = rand();
                A1 = 2 * a * r1 - a;
                C1 = 2 * r2;
                D_alpha = abs(C1 * alpha(j) - positions(i,j));
                X1 = alpha(j) - A1 * D_alpha;

                r1 = rand(); r2 = rand();
                A2 = 2 * a * r1 - a;
                C2 = 2 * r2;
                D_beta = abs(C2 * beta(j) - positions(i,j));
                X2 = beta(j) - A2 * D_beta;

                r1 = rand(); r2 = rand();
                A3 = 2 * a * r1 - a;
                C3 = 2 * r2;
                D_delta = abs(C3 * delta(j) - positions(i,j));
                X3 = delta(j) - A3 * D_delta;

                positions(i,j) = (X1 + X2 + X3) / 3;
            end
        end

        % 邊界限制
        positions = max(min(positions, ub), lb);

        % 更新領導狼群
        fitness = arrayfun(@(i) func(positions(i,:)), 1:n_particles)';
        [~, sorted_idx] = sort(fitness);
        alpha = positions(sorted_idx(1), :);
        beta  = positions(sorted_idx(2), :);
        delta = positions(sorted_idx(3), :);
        bestCost = fitness(sorted_idx(1));
        best_cost_history(t)  = max(bestCost, 1e-15);
    end
end

%% 測試函數
function y = sphere(x)
    y = sum(x.^2);
end

function y = rastrigin(x)
    y = 10 * numel(x) + sum(x.^2 - 10 * cos(2 * pi * x));
end

function y = rosenbrock(x)
    y = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (x(1:end-1) - 1).^2);
end

function y = ackley(x)
    a = 20; b = 0.2; c = 2*pi; d = numel(x);
    y = -a * exp(-b * sqrt(sum(x.^2) / d)) ...
        - exp(sum(cos(c * x)) / d) + a + exp(1);
end

function y = griewank(x)
    i = 1:numel(x);
    y = sum(x.^2) / 4000 - prod(cos(x ./ sqrt(i))) + 1;
end
