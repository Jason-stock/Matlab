% 隨機生成 100 x 2 的 dataset
data = rand(100, 2);

% 設定參數
ra = 0.5;  % 決定密度影響範圍的參數
rb = 1.5 * ra;  % 決定密度降低的範圍
eps = 0.1;  % 收斂條件，密度閾值

% 計算每個點的初始資料密度
num_points = size(data, 1);
density = zeros(num_points, 1);
for i = 1:num_points
    diff = data - data(i, :);
    dist_sq = sum(diff.^2, 2);
    density(i) = sum(exp(-dist_sq / ((ra/2)^2)));
end

% 開始減法群聚
cluster_centers = []; % 用來儲存群中心
while true
    % 找到最大密度的點，作為群中心
    [max_density, idx] = max(density);
    if max_density < eps
        break; % 如果密度低於閾值，停止迴圈
    end
    cluster_centers = [cluster_centers; data(idx, :)];
    
    % 修改資料密度度量
    for i = 1:num_points
        diff = data(i, :) - data(idx, :);
        dist_sq = sum(diff.^2);
        density(i) = density(i) - max_density * exp(-dist_sq / ((rb/2)^2));
    end
end

% 繪製結果
figure;
hold on;

% 繪製資料點
scatter(data(:, 1), data(:, 2), 'b', 'filled'); % 原始數據點

% 繪製群中心和其影響範圍
theta = linspace(0, 2*pi, 100); % 用於畫圓
for i = 1:size(cluster_centers, 1)
    % 圓的坐標
    x_circle = cluster_centers(i, 1) + ra * cos(theta);
    y_circle = cluster_centers(i, 2) + ra * sin(theta);
    
    % 繪製圓
    plot(x_circle, y_circle, 'r--'); % 用虛線表示範圍
end

% 繪製群中心
scatter(cluster_centers(:, 1), cluster_centers(:, 2), 'r', 'filled', 'd'); % 群中心

% 設定圖例和標籤
legend('資料點', '群中心範圍');
xlabel('X');
ylabel('Y');
title('減法群聚結果及影響範圍');
grid on;
hold off;


