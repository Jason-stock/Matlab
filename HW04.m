% Q1-1 - 將測試函數視覺化

% Rosenbrock function
x1 = linspace(-5, 10, 1000);
x2 = linspace(-5, 10, 1000);
[X1, X2] = meshgrid(x1, x2);
f1 = 100 * (X2 - X1.^2).^2 + (X1 - 1).^2;

% 繪製3-D圖
figure;
surf(X1, X2, f1,'EdgeColor', 'none');
title('Rosenbrock Function - 3D Surface');
xlabel('x1'); ylabel('x2'); zlabel('f(x)');

% 繪製等高線圖
figure;
contour3(X1, X2, f1, 50);
title('Rosenbrock Function - Contour Plot');
xlabel('x1'); ylabel('x2');

% Rastrigin function
x1 = linspace(-5.12, 5.12, 1000);
x2 = linspace(-5.12, 5.12, 1000);
[X1, X2] = meshgrid(x1, x2);
f2 = 10 * 2 + (X1.^2 - 10 * cos(2 * pi * X1)) + (X2.^2 - 10 * cos(2 * pi * X2));

% 繪製3-D圖
figure;
surf(X1, X2, f2,'EdgeColor', 'none');
title('Rastrigin Function - 3D Surface');
xlabel('x1'); ylabel('x2'); zlabel('f(x)');

% 繪製等高線圖
figure;
contour3(X1, X2, f2, 50);
title('Rastrigin Function - Contour Plot');
xlabel('x1'); ylabel('x2');

%%
% Q1-2: WOA for optimizing Rosenbrock and Rastrigin functions
clc; clear; close all;

% Parameters
D = 2; % Dimensions
nT = 100; % Number of iterations
swarm_size = 30; % Swarm size
rosen_range = [-5, 10];
rastr_range = [-5.12, 5.12];
initial_rosen = [-4.91, 9.91];
initial_rastr = [-4.95, 4.95];

% Test Functions
rosenbrock = @(x) sum(100 * (x(2:end) - x(1:end-1).^2).^2 + (x(1:end-1) - 1).^2);
rastrigin = @(x) 10 * D + sum(x.^2 - 10 * cos(2 * pi * x));

% Initialize Swarm
X_rosen = rosen_range(1) + (rosen_range(2) - rosen_range(1)) * rand(swarm_size, D);
X_rastr = rastr_range(1) + (rastr_range(2) - rastr_range(1)) * rand(swarm_size, D);
X_rosen(1, :) = initial_rosen; % Set initial position
X_rastr(1, :) = initial_rastr; % Set initial position

% Trackers
best_f_rosen = zeros(nT, 1);
best_f_rastr = zeros(nT, 1);
path_rosen = zeros(nT, D); % Track the leader's path
path_rastr = zeros(nT, D);

% WOA Algorithm
for iter = 1:nT
    % Rosenbrock
    fitness_rosen = arrayfun(@(i) rosenbrock(X_rosen(i, :)), 1:swarm_size);
    [best_f_rosen(iter), idx_rosen] = min(fitness_rosen);
    leader_rosen = X_rosen(idx_rosen, :);
    path_rosen(iter, :) = leader_rosen; % Track path
    X_rosen = update_swarm(X_rosen, leader_rosen, iter, nT, rosen_range);

    % Rastrigin
    fitness_rastr = arrayfun(@(i) rastrigin(X_rastr(i, :)), 1:swarm_size);
    [best_f_rastr(iter), idx_rastr] = min(fitness_rastr);
    leader_rastr = X_rastr(idx_rastr, :);
    path_rastr(iter, :) = leader_rastr; % Track path
    X_rastr = update_swarm(X_rastr, leader_rastr, iter, nT, rastr_range);
end

% Results Table: Rosenbrock
rosen_indices = [1:5, nT-4:nT]; % Indices for the first 5 and last 5 iterations
rosen_results = path_rosen(rosen_indices, :); % Select corresponding rows
rosen_row_names = strcat('Iter', string([1:5, nT-4:nT])); % Generate row names

disp('Final Results: Rosenbrock');
disp(array2table(rosen_results, ...
    'VariableNames', {'x1', 'x2'}, 'RowNames', rosen_row_names));
disp(['Best Result',num2str(best_f_rosen(nT))]);

% Results Table: Rastrigin
rastr_indices = [1:5, nT-4:nT]; % Indices for the first 5 and last 5 iterations
rastr_results = path_rastr(rastr_indices, :); % Select corresponding rows
rastr_row_names = strcat('Iter', string([1:5, nT-4:nT])); % Generate row names

disp('Final Results: Rastrigin');
disp(array2table(rastr_results, ...
    'VariableNames', {'x1', 'x2'}, 'RowNames', rastr_row_names));
disp(['Best Result:',num2str(best_f_rastr(nT))]);

% Plot Learning Curves
figure;
plot(1:nT, best_f_rosen, '-o', 'LineWidth', 1.5);
title('Learning Curve - Rosenbrock');
xlabel('Iterations'); ylabel('Best Fitness Value');

figure;
plot(1:nT, best_f_rastr, '-o', 'LineWidth', 1.5);
title('Learning Curve - Rastrigin');
xlabel('Iterations'); ylabel('Best Fitness Value');


% Rosenbrock: 3D Contour with Search Path
figure;
[x1, x2] = meshgrid(linspace(rosen_range(1), rosen_range(2), 100));
f_rosen = 100 * (x2 - x1.^2).^2 + (x1 - 1).^2;
contour3(x1, x2, f_rosen, 50); hold on;

% Calculate z values for search path
z_rosen = arrayfun(@(i) rosenbrock(path_rosen(i, :)), 1:size(path_rosen, 1));
plot3(path_rosen(:, 1), path_rosen(:, 2), z_rosen, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);

title('Search Path - Rosenbrock');
xlabel('x1'); ylabel('x2'); zlabel('f(x)');
grid on;

% Rastrigin: 3D Contour with Search Path
figure;
[x1, x2] = meshgrid(linspace(rastr_range(1), rastr_range(2), 100));
f_rastr = 10 * D + (x1.^2 - 10 * cos(2 * pi * x1)) + (x2.^2 - 10 * cos(2 * pi * x2));
contour3(x1, x2, f_rastr, 50); hold on;

% Calculate z values for search path
z_rastr = arrayfun(@(i) rastrigin(path_rastr(i, :)), 1:size(path_rastr, 1));
plot3(path_rastr(:, 1), path_rastr(:, 2), z_rastr, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);

title('Search Path - Rastrigin');
xlabel('x1'); ylabel('x2'); zlabel('f(x)');
grid on;


% Subfunction: Update Swarm
function swarm = update_swarm(swarm, leader, iter, nT, bounds)
    a = 2 - iter * (2 / nT); % Decreasing parameter
    for i = 1:size(swarm, 1)
        r = rand(1, size(swarm, 2));
        A = 2 * a * r - a;
        C = 2 * r;
        p = rand();
        if p < 0.5
            D = abs(C .* leader - swarm(i, :));
            swarm(i, :) = leader - A .* D;
        else
            rand_pos = bounds(1) + (bounds(2) - bounds(1)) * rand(1, size(swarm, 2));
            D = abs(C .* rand_pos - swarm(i, :));
            swarm(i, :) = rand_pos - A .* D;
        end
        % Enforce boundaries
        swarm(i, :) = max(bounds(1), min(bounds(2), swarm(i, :)));
    end
end



%%
% Q2: Least Squares Method for Regression
clc; clear; close all;

% Data for linear regression
x_linear = [60, 70, 80, 90, 100];
y_linear = [14, 16, 19, 20, 21];

% Linear Regression
A = [x_linear', ones(size(x_linear'))];
coeffs_linear = (A' * A) \ (A' * y_linear');
a_linear = coeffs_linear(1); % Slope
b_linear = coeffs_linear(2); % Intercept

% Plot Linear Fit
figure;
scatter(x_linear, y_linear, 'filled');
hold on;
x_fit_linear = linspace(min(x_linear), max(x_linear), 100);
y_fit_linear = a_linear * x_fit_linear + b_linear;
plot(x_fit_linear, y_fit_linear, 'r', 'LineWidth', 1.5);
title('Linear Fit');
xlabel('x'); ylabel('y');
legend('Data Points', 'Fitted Line');

% Data for quadratic regression
x_curve = [0, 25, 50, 75, 100];
y_curve = [-12.4, 5, 33.2, 72.8, 134];

% Quadratic Regression
X_curve = [x_curve'.^2, x_curve', ones(size(x_curve'))];
coeffs_curve = (X_curve' * X_curve) \ (X_curve' * y_curve');
a_curve = coeffs_curve(1);
b_curve = coeffs_curve(2);
c_curve = coeffs_curve(3);

% Plot Quadratic Fit
figure;
scatter(x_curve, y_curve, 'filled');
hold on;
x_fit_curve = linspace(min(x_curve), max(x_curve), 100);
y_fit_curve = a_curve * x_fit_curve.^2 + b_curve * x_fit_curve + c_curve;
plot(x_fit_curve, y_fit_curve, 'r', 'LineWidth', 1.5);
title('Quadratic Fit');
xlabel('x'); ylabel('y');
legend('Data Points', 'Fitted Curve');
