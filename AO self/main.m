clc;
clear;
close all;

% 設定 AO 參數
N = 50;        % 族群大小
T = 1000;       % 最大迭代次數
Dim = 30;      % 變數維度

num_functions = 13;

% 儲存所有測試函數的收斂曲線
convergence_curves = zeros(T, num_functions);
final_fitness_values = zeros(1, num_functions); % 儲存最終適應值

% 執行 AO 演算法
for func_id = 1:num_functions
    fprintf('Running AO on Function F%d ...\n', func_id);
    
    [LB,UB,Dim,F_obj] = Get_F("F"+num2str(func_id));
    % 執行 AO
    [Best_FF, Best_P, conv] = AO(N, T, LB, UB, Dim, F_obj);
    
    % 儲存收斂曲線
    convergence_curves(:, func_id) = conv;
    final_fitness_values(func_id) = conv(end); % 最終適應值
end

% 繪製收斂曲線
figure;
hold on;
colors = lines(num_functions); % 使用 'lines' 來確保不同顏色
x_vals = 1:T;

for i = 1:num_functions
    plot(x_vals, convergence_curves(:, i), 'Color', colors(i,:), 'LineWidth', 2);
    
    % 在曲線終點標記函數名稱
    text(T, convergence_curves(end, i), sprintf('F%d', i), 'FontSize', 10, ...
        'Color', colors(i,:), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

hold off;
xlabel('Iterations');
ylabel('Fitness Value');
title('Comparison of AO Learning Curves on 13 Benchmark Functions');
legend(arrayfun(@(x) sprintf('F%d', x), 1:num_functions, 'UniformOutput', false), 'Location', 'northeast');
set(gca,"YScale","log");
grid on;

% 印出每個測試函數的最終適應值
fprintf('\nFinal Fitness Values:\n');
for i = 1:num_functions
    fprintf('F%d: %e\n', i, final_fitness_values(i));
end



