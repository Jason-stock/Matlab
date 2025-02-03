% 設定參數
num_iterations = 100; % 總迭代次數
num_samples = 10; % 每次迭代生成的隨機樣本數
x_center = 50; % 初始中心值

% 儲存每次迭代的最小值
min_y_values = zeros(num_iterations, 1);
min_x_values = zeros(num_iterations, 1);

for iter = 1:num_iterations
    stdx = 100/iter;
    if stdx < 0.1
        stdx = 0.1;
    else
        % do nothing
    end
    % 在 [-1, 1] 區間內生成隨機 x 值，並以 x_center 為中心
    % x_samples = x_center + rand(num_samples, 1) * 2 - 1; % 隨機生成範圍 [-1, 1]
    x_temp = x_center + randn(1 , num_samples) * stdx;
    x_samples = [x_center x_temp];

    % 計算對應的 y 值
    y_samples = func(x_samples);
    
    % 找到最小值及其對應的 x 值
    [min_y, min_index] = min(y_samples);
    min_x = x_samples(min_index);
    
    % 儲存最小值
    min_y_values(iter) = min_y;
    min_x_values(iter) = min_x;
    % 更新中心值為當前找到的最小 x 值
    x_center = min_x;
    
    % 顯示當前迭代結果
    fprintf('Iteration %d: Min y = %.4f at x = %.4f\n', iter, min_y, min_x);
end

% 繪製函式圖形及最小值點
figure; % 創建新圖形窗口

% 定義函式範圍以繪製平滑曲線
x_plot = linspace(-50, 50, 400); % 
y_plot = x_plot.^2 + 10; % 計算對應的 y 值

% 繪製函式圖形
plot(x_plot, y_plot, 'b-', 'LineWidth', 2); % 繪製藍色實線
hold on; % 保持當前圖形

% 繪製每次迭代找到的最小值點
scatter(min_x_values, min_y_values, 'ro', 'filled'); % 用紅色圓圈標記最小值點

% 添加標籤和標題
xlabel('X 軸'); % 標記 x 軸
ylabel('Y 軸'); % 標記 y 軸
title('函式 y = x^2 + 10 與每次尋找到的最小值'); % 添加標題
legend('y = x^2 + 10', 'Min Values'); % 添加圖例

hold off; % 停止保持當前圖形

% 最終結果
fprintf('Final minimum value after %d iterations: %.4f\n', num_iterations, min(min_y_values));

%%
% 設定參數
num_iterations = 1000; % 總迭代次數
num_samples = 9; % 每次迭代生成的隨機樣本數
dim = 30; % 維度
x_center = 50 * ones(1, dim); % 初始中心值 (N維向量)

% 儲存每次迭代的最小值
min_y_values = zeros(num_iterations, 1);
min_x_values = zeros(num_iterations, dim);

for iter = 1:num_iterations
    stdx = 100 / iter;
    if stdx < 0.1
        stdx = 0.1;
    end
    
    % 在10維空間中生成隨機 x 值，並以 x_center 為中心
    x_temp = x_center + randn(num_samples, dim) * stdx;
    x_samples = [x_center; x_temp];
    
    %宣告一個y_samples存入每次迭代的y值
    y_samples = zeros(num_samples+1,1);

    % 計算對應的 y 值，並存入y_samples中
    for i = 1:num_samples+1
        y_samples(i) = func(x_samples(i,:));
    end
    % 找到最小值及其對應的 x 值
    [min_y, min_index] = min(y_samples);
    min_x = x_samples(min_index, :);
    
    % 儲存最小值
    min_y_values(iter) = min_y;
    min_x_values(iter, :) = min_x;
    
    % 更新中心值為當前找到的最小 x 值
    x_center = min_x;
    % 顯示當前迭代結果
    fprintf('Iteration %d: Min y = %.4f at x = [%s]\n', iter, min_y, num2str(min_x));
end

% 繪製每次迭代找到的最小值
figure; % 創建新圖形窗口

% 繪製每次迭代找到的最小值進程
plot(1:num_iterations, min_y_values, 'b-', 'LineWidth', 2); % 繪製藍色實線
hold on; % 保持當前圖形
scatter(1:num_iterations, min_y_values, 'ro', 'filled'); % 用紅色圓圈標記最小值點

% 添加標籤和標題
xlabel('Iteration'); % 標記 x 軸為迭代次數
ylabel('Minimum Y'); % 標記 y 軸
title('每次迭代找到的最小值'); % 添加標題
legend('Min Values Progress'); % 添加圖例

hold off; % 停止保持當前圖形

% 最終結果
fprintf('Final minimum value after %d iterations: %.4f\n', num_iterations, min(min_y_values));

function y = func(x)
    % 計算每個樣本的內積和 (10維向量的平方和) 加上10
    y = x*x' + 10;
end

%%





