function improvedRO_multidim_test()
    % 測試維度設定
    dimList = [30, 50, 100];
    maxIter = 2000;
    sigma = 0.5;

    % 測試函數與名稱
    funcs = {@sphere, @rastrigin, @rosenbrock, @ackley, @griewank};
    names = {'Sphere', 'Rastrigin', 'Rosenbrock', 'Ackley', 'Griewank'};

    for d = 1:length(dimList)
        dim = dimList(d);
        fprintf('\n===== Testing Dimension: %d =====\n', dim);
        for i = 1:length(funcs)
            [~, bestF, history] = improvedRO(funcs{i}, dim, maxIter, sigma);
            fprintf('Function: %-10s | Best Objective: %.6f\n', names{i}, bestF);

            figure;
            plot(1:maxIter, history, 'LineWidth', 1.5);
            xlabel('Iteration');
            ylabel('Best Objective Value');
            title(sprintf('Convergence Curve of Improved RO on %s Dim - %d -dim',names{i},dim));
            grid on;
        end
        
    end

    
end

function [bestX, bestF, history] = improvedRO(fun, n, maxIter, sigma)
    x = randn(1, n);           
    b = zeros(1, n);           
    fx = fun(x);               
    bestX = x;
    bestF = fx;
    history = zeros(1, maxIter);  % 收斂曲線記錄

    for iter = 1:maxIter
        dx = sigma * randn(1, n);       
        xNew = x + b + dx;
        fNew = fun(xNew);

        if fNew < fx
            x = xNew;
            fx = fNew;
            b = 0.2 * b + 0.4 * dx;
        else
            xRev = x + b - dx;
            fRev = fun(xRev);

            if fRev < fx
                x = xRev;
                fx = fRev;
                b = b - 0.4 * dx;
            else
                b = 0.5 * b;
            end
        end

        if fx < bestF
            bestF = fx;
            bestX = x;
        end

        history(iter) = bestF;  % 記錄當前最優值
    end
end




%% 測試函數定義
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
    a = 20; b = 0.2; c = 2*pi;
    d = numel(x);
    sum1 = sum(x.^2);
    sum2 = sum(cos(c * x));
    y = -a * exp(-b * sqrt(sum1 / d)) - exp(sum2 / d) + a + exp(1);
end

function y = griewank(x)
    sum1 = sum(x.^2) / 4000;
    prod1 = prod(cos(x ./ sqrt(1:numel(x))));
    y = sum1 - prod1 + 1;
end

improvedRO_multidim_test()
