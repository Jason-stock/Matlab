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
% (此部分與採樣無關，但保留原功能)
Umin_x = 0.0;
Umax_x = 0.6;
r_values_rescaled = rescale_axis_range(r_values_original, Umin_x, Umax_x);
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
ylabel('機率密度 P(r)', 'FontSize', 12);
legend(sprintf('調整後 X 軸範圍: [%.4f, %.4f]', min(r_values_rescaled), max(r_values_rescaled)));
grid on;
xlim([Umin_x, Umax_x]); 


%% 4. 使用逆轉換採樣 (Inverse Transform Sampling) 生成隨機樣本
fprintf('--------------------------------------------------\n');
fprintf('開始執行逆轉換採樣...\n');

% 設定要生成的樣本數量
num_samples = 20000; % 例如，生成 20000 個樣本

% 呼叫逆轉換採樣函數
generated_samples = inverse_transform_sampling(r_values_original, P_r_values_normalized, num_samples);

fprintf('已成功生成 %d 個樣本。\n', num_samples);
fprintf('樣本範圍: [%.4f, %.4f]\n', min(generated_samples), max(generated_samples));

%% 5. 繪製生成的樣本分佈 vs. 原始 P(r) (Figure 2)
figure('Name', '逆轉換採樣結果 (修正後)');

% 5.1. 繪製生成樣本的直方圖 (歸一化為 PDF)
histogram(generated_samples, 100, 'Normalization', 'pdf', 'DisplayName', '生成的樣本 (Histogram)');
hold on;

% 5.2. 疊加繪製原始的 P(r) 函數以供比較
plot(r_values_original, P_r_values_normalized, 'r-', 'LineWidth', 2, 'DisplayName', '原始 P(r) 函數');

title('逆轉換採樣樣本分佈 vs. 原始 PDF', 'FontSize', 14);
xlabel('物理半徑 r', 'FontSize', 12);
ylabel('機率密度', 'FontSize', 12);
legend;
grid on;
xlim([min(r_values_original), 15]); % 由於 PDF 集中在左側，可縮放 X 軸以便觀察
% xlim([min(r_values_original), max(r_values_original)]); % 顯示完整 r 範圍


%% ========================================================================
% ==                      輔助函數 (Functions)                        ==
% ========================================================================

function U_x = rescale_axis_range(G_x, Umin_x, Umax_x)
%RESCALE_AXIS_RANGE 將輸入的 X 軸向量 G_x 線性映射到一個新的範圍 [Umin_x, Umax_x]
    
    Gmin_x = min(G_x);
    Gmax_x = max(G_x);
    
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
%
%   輸入:
%       x_values     - PDF 的 X 軸 (例如 r_values_original)
%       pdf_values   - PDF 的 Y 軸 (例如 P_r_values_normalized)
%       num_samples  - 要生成的樣本數量
%
%   輸出:
%       samples      - 生成的隨機樣本向量

    % 1. 計算數值 CDF (累積分佈函數)
    % 確保 x_values 和 pdf_values 是行向量
    x_values = x_values(:)';
    pdf_values = pdf_values(:)';
    CDF_values = cumtrapz(x_values, pdf_values);

    % 2. 確保 CDF 範圍是 [0, 1] 
    % 為了數值穩定性，我們手動將第一個值設為 0，最後一個值設為 1
    CDF_values(1) = 0;
    CDF_values(end) = 1;
    
    % 3. 【修正】處理 CDF 中的平坦區域 (重複值)
    % 我們需要一個 "嚴格" 單調遞增的 CDF 向量 (CDF_unique)
    % 和 "對應" 的 x 值 (x_unique)
    
    % 使用 'last' 選項：
    % 這會保留每個 "平台期" (例如 CDF = 0 或 CDF = 1) 的 *最後一個* 點的索引。
    % - 對於開頭的 0 平台，它會正確地將 u=0 映射到 PDF 開始有值的點。
    % - 對於結尾的 1 平台，它會正確地將 u=1 映射到 x 軸的終點 (例如 r=30)。
    [CDF_unique, ia] = unique(CDF_values, 'last');
    
    % 根據 'last' 索引，提取對應的 x 值
    x_unique = x_values(ia);

    % 4. 生成 U(0, 1) 的均勻分佈隨機數
    u = rand(num_samples, 1);

    % 5. 執行逆轉換：使用 "乾淨" 且 "唯一" 的 CDF 和 X 值進行插值
    % interp1(Y_lookup, X_lookup, Y_query)
    % Y_lookup (CDF_unique) 必須是唯一的
    samples = interp1(CDF_unique, x_unique, u);
end