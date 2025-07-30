% 隨機生成 100 x 2 的 complex dataset
data = rand(30, 2) + 1i * rand(30, 2);  % 複數數據
% 參數設定
ra = 0.3;
rb = 1.5 * ra;
eps = 1;

% 初始化密度，計算各點之間的密度度量
num_points = size(data, 1);
density = zeros(num_points, 1);
for i = 1:num_points
    density_i = 0;
    for j = 1:num_points
        diff = (data(j,:) - data(i,:)).';  % column vector for Hermitian
        dist_sq = real(diff' * diff);      % Hermitian norm squared
        density_i = density_i + exp(-dist_sq / ((ra/2)^2));
    end
    density(i) = density_i;
end

% 開始減法群聚
cluster_centers = [];
while true
    [max_density, idx] = max(density);
    if max_density < eps
        break;
    end
    cluster_centers = [cluster_centers; data(idx, :)];
    
    for i = 1:num_points
        diff = (data(i,:) - data(idx,:)).';
        dist_sq = real(diff' * diff);
        density(i) = density(i) - max_density * exp(-dist_sq / ((rb/2)^2));
    end
end

% 繪製結果（以實部與虛部示意）
figure;
hold on;
scatter(real(data(:, 1)), imag(data(:, 1)), 'b', 'filled');  % 使用第 1 維作圖

theta = linspace(0, 2*pi, 100);
for i = 1:size(cluster_centers, 1)
    x_circle = real(cluster_centers(i, 1)) + ra * cos(theta);
    y_circle = imag(cluster_centers(i, 1)) + ra * sin(theta);
    plot(x_circle, y_circle, 'r--');
end
scatter(real(cluster_centers(:, 1)), imag(cluster_centers(:, 1)), 'r', 'filled', 'd');

legend('資料點', '群中心範圍');
xlabel('實部 (Real)');
ylabel('虛部 (Imag)');
title('複數型的減法群聚演算法');
grid on;
hold off;



figure;
hold on;
scatter(real(data(:, 1)), real(data(:, 2)), 'b', 'filled');  % 使用第 1 維作圖

theta = linspace(0, 2*pi, 100);
for i = 1:size(cluster_centers, 1)
    x_circle = real(cluster_centers(i, 1)) + ra * cos(theta);
    y_circle = real(cluster_centers(i, 2)) + ra * sin(theta);
    plot(x_circle, y_circle, 'r--');
end
scatter(real(cluster_centers(:, 1)), real(cluster_centers(:, 2)), 'r', 'filled', 'd');

legend('資料點', '群中心範圍');
xlabel('實部 (Real) x');
ylabel('實部 (Imag) y');
title('複數型的減法群聚演算法');
grid on;
hold off;


figure;
hold on;
scatter(imag(data(:, 1)), imag(data(:, 2)), 'b', 'filled');  % 使用第 1 維作圖

theta = linspace(0, 2*pi, 100);
for i = 1:size(cluster_centers, 1)
    x_circle = imag(cluster_centers(i, 1)) + ra * cos(theta);
    y_circle = imag(cluster_centers(i, 2)) + ra * sin(theta);
    plot(x_circle, y_circle, 'r--');
end
scatter(imag(cluster_centers(:, 1)), imag(cluster_centers(:, 2)), 'r', 'filled', 'd');

legend('資料點', '群中心範圍');
xlabel('虛部 (Imag) x');
ylabel('虛部 (Imag) y');
title('複數型的減法群聚演算法');
grid on;
hold off;
