% 主腳本：演示如何將 X 軸 (r_values) 調整到自訂範圍 [0, 0.6]
% 並演示如何使用逆轉換採樣 (Inverse Transform Sampling)
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
% 歸一化Y軸面積
area = trapz(r_values_original, P_r_values);
P_r_values_normalized = P_r_values / area;

fprintf('已生成原始 P(r) 函數。\n');
fprintf('原始 X 軸範圍 (G_x): [%.1f, %.1f]\n', min(r_values_original), max(r_values_original));
fprintf('--------------------------------------------------\n');

%% 2. 設定 X 軸的自訂範圍並呼叫函數
% 使用者想要調整 X 軸成的目標範圍 [Umin_x, Umax_x]
Umin_x = 0.0;
Umax_x = 0.6;

% 【修改】定義固定的來源範圍
source_range = [min(r_values_original), max(r_values_original)];

% 【修改】呼叫 rescale_axis_range 函數來調整 X 軸，傳入固定的來源範圍
r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x, source_range);

fprintf('已將 X 軸調整至 [%.1f, %.1f]\n', Umin_x, Umax_x);
fprintf('驗證：調整後 X 軸的實際範圍為 [%.6f, %.6f]\n', min(r_values_rescaled), max(r_values_rescaled));


%% 3. 繪製調整前後的 P(r) 函數圖形 (Figure 1)
figure('Name', 'X 軸範圍調整前後對比');
subplot(2, 1, 1); 
plot(r_values_original, P_r_values_normalized, 'b-', 'LineWidth', 2);
title('調整前的 P(r) 函數', 'FontSize', 14);
xlabel('原始 X 軸 (物理半徑 r)', 'FontSize', 12);
ylabel('機率密度 P(r)', 'FontSize', 12);
legend(sprintf('原始 X 軸範圍: [%.1f, %.1f]', min(r_values_original), max(r_values_original)));
grid on;

subplot(2, 1, 2); 
plot(r_values_rescaled, P_r_values_normalized, 'r-', 'LineWidth', 2);
title(sprintf('調整後的 P(r) 函數 - 目標 X 軸範圍 [%.1f, %.1f]', Umin_x, Umax_x), 'FontSize', 14);
xlabel('調整後的 X 軸 (標準化半徑)', 'FontSize', 12);
ylabel('機率密度 P(r) (Y軸未縮放)', 'FontSize', 12);
legend(sprintf('調整後 X 軸範圍: [%.4f, %.4f]', min(r_values_rescaled), max(r_values_rescaled)));
grid on;
xlim([Umin_x, Umax_x]); 


%% 4. 使用逆轉換採樣 (Inverse Transform Sampling) 生成隨機樣本
fprintf('--------------------------------------------------\n');
fprintf('開始執行逆轉換採樣...\n');
num_samples = 20000; 
generated_samples = inverse_transform_sampling(r_values_original, P_r_values_normalized, num_samples);
fprintf('已成功生成 %d 個樣本。\n', num_samples);
fprintf('樣本範圍: [%.4f, %.4f]\n', min(generated_samples), max(generated_samples));

%% 5. 繪製生成的樣本分佈 vs. 原始 P(r) (Figure 2)
figure('Name', '逆轉換採樣結果 (原始 [0, 30] 範圍)');
histogram(generated_samples, 100, 'Normalization', 'pdf', 'DisplayName', '生成的樣本 (Histogram)');
hold on;
plot(r_values_original, P_r_values_normalized, 'r-', 'LineWidth', 2, 'DisplayName', '原始 P(r) 函數');
title('逆轉換採樣樣本分佈 vs. 原始 PDF', 'FontSize', 14);
xlabel('物理半徑 r', 'FontSize', 12);
ylabel('機率密度', 'FontSize', 12);
legend;
grid on;
xlim([min(r_values_original), 15]); % 縮放 X 軸以便觀察


%% 6. 【修正】繪製 "縮放後" 的樣本分佈 vs. "縮放後" 的 P(r) (Figure 3)
figure('Name', '逆轉換採樣結果 (縮放後 [0, 0.6] 範圍) - 已修正');

% 6.1. 【修正】將生成的樣本 (在 [0, 30] 空間) 縮放到 [0, 0.6] 空間
% **關鍵修正：** 傳入 'source_range' ([0, 30]) 作為第四個參數
% 這樣才能確保樣本和 PDF 是在 *相同* 的基礎上被縮放的
rescaled_samples = rescale_axis_range(generated_samples, Umin_x, Umax_x, source_range);

% 6.2. 為了使 PDF 在 [0, 0.6] 上的積分仍為 1，我們必須調整 Y 軸 (密度)
scaling_factor = (source_range(2) - source_range(1)) / (Umax_x - Umin_x);
P_r_values_rescaled_density = P_r_values_normalized .* scaling_factor;

% 6.3. 繪製 "縮放後樣本" 的直方圖
histogram(rescaled_samples, 100, 'Normalization', 'pdf', 'DisplayName', '縮放後的樣本 (Histogram)');
hold on;

% 6.4. 疊加繪製 "X 軸和 Y 軸都經過縮放" 的 PDF
plot(r_values_rescaled, P_r_values_rescaled_density, 'r-', 'LineWidth', 2, 'DisplayName', '縮放後的 P(r) 函數 (密度已調整)');

title('縮放後樣本分佈 vs. 縮放後 PDF (已修正)', 'FontSize', 14);
xlabel('調整後的 X 軸 (標準化半徑)', 'FontSize', 12);
ylabel('調整後的機率密度', 'FontSize', 12);
legend;
grid on;
xlim([Umin_x, Umax_x]); % 鎖定 X 軸到 [0, 0.6]


%% ========================================================================
% ==                      輔助函數 (Functions)                        ==
% ========================================================================

function U_x = rescale_axis_range(G_x, Umin_x, Umax_x, G_source_range)
%RESCALE_AXIS_RANGE 將輸入的 X 軸向量 G_x 線性映射到一個新的範圍 [Umin_x, Umax_x]
%
%   輸入:
%       G_x             - 原始的 X 軸數據向量 (例如 r_values 或 generated_samples)
%       Umin_x          - 目標 X 軸範圍的最小值
%       Umax_x          - 目標 X 軸範圍的最大值
%       G_source_range  - (可選) [Gmin, Gmax] 向量。如果提供，
%                         函數將使用此範圍作為來源範圍，而不是 G_x 的 min/max。

    % 【修改】 檢查是否提供了 G_source_range
    if nargin < 4
        % 如果未提供，使用 G_x 自己的 min/max
        Gmin_x = min(G_x(:)); 
        Gmax_x = max(G_x(:));
    else
        % 如果提供了，使用指定的 G_source_range
        Gmin_x = G_source_range(1);
        Gmax_x = G_source_range(2);
    end
    
    if Gmax_x == Gmin_x
        U_x = ones(size(G_x)) * Umin_x;
        warning('輸入的 X 軸向量所有元素都相同。');
        return;
    end

    % 應用標準範圍調整公式
    U_x = ((G_x - Gmin_x) ./ (Gmax_x - Gmin_x)) .* (Umax_x - Umin_x) + Umin_x;
end


function samples = inverse_transform_sampling(x_values, pdf_values, num_samples)
%INVERSE_TRANSFORM_SAMPLING 從數值 PDF 生成隨機樣本

    % 1. 計算數值 CDF (累積分佈函數)
    x_values = x_values(:)';
    pdf_values = pdf_values(:)';
    CDF_values = cumtrapz(x_values, pdf_values);

    % 2. 確保 CDF 範圍是 [0, 1] 
    CDF_values(1) = 0;
    CDF_values(end) = 1;
    
    % 3. 處理 CDF 中的平坦區域 (重複值)
    [CDF_unique, ia] = unique(CDF_values, 'last');
    x_unique = x_values(ia);

    % 4. 生成 U(0, 1) 的均勻分佈隨機數
    u = rand(num_samples, 1);

    % 5. 執行逆轉換：使用 "乾淨" 且 "唯一" 的 CDF 和 X 值進行插值
    samples = interp1(CDF_unique, x_unique, u);
end