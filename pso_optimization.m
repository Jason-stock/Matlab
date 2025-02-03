%% PSO演算法
PSO_optimization();
function PSO_optimization
    % 參數設定
    dim = 50; % 設定input的維度
    max_iter = 300; % 設定最大的迭代數
    n_particles = 50; % 設定粒子群的數量
    
    % 定義要尋找最佳解的方程式
    functions = {@rastrigin, @griewank, @dixon_price};
    function_names = {'Rastrigin Function', 'Griewank Function', 'Dixon-Price Function'};
    bounds = [-5.12, 5.12; -600, 600; -10, 10]; % 搜尋範圍

    % Plot 3D surfaces for each function
    for i = 1:length(functions)
        plot_function_3d(functions{i}, bounds(i, :), function_names{i});
    end
    
    for i = 1:length(functions)
        fprintf('Optimizing %s...\n', function_names{i});
        [best_cost_history] = pso(functions{i}, dim, max_iter, n_particles, bounds(i, :));
        % Plot convergence
        figure;
        plot(1:max_iter, best_cost_history, 'LineWidth', 1.5);
        xlabel('Iterations');
        ylabel('Best Solution');
        title(['Convergence Curve - ', function_names{i}]);
        grid on;
    end
        
end

function plot_function_3d(func, bounds, func_name)
    % Plot a 3D surface for a 2D projection of the given function
    [X, Y] = meshgrid(linspace(bounds(1), bounds(2), 100), linspace(bounds(1), bounds(2), 100));
    Z = arrayfun(@(x, y) func([x, y]), X, Y);
    
    figure;
    surf(X, Y, Z, 'EdgeColor', 'none');
    title(['3D Surface of ', func_name]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on;
end

function [best_cost_history] = pso(func, dim, max_iter, n_particles, bounds)
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
end

function val = rastrigin(x)  % cost function 1
    val = 10 * numel(x) + sum(x.^2 - 10 * cos(2 * pi * x));
end

function val = griewank(x)  % cost function 2
    val = sum(x.^2) / 4000 - prod(cos(x ./ sqrt(1:numel(x)))) + 1;
end

function val = dixon_price(x)  % cost function 3
    val = (x(1) - 1)^2 + sum((2:numel(x)) .* (2 * x(2:end).^2 - x(1:end-1)).^2);
end
