function pso_convergence_plot()
    dims = [30, 50, 100];
    funcs = {@sphere, @rastrigin, @rosenbrock, @ackley, @griewank};
    names = {'Sphere', 'Rastrigin', 'Rosenbrock', 'Ackley', 'Griewank'};

    for d = 1:length(dims)
        dim = dims(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);
        figure('Name', sprintf('PSO Convergence (Dim = %d)', dim));
        hold on;

        for i = 1:length(funcs)
            [bestF, history] = pso(funcs{i}, dim, 50, 1000);
            fprintf('Function: %-10s | Best Objective: %.6f\n', names{i}, bestF);
            plot(history, 'DisplayName', names{i}, 'LineWidth', 1.5);
        end

        xlabel('Iteration');
        ylabel('Best Objective Value');
        title(sprintf('PSO Convergence Curves (Dimension = %d)', dim));
        legend show;
        grid on;
        hold off;
    end
end

function [bestF, history] = pso(fun, dim, swarmSize, maxIter)
    w = 0.7; c1 = 1.5; c2 = 1.5;
    lb = -5 * ones(1, dim);
    ub = 5 * ones(1, dim);

    X = rand(swarmSize, dim) .* (ub - lb) + lb;
    V = zeros(swarmSize, dim);
    pBest = X;
    pBestVal = arrayfun(fun, X);
    [gBestVal, gIdx] = min(pBestVal);
    gBest = X(gIdx, :);
    history = zeros(1, maxIter);

    for iter = 1:maxIter
    r1 = rand(swarmSize, dim);
    r2 = rand(swarmSize, dim);
    V = w * V + c1 * r1 .* (pBest - X) + c2 * r2 .* (repmat(gBest, swarmSize, 1) - X);
    X = X + V;

    % 邊界限制
    X = max(min(X, ub), lb);

    % 更新個體與全域最優
    fVals = arrayfun(fun, X);
    improved = fVals < pBestVal;
    pBest(improved, :) = X(improved, :);
    pBestVal(improved) = fVals(improved);

    [currentBest, idx] = min(pBestVal);
    if currentBest < gBestVal
        gBestVal = currentBest;
        gBest = X(idx, :);
    end

    history(iter) = gBestVal;
    end


    bestF = gBestVal;
end

pso_convergence_plot()
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


