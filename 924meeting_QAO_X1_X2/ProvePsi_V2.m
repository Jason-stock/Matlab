% 主腳本：演示如何將 X 軸 (r_values) 調整到自訂範圍 [0, 0.6]
clc;
clear;
close all;

%% 1. 生成原始的 P(r) 函數數據
a0 = 1; 
num_slots = 10000;
num_points = num_slots + 1;

% 原始 X 軸：物理距離 r (範圍 [0, 30])
r_values_original = linspace(0, 30, num_points);

% Y 軸：計算對應的機率密度 P(r)
P_r_values = (4 / a0^3) .* (r_values_original.^2) .* exp(-2 .* r_values_original ./ a0);
% (可選) 歸一化Y軸面積，這不影響X軸的調整
area = trapz(r_values_original, P_r_values);
P_r_values_normalized = P_r_values / area;

fprintf('已生成原始 P(r) 函數。\n');
fprintf('原始 X 軸範圍 (G_x): [%.1f, %.1f]\n', min(r_values_original), max(r_values_original));
fprintf('--------------------------------------------------\n');

%% 2. 設定 X 軸的自訂範圍並呼叫函數
% 使用者想要調整 X 軸成的目標範圍 [Umin_x, Umax_x]
Umin_x = 0.0;
Umax_x = 0.6;

% 呼叫 rescale_axis_range 函數來調整 X 軸
% G_x (原始X軸向量) 是 r_values_original
r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);

fprintf('已將 X 軸調整至 [%.1f, %.1f]\n', Umin_x, Umax_x);
fprintf('驗證：調整後 X 軸的實際範圍為 [%.6f, %.6f]\n', min(r_values_rescaled), max(r_values_rescaled));

%% 3. 繪製調整前後的 P(r) 函數圖形
figure('Name', 'X 軸範圍調整前後對比');

% --- 繪製調整前的圖形 ---
subplot(2, 1, 1); % 建立一個 2x1 的圖形網格，並選擇第 1 個
plot(r_values_original, P_r_values_normalized, 'b-', 'LineWidth', 2);
title('調整前的 P(r) 函數', 'FontSize', 14);
xlabel('原始 X 軸 (物理半徑 r)', 'FontSize', 12);
ylabel('機率密度 P(r)', 'FontSize', 12);
legend(sprintf('原始 X 軸範圍: [%.1f, %.1f]', min(r_values_original), max(r_values_original)));
grid on;

% --- 繪製調整後的圖形 ---
subplot(2, 1, 2); % 選擇第 2 個子圖
plot(r_values_rescaled, P_r_values_normalized, 'r-', 'LineWidth', 2);
title(sprintf('調整後的 P(r) 函數 - 目標 X 軸範圍 [%.1f, %.1f]', Umin_x, Umax_x), 'FontSize', 14);
xlabel('調整後的 X 軸 (標準化半徑)', 'FontSize', 12);
ylabel('機率密度 P(r)', 'FontSize', 12);
legend(sprintf('調整後 X 軸範圍: [%.4f, %.4f]', min(r_values_rescaled), max(r_values_rescaled)));
grid on;
% 鎖定X軸範圍到目標範圍
xlim([Umin_x, Umax_x]); 


%% ========================================================================
% ==                  X 軸範圍調整函數 (Function)                     ==
% ========================================================================
function U_x = rescale_axis_range(G_x, Umin_x, Umax_x)
%RESCALE_AXIS_RANGE 將輸入的 X 軸向量 G_x 線性映射到一個新的範圍 [Umin_x, Umax_x]
%
%   輸入:
%       G_x    - 原始的 X 軸數據向量 (例如 r_values)
%       Umin_x - 目標 X 軸範圍的最小值
%       Umax_x - 目標 X 軸範圍的最大值
%
%   輸出:
%       U_x    - 調整到新範圍的 X 軸數據向量

    % 獲取 G_x 的實際最大值和最小值
    Gmin_x = min(G_x);
    Gmax_x = max(G_x);
    
    % 檢查 Gmax 和 Gmin 是否相同，以避免除以零
    if Gmax_x == Gmin_x
        U_x = ones(size(G_x)) * Umin_x;
        warning('輸入的 X 軸向量所有元素都相同。');
        return;
    end

    % 應用標準範圍調整公式 (與 Y 軸調整的邏輯相同)
    % U_x = ( (G_x - Gmin_x) / (Gmax_x - Gmin_x) ) * (Umax_x - Umin_x) + Umin_x;
    U_x = ((G_x - Gmin_x) ./ (Gmax_x - Gmin_x)) .* (Umax_x - Umin_x) + Umin_x;
end