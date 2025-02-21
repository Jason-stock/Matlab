clc;
clear;
close all;

% 設定 AO 參數
N = 50;        % 族群大小
T = 1000;       % 最大迭代次數
Dim = 100;      % 變數維度
runtimes = 30;
num_functions = 13;


every_time_best = zeros(runtimes,num_functions);

% 執行 AO 演算法
for i = 1:runtimes
    % 儲存所有測試函數的收斂曲線
    convergence_curves = zeros(T, num_functions);
    final_fitness_values = zeros(1, num_functions); % 儲存最終適應值

    for func_id = 1:num_functions
        fprintf('Running AO on Function F%d ...\n', func_id);
    
        [LB,UB,F_obj] = Get_F("F"+num2str(func_id));
        % 執行 AO
        [Best_FF, Best_P, conv] = AO(N, T, LB, UB, Dim, F_obj);
    
        % 儲存收斂曲線
        convergence_curves(:, func_id) = conv;
        final_fitness_values(func_id) = conv(end); % 最終適應值
    end

    % 繪製收斂曲線
    % figure;
    % hold on;
    % colors = lines(num_functions); % 使用 'lines' 來確保不同顏色
    % x_vals = 1:T;

    % for i = 1:num_functions
    %     plot(x_vals, convergence_curves(:, i), 'Color', colors(i,:), 'LineWidth', 2);
    % 
    %     % 在曲線終點標記函數名稱
    %     text(T, convergence_curves(end, i), sprintf('F%d', i), 'FontSize', 10, ...
    %         'Color', colors(i,:), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    % end
    % 
    % hold off;
    % xlabel('Iterations');
    % ylabel('Fitness Value');
    % title('Comparison of AO Learning Curves on 13 Benchmark Functions');
    % legend(arrayfun(@(x) sprintf('F%d', x), 1:num_functions, 'UniformOutput', false), 'Location', 'northeast');
    % set(gca,"YScale","log");
    % grid on;

    % 印出每個測試函數的最終適應值
    fprintf('\nFinal Fitness Values:\n');
    for j = 1:num_functions
        fprintf('F%d: %e\n', j, final_fitness_values(j));
    end
    every_time_best(i,:) = final_fitness_values;

   
end

mean_value = mean(every_time_best);   % 每列的平均值
std_value = std(every_time_best);     % 每列的標準差
min_value = min(every_time_best);     % 每列的最小值
max_value = max(every_time_best);     % 每列的最大值

fprintf('平均值: %f\n', mean_value);
fprintf('標準差: %f\n', std_value);
fprintf('最小值: %f\n', min_value);
fprintf('最大值: %f\n', max_value);